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
datapath  = '/projectnb2/npbssmic/ns/remote_folder/';
P2path = '/projectnb2/npbssmic/ns/BA4445_3_2PM/';   % 2P file path
nslice=104; % define total number of slice
njobs=1; % number of jobs per slice in SCC parallel processing, default to be 1
% specify OCT system name
sys = 'PSOCT';
% specify mosaic parameters, you can get it from Imagej stitching
%% xx yy is positive for dataset acquired after sep 06
xx=866;    % xx is the X displacement of two adjacent tile align in the X direction
xy=0;     % xy is the Y displacement of two adjacent tile align in the X direction, default to 0
yy=866;    % yy is the Y displacement of two adjacent tile align in the Y direction
yx=0;      % xx is the X displacement of two adjacent tile align in the Y direction, default to 0
numX=16;    % #tiles in X direction
numY=17;    % #tiles in Y direction
Xoverlap=0.15;   % overlap in X direction
Yoverlap=0.15;   % overlap in Y direction
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
filename0=dir(strcat('33-*AB.dat')); % count #tiles per slice
ntile=length(filename0);

% the $SGE-TASK-ID environment variable read in is CHARACTER, need to transfer to number
id=66;%str2num(id);   
section=ceil(ntile/njobs);
istart=144;%(id-1)*section+1;
istop=section;
% create folder for AIPs and MIPs
create_dir(nslice, datapath);  
if ~isfile(strcat(datapath,'surface.mat'))
    Hui_sum_all(datapath,ntile, 13,300);
end
cd(datapath)
load(strcat(datapath,'surface.mat'));
surface=round(surface-min(surface(:)));

for islice=id
    cd(datapath)
    for iFile=istart:istop
        if ~isfile(strcat(datapath,'dist_corrected/co-',num2str(islice),'-',num2str(iFile),'-260-1000-1000.dat'))
            % Generate filename, volume dimension before loading file
            name=strsplit(filename0(iFile).name,'.');  
            name_dat=strsplit(name{1},'-');
            slice_index=islice;
            % Xrpt and Yrpt are x and y scan repetition, default = 1
            Zsize = str2num(name_dat{3}); Xrpt = 1; Xsize=str2num(name_dat{4}); Yrpt = 1; Ysize = str2num(name_dat{5});
            dim1=[Zsize Xrpt Xsize Yrpt Ysize];     % tile size for reflectivity 
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

             cross=amp(:,101:1200,1:1100);
             co=amp(:,101:1200,1101:2200);
             cross = FOV_curvature_correction(cross, surface, size(cross,1), size(cross,2), size(cross,3));  
             co = FOV_curvature_correction(co, surface, size(co,1), size(co,2), size(co,3)); 
%              cross=cross(:,51:1050,51:1050);
%              co=co(:,51:1050,51:1050);
             ref=sqrt(cross.^2+co.^2);
             start_pixel=105; % start depth needs to be configured for each sample !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
             aip=squeeze(mean(ref(start_pixel:start_pixel+50,:,:),1));
             
             
             if(mean2(aip)>0.05 || std2(aip)>0.0055)
                 
                 cross = Grid_correction(cross, grid_matrix, 1050, 51, 1050, 51, size(cross,1));  
                 co = Grid_correction(co, grid_matrix, 1050, 51, 1050, 51, size(co,1));  
                 ref=sqrt(cross.^2+co.^2);

             % surface profiling and save to folder
             
             % saving corrected tiles to folder. Optional
             
               name1=strcat(num2str(islice),'-',num2str(iFile),'-',num2str(size(cross,1)),'-',num2str(size(cross,2)),'-',num2str(size(cross,3)),'.dat'); % gen file name for reflectivity
               FILE_ref=strcat(corrected_path, 'cross-', name1);
               FID=fopen(FILE_ref,'w');
               fwrite(FID,cross./4*65535,'int16');
               fclose(FID);

               name2=strcat(num2str(islice),'-',num2str(iFile),'-',num2str(size(co,1)),'-',num2str(size(co,2)),'-',num2str(size(co,3)),'.dat'); % gen file name for reflectivity
               FILE_ret=strcat(corrected_path, 'co-', name2);
               FID=fopen(FILE_ret,'w');
               fwrite(FID,co./4*65535,'int16');
               fclose(FID);

               % Optical_fitting_immune2surf(co, cross, s_seg, z_seg, datapath,threshold, mus_depth, bfg_depth, mean_surf)
    %            Optical_fitting_immune2surf(co, cross, islice, iFile, datapath,threshold, mus_depth, bfg_depth, mean_surf)
             else
    %            Optical_fitting_immune2surf(zeros(size(co)), zeros(size(co)), islice, iFile, datapath,threshold, mus_depth, bfg_depth, mean_surf)
             end


            

            fprintf(strcat('Tile No. ',string(iFile),' is reconstructed.', datestr(now,'DD:HH:MM'),'\n'));
        end
    end   
    
end
