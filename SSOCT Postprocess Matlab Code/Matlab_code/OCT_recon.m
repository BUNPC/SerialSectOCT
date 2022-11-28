%% ----------------------------------------- %%
% Note Jan 28 2020:
%
% Current version of code does FOV correction, grid correction & MIP/AIP
% generation, surface finding & profiling, mosacing & blending
%
% Suggested parallelization method: one slice per thread
% 
% volume stitching is currently in another code
%
% Note Oct 28 2019:
%
% Current version of code does FOV correction, grid correction & MIP/AIP
% generation, surface finding & profiling, mosacing & blending
% 
% volume stitching is currently in another code
%
% Note Nov 5 2019:
% 
% All parameters were moved to the beginning of the script
% volume stitching is currently in another code
%
% Note 09/02/2020
%
% Current version of code does FOV correction(optional), grid correction(optional) & MIP/AIP
% generation, surface finding & profiling, mosacing & blending
%
%
% Author: Jiarui Yang, Shuaibin Chang
%%%%%%%%%%%%%%%%%%%%%%%
%%
% add subfunctions for the script. Change directory if not running on BU SCC
addpath('/projectnb/npbssmic/s/Matlab_code/fitting_code');
addpath('/projectnb/npbssmic/s/Matlab_code/PostProcessing');
addpath('/projectnb/npbssmic/s/Matlab_code/PSOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code/ThorOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code');
% specify dataset directory
datapath  = '/projectnb2/npbssmic/ns/BA4445_samples/BA4445_5_slice17_end/';
P2path = '/projectnb2/npbssmic/ns/Ann_Mckee_samples_20T/AD_10382_2P/';   % 2P file path
nslice=76; % define total number of slice
njobs=1; % number of jobs per slice in SCC parallel processing, default to be 1
% specify OCT system name
sys = 'PSOCT';
% specify mosaic parameters, you can get it from Imagej stitching
%% xx yy is positive for dataset acquired after sep 06
xx=866;    % xx is the X displacement of two adjacent tile align in the X direction
xy=0;     % xy is the Y displacement of two adjacent tile align in the X direction, default to 0
yy=866;    % yy is the Y displacement of two adjacent tile align in the Y direction
yx=0;      % xx is the X displacement of two adjacent tile align in the Y direction, default to 0
numX=17;    % #tiles in X direction
numY=13;    % #tiles in Y direction
Xoverlap=0.05;   % overlap in X direction
Yoverlap=0.05;   % overlap in Y direction
disp=[xx xy yy yx];
mosaic=[numX numY Xoverlap Yoverlap];
pxlsize=[1000 1000];
pattern = 'bidirectional';  % mosaic pattern, could be bidirectional or unidirectional
% load distortion correction matrixes, Optional
if(strcmp(sys,'PSOCT'))
    folder_distort='/projectnb2/npbssmic/ns/distortion_correction/OCT_grid_after_211021/';                     
    fileID = fopen(strcat(folder_distort,'grid matrix.bin'), 'r'); 
    grid_matrix = fread(fileID,'double');
    fclose(fileID);
    grid_matrix=reshape(grid_matrix, 4,1100,1100);
end
% directory that stores distortion corrected 3D tiles. Optional
corrected_path=strcat(datapath,'dist_corrected/'); 
mkdir(strcat(datapath,'dist_corrected'));
mkdir(strcat(datapath,'dist_corrected/volume'));
cd(datapath);
filename0=dir(strcat('21-*AB.dat')); % count #tiles per slice
ntile=length(filename0);

% the $SGE-TASK-ID environment variable read in is CHARACTER, need to transfer to number
id = 72;%str2num(id);   
section=ceil(ntile/njobs);
istart=1;%(id-1)*section+1;
istop=0;%section;
% create folder for AIPs and MIPs
create_dir(nslice, datapath);  
if ~isfile(strcat(datapath,'surface.mat'))
    Hui_sum_all(datapath,ntile, 11,300); % parameters: data path, ntile, slice#, Z pixels. slice# should be the one that was cut even.
end
cd(datapath);
load(strcat(datapath,'surface.mat'));
surface=round(surface-min(surface(:)));
%%
for islice=id
    cd(datapath)
    for iFile=istart:istop
        % Generate filename, volume dimension before loading file
        name=strsplit(filename0(iFile).name,'.');  
        name_dat=strsplit(name{1},'-');
        slice_index=islice;
        % Xrpt and Yrpt are x and y scan repetition, default = 1
        Zsize = str2num(name_dat{3}); Xrpt = 1; Xsize=str2num(name_dat{4}); Yrpt = 1; Ysize = str2num(name_dat{5});
        dim1=[Zsize Xrpt Xsize Yrpt Ysize*1.5];     % tile size for reflectivity 
        if strcmp(sys,'Thorlabs')
            dim1=[400 1 400 1 400];
        end
        name1=strcat(num2str(islice),'-',num2str(iFile),'-',num2str(Zsize),'-',num2str(Xsize),'-',num2str(Ysize),'-AB.dat'); 
        % load data
        ifilePath = [datapath,name1];
        amp = ReadDat_int16(ifilePath, dim1)./65535*4;
        message=strcat('Tile No. ',string(iFile),' is read.', datestr(now,'DD:HH:MM'),'\n');
        fprintf(message);
        
        % distortion correction
        if(strcmp(sys,'PSOCT')) 
             cross=amp(:,101:1200,1:1100);
             co=amp(:,101:1200,1101:2200);
             ori=amp(:,101:1200,2201:3300);
             ori=ori.*90;
             ori(ori>180)=ori(ori>180)-180;
             cross = FOV_curvature_correction(cross, surface, size(cross,1), size(cross,2), size(cross,3));  
%              cross=cross(:,51:1050,51:1050);
             cross = Grid_correction(cross, grid_matrix, 1050, 51, 1050, 51, size(cross,1));  
             co = FOV_curvature_correction(co, surface, size(co,1), size(co,2), size(co,3)); 
%              co=co(:,51:1050,51:1050);
             co = Grid_correction(co, grid_matrix, 1050, 51, 1050, 51, size(co,1));  
             ori = FOV_curvature_correction(ori, surface, size(ori,1), size(ori,2), size(ori,3)); 
             ori=ori(:,51:1050,51:1050);
%              ori = Grid_correction(ori, grid_matrix, 1050, 51, 1050, 51, size(ori,1));  
             ref=sqrt(cross.^2+co.^2);
             ret=atan(cross./co)./pi*180;
             ori(ref<0.04)=0;
             ret(ref<0.04)=0;
        end
         % surface profiling and save to folder
         sur=surprofile2(ref,sys,10);
         surname=strcat(datapath,'surf/vol',num2str(slice_index),'/',num2str(iFile),'.mat');
         save(surname,'sur');
         % Generating AIP, MIP, retardance AIP in mat
         start_pixel=70; % start depth needs to be configured for each sample !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
         mip=squeeze(max(ref(start_pixel:start_pixel+50,:,:),[],1)); 
         aip=squeeze(mean(ref(1:110,:,:),1));
         ret_aip=squeeze(mean(ret(start_pixel:start_pixel+100,:,:),1));  
         
         [X Y]=meshgrid(0.1:100);
         [Xv Yv]=meshgrid(0.1:0.0991:99.1);
         Vq=interp2(X,Y,sur,Xv,Yv);
         sur=round(Vq);
         ori2D=Gen_ori_2D(ori,sur,40);
         
         % saving corrected tiles to folder. Optional
         if(mean2(aip)>0.03 || std2(aip)>0.002)
           name1=strcat(num2str(islice),'-',num2str(iFile),'-',num2str(size(cross,1)),'-',num2str(size(cross,2)),'-',num2str(size(cross,3)),'.dat'); % gen file name for reflectivity
           FILE_ref=strcat(corrected_path, 'cross-', name1);
           FID=fopen(FILE_ref,'w');
           fwrite(FID,cross./4*65535,'uint16');
           fclose(FID);
           
           name2=strcat(num2str(islice),'-',num2str(iFile),'-',num2str(size(co,1)),'-',num2str(size(co,2)),'-',num2str(size(co,3)),'.dat'); % gen file name for reflectivity
           FILE_ret=strcat(corrected_path, 'co-', name2);
           FID=fopen(FILE_ret,'w');
           fwrite(FID,co./4*65535,'uint16');
           fclose(FID);
           
           name3=strcat(num2str(islice),'-',num2str(iFile),'-',num2str(size(ori,1)),'-',num2str(size(ori,2)),'-',num2str(size(ori,3)),'.dat'); % gen file name for reflectivity
           FILE_ret=strcat(corrected_path, 'ori-', name2);
           FID=fopen(FILE_ret,'w');
           fwrite(FID,(ori./180).*65535,'uint16');
           fclose(FID);
           % Optical_fitting_immune2surf(co, cross, s_seg, z_seg, datapath,threshold, mus_depth, bfg_depth, mean_surf)
%            Optical_fitting_immune2surf(co, cross, islice, iFile, datapath,0.09, 130, 100, 60)
         else
%            Optical_fitting_immune2surf(zeros(size(co)), zeros(size(co)), islice, iFile, datapath,0.08, 130, 100, 60)
         end
         
         
        % Saving AIP.tif
        aip=single(aip);
        tiffname=strcat(datapath,'aip/vol',num2str(slice_index),'/','AIP.tif');
        if iFile==1
            t = Tiff(tiffname,'w');
        else
            t = Tiff(tiffname,'a');
        end
        tagstruct.ImageLength     = size(aip,1);
        tagstruct.ImageWidth      = size(aip,2);
        tagstruct.SampleFormat    = Tiff.SampleFormat.IEEEFP;
        tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
        tagstruct.BitsPerSample   = 32;
        tagstruct.SamplesPerPixel = 1;
        tagstruct.Compression     = Tiff.Compression.None;
        tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
        tagstruct.Software        = 'MATLAB';
        t.setTag(tagstruct);
        t.write(aip);
        t.close();
        
       % Saving retardance AIP.tif
        ret_aip=single(ret_aip);
        tiffname=strcat(datapath,'retardance/vol',num2str(slice_index),'/','RET.tif');
        if iFile==1
            t = Tiff(tiffname,'w');
        else
            t = Tiff(tiffname,'a');
        end
        tagstruct.ImageLength     = size(ret_aip,1);
        tagstruct.ImageWidth      = size(ret_aip,2);
        tagstruct.SampleFormat    = Tiff.SampleFormat.IEEEFP;
        tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
        tagstruct.BitsPerSample   = 32;
        tagstruct.SamplesPerPixel = 1;
        tagstruct.Compression     = Tiff.Compression.None;
        tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
        tagstruct.Software        = 'MATLAB';
        t.setTag(tagstruct);
        t.write(ret_aip);
        t.close();


        % Saving orientation ORI.tif
        ori2D=single(ori2D);
        tiffname=strcat(datapath,'orientation/vol',num2str(slice_index),'/','ORI.tif');
        if iFile==1
            t = Tiff(tiffname,'w');
        else
            t = Tiff(tiffname,'a');
        end
        tagstruct.ImageLength     = size(ori2D,1);
        tagstruct.ImageWidth      = size(ori2D,2);
        tagstruct.SampleFormat    = Tiff.SampleFormat.IEEEFP;
        tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
        tagstruct.BitsPerSample   = 32;
        tagstruct.SamplesPerPixel = 1;
        tagstruct.Compression     = Tiff.Compression.None;
        tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
        tagstruct.Software        = 'MATLAB';
        t.setTag(tagstruct);
        t.write(ori2D);
        t.close();


        % Saving MIP.tif
        mip=single(mip);
        tiffname=strcat(datapath,'mip/vol',num2str(slice_index),'/','MIP.tif');
        if iFile==1
            t = Tiff(tiffname,'w');
        else
            t = Tiff(tiffname,'a');
        end
        tagstruct.ImageLength     = size(mip,1);
        tagstruct.ImageWidth      = size(mip,2);
        tagstruct.SampleFormat    = Tiff.SampleFormat.IEEEFP;
        tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
        tagstruct.BitsPerSample   = 32;
        tagstruct.SamplesPerPixel = 1;
        tagstruct.Compression     = Tiff.Compression.None;
        tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
        tagstruct.Software        = 'MATLAB';
        t.setTag(tagstruct);
        t.write(mip);
        t.close();

        fprintf(strcat('Tile No. ',string(iFile),' is reconstructed.', datestr(now,'DD:HH:MM'),'\n'));
    end   
%% Stitching
    start_pixel=70; 
    stitch=1; % 1 using OCT stitching coordinates, 0 using 2P stitching coordinates
%     fid=fopen(strcat(datapath,'log',num2str(id),'.txt'),'w');
%     fclose(fid);
%     cd(datapath)
%     logfiles=dir(strcat(datapath,'log*.txt')); 
%     while length(logfiles)~=19
%         pause(600);
%     end
%     Gen_OCT_coord(datapath,disp,mosaic,pxlsize,islice,pattern, 5, 9, 15)
%     AIP_stitch(P2path,datapath,disp,mosaic,pxlsize,islice,pattern,sys,stitch);                     % stitch AIP
%     Mus_stitch('mus',P2path,datapath,disp,mosaic,pxlsize./10,islice,pattern,sys,stitch);           % stitch mus
%     Mub_stitch('mub', P2path,datapath,disp,mosaic,pxlsize./10,islice,pattern,sys,stitch);           % stitch mub
% %     rewrite_bfg_tiles(datapath,islice,numX*numY);
%     Bfg_stitch('bfg', P2path,datapath,disp,mosaic,pxlsize./10,islice,pattern,sys,stitch);
%     R2_stitch('R2', P2path, datapath,disp,mosaic,pxlsize./10,islice,pattern,sys,stitch);
%     ZF_stitch('ZF', P2path, datapath,disp,mosaic,pxlsize./10,islice,pattern,sys,stitch);
%     ZR_stitch('ZR', P2path, datapath,disp,mosaic,pxlsize./10,islice,pattern,sys,stitch);
%     BKG_stitch('BKG', P2path, datapath,disp,mosaic,pxlsize./10,islice,pattern,sys,stitch);
%     MIP_stitch('mip', P2path,datapath,disp,mosaic,pxlsize,islice,pattern,sys,stitch);
%     Surf_stitch('sur',P2path,datapath,disp,mosaic,pxlsize/10,islice,pattern,sys,stitch);              % stitch surface
%     Ret_stitch('ret_aip', P2path,datapath,disp,mosaic,pxlsize,islice,pattern,sys,stitch);              % stitch retardance AIP
%     Ori_stitch('ori2D', P2path,datapath,disp,mosaic,pxlsize,islice,pattern,sys,stitch); 
%     Gen_ori_RGB(datapath,islice, 0.015);
    BaSiC_shading_and_ref_stitch(islice,P2path,datapath, numX*numY, start_pixel, 70,stitch); % volume recon start depth, thickness(pixels)!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%     BaSiC_shading_and_ori_stitch(islice,P2path,datapath, numX*numY, 1, 200); % volu
    fprintf(strcat('Slice No. ',num2str(islice),' is stitched.', datestr(now,'DD:HH:MM'),'\n'));
    

end
fid=fopen(strcat(datapath,'aip/log',num2str(id),'.txt'),'w');
fclose(fid);
cd(strcat(datapath,'aip/'))
logfiles=dir(strcat(datapath,'aip/log*.txt')); 
% if length(logfiles)==nslice
%    delete log*.txt
% %    Concat_ref_vol(nslice,datapath);
%    % ref_mus(datapath, nslice, nslice*11, 50); % volume intensity correction, comment the mus part if no fitting is generated
% end