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

% id=9;%str2num(id);
datapath='/projectnb2/npbssmic/ns/210323_PSOCT_Ann_PTSD1_2/';    
% specify dataset directory
correct_path=strcat(datapath,'replace/');

% add subfunctions for the script. Change directory if not running on BU SCC
addpath('/projectnb/npbssmic/s/Matlab_code/fitting_code');
addpath('/projectnb/npbssmic/s/Matlab_code/PostProcessing');
addpath('/projectnb/npbssmic/s/Matlab_code/PSOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code/ThorOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code');

cd(datapath);
filename0=dir(strcat('1-*AB.dat')); % count #tiles per slice
ntile=length(filename0);
nslice=24; % define total number of slices


% Define your own istart and istop if not running on BU SCC
    njobs=1;
    section=ceil(ntile/njobs);
    % the $SGE-TASK-ID environment variable read in is CHARACTER, need to transfer to number
   
    istart=73;%(id-1)*section+1;
    istop=section;

for islice=9:9
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
        amp = ReadDat_int16(ifilePath, dim1);

        message=strcat('Tile No. ',string(coord),' is read.', datestr(now,'DD:HH:MM'),'\n');
        fprintf(message);


         % saving corrected tiles to folder. Optional
         if(strcmp(sys,'PSOCT'))
           start_point=1;
           name1=strcat(num2str(islice+9),'-',num2str(iFile),'-',num2str(size(amp,1)-start_point+1),'-',num2str(size(amp,2)),'-',num2str(size(amp,3)),'-AB.dat'); % gen file name for reflectivity
           FILE_ref=strcat(correct_path, name1);
           FID=fopen(FILE_ref,'w');
           
           fwrite(FID,amp,'int16');
           fclose(FID);

         end
         


        fprintf(strcat('Tile No. ',coord,' is reconstructed.', datestr(now,'DD:HH:MM'),'\n'));
    end   
    fprintf(strcat('Slice No. ',num2str(islice+1),' is stitched.', datestr(now,'DD:HH:MM'),'\n'));

end