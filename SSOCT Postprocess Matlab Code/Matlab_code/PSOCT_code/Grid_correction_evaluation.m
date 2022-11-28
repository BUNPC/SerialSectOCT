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
% Author: Jiarui Yang, Stephan Chang
%%%%%%%%%%%%%%%%%%%%%%%

%% set file path & system type & stitching parameters

% specify OCT system name
sys = 'PSOCT';
% specify mosaic parameters, you can get it from Imagej stitching
xx=-866;    % xx is the X displacement of two adjacent tile align in the X direction
xy=8;     % xy is the Y displacement of two adjacent tile align in the X direction, default to 0
yy=866;    % yy is the Y displacement of two adjacent tile align in the Y direction
yx=8;      % xx is the X displacement of two adjacent tile align in the Y direction, default to 0
numX=8;    % #tiles in X direction
numY=11;    % #tiles in Y direction
Xoverlap=0.15;   % overlap in X direction
Yoverlap=0.15;   % overlap in Y direction
disp=[xx xy yy yx];
mosaic=[numX numY Xoverlap Yoverlap];
pattern = 'bidirectional';  % mosaic pattern, could be bidirectional or unidirectional
% load distortion correction matrixes, Optional
if(strcmp(sys,'PSOCT'))
    folder_distort='/projectnb2/npbssmic/ns/210323_PSOCT_Ann_PTSD1_3/';                     
%     fileID = fopen(strcat(folder_distort,'grid matrix.bin'), 'r'); 
%     grid_matrix = fread(fileID,'double');
%     fclose(fileID);
%     grid_matrix=reshape(grid_matrix, 4,1100,1100);
    load(strcat(folder_distort,'surface.mat'));
%     load(strcat(folder_distort,'mask.mat'));

end

% specify dataset directory
datapath  = folder_distort;
% directory that stores distortion corrected 3D tiles. Optional
corrected_path=strcat(datapath,'dist_corrected/'); 
mkdir(strcat(datapath,'dist_corrected'));
mkdir(strcat(datapath,'dist_corrected/volume'));
% add subfunctions for the script. Change directory if not running on BU SCC
addpath('/projectnb/npbssmic/s/Matlab_code/fitting_code');
addpath('/projectnb/npbssmic/s/Matlab_code/PostProcessing');
addpath('/projectnb/npbssmic/s/Matlab_code/PSOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code/ThorOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code');

cd(datapath);
filename0=dir(strcat('1-*AB.dat')); % count #tiles per slice
ntile=length(filename0);
nslice=9; % define total number of slices

% the following indented lines are for multi-thread processing
% on BU SCC only. The purpose here is to divide the data into njobs groups,
% njobs being the number of threads used. istart and istop are the start and stop tile
% number for id-th thread.
%
% Define your own istart and istop if not running on BU SCC
id=1;%str2num(id);    
njobs=1;
    section=ceil(ntile/njobs);
    % the $SGE-TASK-ID environment variable read in is CHARACTER, need to transfer to number
   
    istart=1;%(id-1)*section+1;
    istop=section;
% create folder for AIPs and MIPs
create_dir(nslice, datapath);           % create directories for all results
% load(strcat(folder_distort,'/zf.mat'));   % load Zf map, optional
% load(strcat(folder_distort,'/shade.mat'));  % load shading map, optional
for islice=id
    for iFile=istart:istop
        % Generate filename, volume dimension before loading file
        % PSOCT Filename format:slice-tile-Z-X-Y-type.dat. Type can be A, B, AB, ref, ret
        name=strsplit(filename0(iFile).name,'.');  
        name_dat=strsplit(name{1},'-');
        slice_index=islice;
        coord=num2str(iFile);
        % Xrpt and Yrpt are x and y scan repetition, default = 1
        Zsize = str2num(name_dat{3}); Xrpt = 1; Xsize=str2num(name_dat{4}); Yrpt = 1; Ysize = str2num(name_dat{5});
        dim1=[Zsize Xrpt Xsize Yrpt Ysize];     % tile size for reflectivity 
        if strcmp(sys,'Thorlabs')
            dim1=[400 1 400 1 400];
%             dim1=[137 1 1000 1 1000];
        end
        name1=strcat(num2str(islice),'-',num2str(iFile),'-',num2str(Zsize),'-',num2str(Xsize),'-',num2str(Ysize),'-AB.dat'); % gen file name for reflectivity
        
        % load reflectivity data
        ifilePath = [datapath,name1];
        amp = ReadDat_int16(ifilePath, dim1)./65535*2;
        % load retardance data
%         if(strcmp(sys,'PSOCT'))
%             dim2=[Zsize/4 Xrpt Xsize Yrpt Ysize/2];   % tile size for retardance, downsampled by 4 in Z 
%             name2=strcat(num2str(islice),'-',num2str(iFile),'-',num2str(Zsize),'-',num2str(Xsize),'-',num2str(Ysize),'-ret.dat');% gen file name for retardance
%             retPath=[datapath,name2];
%             ret = ReadDat_int16(retPath, dim2)./65535*180;
%         end
        
        message=strcat('Tile No. ',string(coord),' is read.', datestr(now,'DD:HH:MM'),'\n');
        fprintf(message);
        
        % distortion correction for PSOCT. Comment out if not need
        
        if(strcmp(sys,'PSOCT')) 
             cross=amp(:,106:1205,1:1100);
             co=amp(:,106:1205,1101:2200);
             cross = FOV_curvature_correction(cross, surface, size(cross,1), size(cross,2), size(cross,3));           % specify z and x 
%              cross = Grid_correction(cross, grid_matrix, 1050, 51, 1050, 51, size(cross,1));                   % specify x0,x1,y0,y1 and z
cross=cross(:,51:1050,51:1050);             
co = FOV_curvature_correction(co, surface, size(co,1), size(co,2), size(co,3)); % specify z and x 
%              co = Grid_correction(co, grid_matrix, 1050, 51, 1050, 51, size(co,1));                   % specify x0,x1,y0,y1 and z
             co=co(:,51:1050,51:1050); 
ref=sqrt(cross.^2+co.^2);
%              ret=atan(cross./co);
        end

         % surface profiling and save to folder
%          sur=surprofile2(ref,sys);
%          surname=strcat(datapath,'surf/vol',num2str(slice_index),'/',coord,'.mat');
%          save(surname,'sur');
                  
         % saving corrected tiles to folder. Optional
%          if(strcmp(sys,'PSOCT'))
%            start_point=1;
%            name1=strcat(num2str(islice),'-',num2str(iFile),'-',num2str(size(cross,1)-start_point+1),'-',num2str(size(cross,2)),'-',num2str(size(cross,3)),'.dat'); % gen file name for reflectivity
%            FILE_ref=strcat(corrected_path, 'cross-', name1);
%            FID=fopen(FILE_ref,'w');
%            fwrite(FID,cross(start_point:end,:,:)./2*65535,'int16');
%            fclose(FID);
%            
%            name2=strcat(num2str(islice),'-',num2str(iFile),'-',num2str(size(co,1)-start_point+1),'-',num2str(size(co,2)),'-',num2str(size(co,3)),'.dat'); % gen file name for reflectivity
%            FILE_ret=strcat(corrected_path, 'co-', name2);
%            FID=fopen(FILE_ret,'w');
%            fwrite(FID,co(start_point:end,:,:)./2*65535,'int16');
%            fclose(FID);
%          end
         
         % Optical property fitting
%          Optical_fitting(ref,islice, coord, datapath, 3);
         
         % Generating AIP, MIP, retardance AIP in mat
         mip=squeeze(max(ref,[],1));
         aip=squeeze(mean(ref,1));
         avgname=strcat(datapath,'aip/vol',num2str(slice_index),'/',coord,'.mat');
         mipname=strcat(datapath,'mip/vol',num2str(slice_index),'/',coord,'.mat');
         save(mipname,'mip');
         save(avgname,'aip');  
         
%          if(strcmp(sys,'PSOCT'))
%             ret_aip=squeeze(mean(ret(1:40,:,:),1));
%             retname=strcat(datapath,'retardance/vol',num2str(slice_index),'/',coord,'.mat');
%             save(retname,'ret_aip'); 
%          end
       
        % Saving AIP.tif
        aip=single(aip);
        tiffname=strcat(datapath,'aip/vol',num2str(slice_index),'/',coord,'_aip.tif');
        t = Tiff(tiffname,'w');
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
        
%         if(strcmp(sys,'PSOCT'))
%             % Saving retardance AIP.tif
%             ret_aip=single(ret_aip);
%             tiffname=strcat(datapath,'retardance/vol',num2str(slice_index),'/',coord,'_ret.tif');
%             t = Tiff(tiffname,'w');
%             tagstruct.ImageLength     = size(ret,2);
%             tagstruct.ImageWidth      = size(ret,3);
%             tagstruct.SampleFormat    = Tiff.SampleFormat.IEEEFP;
%             tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
%             tagstruct.BitsPerSample   = 32;
%             tagstruct.SamplesPerPixel = 1;
%             tagstruct.Compression     = Tiff.Compression.None;
%             tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
%             tagstruct.Software        = 'MATLAB';
%             t.setTag(tagstruct);
%             t.write(ret_aip);
%             t.close();
%         end
% 
%         % Saving MIP.tif
%         mip=single(mip);
%         tiffname=strcat(datapath,'mip/vol',num2str(slice_index),'/',num2str(str2num(coord)),'_mip.tif');
%         t = Tiff(tiffname,'w');
%         tagstruct.ImageLength     = size(mip,1);
%         tagstruct.ImageWidth      = size(mip,2);
%         tagstruct.SampleFormat    = Tiff.SampleFormat.IEEEFP;
%         tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
%         tagstruct.BitsPerSample   = 32;
%         tagstruct.SamplesPerPixel = 1;
%         tagstruct.Compression     = Tiff.Compression.None;
%         tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
%         tagstruct.Software        = 'MATLAB';
%         t.setTag(tagstruct);
%         t.write(mip);
%         t.close();

        fprintf(strcat('Tile No. ',coord,' is reconstructed.', datestr(now,'DD:HH:MM'),'\n'));
    end   
    pxlsize=[size(cross,2) size(cross,3)];  % finalized tile size for stitching
    
%% Stitching
% Stitch AIP first using Stitch_aip.m and save the coordinates. Same coordinates are used to stitch
% mus, mub, surface and retardance.

    AIP_stitch(datapath,disp,mosaic,pxlsize,islice,pattern,sys);                     % stitch AIP
%     Mus_stitch('mus',datapath,disp,mosaic,pxlsize./10,islice,pattern,sys);           % stitch mus
%     Mub_stitch('mub', datapath,disp,mosaic,pxlsize./10,islice,pattern,sys)           % stitch mub
%     Surf_stitch('sur',datapath,disp,mosaic,pxlsize/10,islice,pattern,'PSOCT');              % stitch surface
%     RetDownsample_Hui('ret', datapath,disp,mosaic,pxlsize,islice,pattern,sys,10);    % downsample retardance. optional
%     Ret_stitch('ret', datapath,disp,mosaic,pxlsize,islice,pattern,sys);              % stitch retardance AIP
    
%     ref_vol_stitch(id,datapath);
%     ref_vol_stitch_from_AB(id,datapath);
    if(strcmp(sys,'PSOCT'))
        
%         ret_vol_stitch(id,datapath);
%         Concat_ret_vol(nslice,datapath);
    end
%     Concat_ref_vol(nslice,datapath);
    fprintf(strcat('Slice No. ',num2str(islice),' is stitched.', datestr(now,'DD:HH:MM'),'\n'));

end