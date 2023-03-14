%% ----------------------------------------- %%
% Note Mar 14 2023:
%
% Current version of code does FOV correction, grid correction &
% MIP/AIP/Retardance/Orientation generation, surface finding & profiling, 
% volume stitching
%
% Fitting is in Fitting_after_recon.m
%
%
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
%% 
% specify dataset directory
OCTpath  = '/projectnb2/npbssmic/ns/BA4445_samples/I57_part2/';  % OCT data path.              ADJUST FOR EACH SAMPLE!!!
P2path = '/projectnb2/npbssmic/ns/Ann_Mckee_samples_20T/AD_10382_2P/';  % 2P data path.
% leave unchanged if no 2P data is avalable                                                    ADJUST FOR EACH SAMPLE!!!
nslice=56;   % total number of imaging slices.                                                 ADJUST FOR EACH SAMPLE!!!
stitch=1; % 1 means using OCT data to generate stitching coordinates, 
% 0 means using 2P stitching coordinates.                                                      ADJUST FOR EACH SAMPLE!!!

% if using OCT images to generate stitching coordinates, you need three slices that are separated in z for stitching (why three? three channels in RGB format.)
% However, say, you have total of 100 slices, but you don't have enough space in SCC so you want to run 50 slices at a time, then the following slice numbers should be smaller than 50
stitch_slice1=5;    % if stitch == 1, first slice for stitching                                ADJUST FOR EACH SAMPLE!!!
stitch_slice2=9;   % if stitch == 1, second slice for stitching                                ADJUST FOR EACH SAMPLE!!!
stitch_slice3=15;   % if stitch == 1, third slice for stitching                                ADJUST FOR EACH SAMPLE!!!

njobs=1; % number of parallel tasks per slice in SCC parallel processing, default to be 1, meaning each task handles one slice
sys = 'PSOCT'; % specify OCT system name. default to be 'PSOCT
% specify mosaic parameters, you can get it from Imagej stitching
% xx yy is positive for dataset acquired after sep 06
xx=866;    % xx is the X displacement of two adjacent tile align in the X direction
xy=0;     % xy is the Y displacement of two adjacent tile align in the X direction, default to 0
yy=866;    % yy is the Y displacement of two adjacent tile align in the Y direction
yx=0;      % xx is the X displacement of two adjacent tile align in the Y direction, default to 0
numX=23;    % #tiles in X direction                                                            ADJUST FOR EACH SAMPLE!!!
numY=14;    % #tiles in Y direction                                                            ADJUST FOR EACH SAMPLE!!!
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
corrected_path=strcat(OCTpath,'dist_corrected/'); 
mkdir(strcat(OCTpath,'dist_corrected'));
mkdir(strcat(OCTpath,'dist_corrected/volume'));
cd(OCTpath);

filename0=dir(strcat('40-*AB.dat')); % get file names                                          ADJUST FOR EACH SAMPLE!!!
ntile=length(filename0);
start_pixel=90; % start depth for calculating MIP, retardance, and volume reconstruction. 
% Should be 10-20 pixels bellow tissue surface.                                                ADJUST FOR EACH SAMPLE!!!
slice_thickness = 70; % imaging slice thickness in pixels. 
% For U01 sample should be 70, for Ann Mckee samples should be 44.                             ADJUST FOR EACH SAMPLE!!!
aip_threshold=0.035; % intensity threshold for AIP (before BaSiC shading correction) 
% to remove agarous.                                                                           ADJUST FOR EACH SAMPLE!!!
aip_threshold_post_BaSiC=aip_threshold/4; % intensity threshold for AIP (after BaSiC shading correction) to remove agarous. 
%%
% the $SGE-TASK-ID environment variable read in is CHARACTER, need to transfer to number
id = str2num(id);   
section=ceil(ntile/njobs); % total tiles per each paralle task, usually equal to total tiles per slice
istart=1;%(id-1)*section+1; starting tile number for each parallel task
istop=section; % end time number for each parallel task
% create folder for AIPs and MIPs
create_dir(nslice, OCTpath);  
% function that finds tissue surface 
if ~isfile(strcat(OCTpath,'surface.mat'))
    if id==1
        Hui_sum_all(OCTpath,ntile, 11,300); % parameters: data path, ntile, slice#, Z pixels. slice# should be the one that was cut even.
    else
        pause(7200)
    end
end
cd(OCTpath);
load(strcat(OCTpath,'surface.mat'));
surface=round(surface-min(surface(:)));
%%
for islice=id
    cd(OCTpath)
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
        ifilePath = [OCTpath,name1];
        amp = ReadDat_int16(ifilePath, dim1)./65535*4;
        message=strcat('Tile No. ',string(iFile),' is read.', datestr(now,'DD:HH:MM'),'\n');
        fprintf(message);
        
        % distortion correction
        if(strcmp(sys,'PSOCT')) 
            % separating data into different channels
             cross=amp(:,101:1200,1:1100);
             co=amp(:,101:1200,1101:2200);
             ori=amp(:,101:1200,2201:3300);
             ori=ori.*90;
             ori(ori>180)=ori(ori>180)-180;
             % correct for tissue surface tilt
             cross = FOV_curvature_correction(cross, surface, size(cross,1), size(cross,2), size(cross,3));  
%              cross=cross(:,51:1050,51:1050);
            % correct distortion in X and Y dimension
             cross = Grid_correction(cross, grid_matrix, 1050, 51, 1050, 51, size(cross,1));  
             co = FOV_curvature_correction(co, surface, size(co,1), size(co,2), size(co,3)); 
%              co=co(:,51:1050,51:1050);
             co = Grid_correction(co, grid_matrix, 1050, 51, 1050, 51, size(co,1));  
             ori = FOV_curvature_correction(ori, surface, size(ori,1), size(ori,2), size(ori,3)); 
             ori=ori(:,51:1050,51:1050);
%              ori = Grid_correction(ori, grid_matrix, 1050, 51, 1050, 51, size(ori,1));  
             ref=sqrt(cross.^2+co.^2);
             ret=atan(cross./co)./pi*180;
%              ori(ref<aip_threshold)=0;
%              ret(ref<aip_threshold)=0;
        end
         % surface profiling and save to folder
         sur=surprofile2(ref,sys,10); % to check how well blade cuts
         surname=strcat(OCTpath,'surf/vol',num2str(slice_index),'/',num2str(iFile),'.mat');
         save(surname,'sur');
         % Generating AIP, MIP, retardance AIP in mat
         %mip -max intentsity proejction
         %aip- average intensity projection
         mip=squeeze(max(ref(start_pixel:start_pixel+50,:,:),[],1)); 
         aip=squeeze(mean(ref(1:110,:,:),1));
         ret_aip=squeeze(mean(ret(start_pixel:start_pixel+100,:,:),1));  
         
         [X Y]=meshgrid(0.1:100);
         [Xv Yv]=meshgrid(0.1:0.0991:99.1);
         Vq=interp2(X,Y,sur,Xv,Yv);
         sur=round(Vq);
         ori2D=Gen_ori_2D(ori,sur,40);
         
         
         % saving distortion-corrected tiles. Optional
         if(mean2(aip)>aip_threshold || std2(aip)>aip_threshold/4)
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
           % fitting optical parameters. Now we do fitting in
           % Fitting_after_recon.m
           % Optical_fitting_immune2surf(co, cross, s_seg, z_seg, datapath,threshold, mus_depth, bfg_depth, mean_surf)
%            Optical_fitting_immune2surf(co, cross, islice, iFile, datapath,0.09, 130, 100, 60)
         else
%            Optical_fitting_immune2surf(zeros(size(co)), zeros(size(co)), islice, iFile, datapath,0.08, 130, 100, 60)
         end
         
         
        % Saving AIP.tif
        tiffname=strcat(OCTpath,'aip/vol',num2str(slice_index),'/','AIP.tif');
        SaveTiff(aip,iFile,tiffname);
        
       % Saving retardance AIP.tif
        tiffname=strcat(OCTpath,'retardance/vol',num2str(slice_index),'/','RET.tif');
        SaveTiff(ret_aip,iFile,tiffname);

        % Saving orientation ORI.tif
        tiffname=strcat(OCTpath,'orientation/vol',num2str(slice_index),'/','ORI.tif');
        SaveTiff(ori2D,iFile,tiffname);

        % Saving MIP.tif
        tiffname=strcat(OCTpath,'mip/vol',num2str(slice_index),'/','MIP.tif');
        SaveTiff(mip,iFile,tiffname);

        fprintf(strcat('Tile No. ',string(iFile),' is reconstructed.', datestr(now,'DD:HH:MM'),'\n'));
    end  
    % log file confirming this slice has finished distortion correction
    fid=fopen(strcat(OCTpath,'dd',num2str(id),'.txt'),'w');
    fclose(fid);
    system(['chmod -R 777 ',OCTpath]);

%% Stitching
    % pause untile the stitching slices finish distortion correction
    if id==1 && stitch==1 && ~isfile(strcat(OCTpath,'aip/RGB/TileConfiguration.registered.txt'))
        while ~(isfile(strcat(OCTpath,'dd',num2str(stitch_slice1),'.txt')) && isfile(strcat(OCTpath,'dd',num2str(stitch_slice2),'.txt')) && isfile(strcat(OCTpath,'dd',num2str(stitch_slice3),'.txt')))
            pause(600);
        end
        %if we dont have 2P data use this code for stitching
        Gen_OCT_coord(OCTpath,disp,mosaic,pxlsize,islice,pattern, stitch_slice1, stitch_slice2, stitch_slice3); % generating OCT stitching coordinates
    end
    % pause until stitching cooridates are generated
    if stitch==1
        while ~isfile(strcat(OCTpath,'aip/RGB/TileConfiguration.registered.txt')) 
            pause(600);
        end
    end
    AIP_stitch(P2path,OCTpath,disp,mosaic,pxlsize,islice,pattern,sys,stitch,aip_threshold,aip_threshold_post_BaSiC);                             % stitch AIP
    %% stitching fitting results. DO NOT use them for U01 samples. FItting is usually performed separately after RECON.
%     Mus_stitch('mus',P2path,datapath,disp,mosaic,pxlsize./10,islice,pattern,sys,stitch);           % stitch mus
%     Mub_stitch('mub', P2path,datapath,disp,mosaic,pxlsize./10,islice,pattern,sys,stitch);           % stitch mub
% %     rewrite_bfg_tiles(datapath,islice,numX*numY);
%     Bfg_stitch('bfg', P2path,datapath,disp,mosaic,pxlsize./10,islice,pattern,sys,stitch);
%     R2_stitch('R2', P2path, datapath,disp,mosaic,pxlsize./10,islice,pattern,sys,stitch);
%     ZF_stitch('ZF', P2path, datapath,disp,mosaic,pxlsize./10,islice,pattern,sys,stitch);
%     ZR_stitch('ZR', P2path, datapath,disp,mosaic,pxlsize./10,islice,pattern,sys,stitch);
%     BKG_stitch('BKG', P2path, datapath,disp,mosaic,pxlsize./10,islice,pattern,sys,stitch);
    %%
    MIP_stitch('mip', P2path,OCTpath,disp,mosaic,pxlsize,islice,pattern,sys,stitch,aip_threshold_post_BaSiC);                      % stitch MIP
    Surf_stitch('sur',P2path,OCTpath,disp,mosaic,pxlsize/10,islice,pattern,sys,stitch);                                            % stitch surface
    Ret_stitch('ret_aip', P2path,OCTpath,disp,mosaic,pxlsize,islice,pattern,sys,stitch,aip_threshold_post_BaSiC);                  % stitch retardance AIP
    
    system(['chmod -R 777 ',OCTpath]);
    Ori_stitch('ori2D', P2path,OCTpath,disp,mosaic,pxlsize,islice,pattern,sys,stitch,aip_threshold_post_BaSiC);                    % stitch orientation
    Gen_ori_RGB(OCTpath,islice, 0.015);
    % convert orientation to RGB using color wheel
    % this is for stitching volume
    BaSiC_shading_and_ref_stitch(islice,P2path,OCTpath, numX*numY, start_pixel, slice_thickness,stitch,aip_threshold_post_BaSiC);  % volume recon 
%     BaSiC_shading_and_ori_stitch(islice,P2path,datapath, numX*numY, 1, 200); 
    fprintf(strcat('Slice No. ',num2str(islice),' is stitched.', datestr(now,'DD:HH:MM'),'\n'));

end
%% log file indicates this slice has done reconstruction
fid=fopen(strcat(OCTpath,'aip/log',num2str(id),'.txt'),'w');
fclose(fid);
cd(strcat(OCTpath,'aip/'))
logfiles=dir(strcat(OCTpath,'aip/log*.txt')); 
% if all slices finish reconstruction, do stacking 
if length(logfiles)==nslice
%    delete log*.txt
   Concat_ref_vol(nslice,OCTpath);
%    ref_mus(OCTpath, nslice, nslice*11, 50, 50); % volume intensity correction, comment the mus part if no fitting is generated
end
system(['chmod -R 777 ',OCTpath]);