% specify OCT system name
sys = 'PSOCT';

% specify dataset directory
datapath  = strcat('/projectnb2/npbssmic/ns/201028_PSOCT/dist_corrected/');

addpath('/projectnb/npbssmic/s/Matlab_code/fitting_code');
addpath('/projectnb/npbssmic/s/Matlab_code/PostProcessing');
addpath('/projectnb/npbssmic/s/Matlab_code/PSOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code/ThorOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code');

cd(datapath);
filename0=dir(strcat('ref-1-*.dat')); % count #tiles per slice
ntile=length(filename0);
nslice=30; % define total number of slices

% the following indented lines are for multi-thread processing
% on BU SCC only. The purpose here is to divide the data into njobs groups,
% njobs being the number of threads used. istart and istop are the start and stop tile
% number for id-th thread.
%
% Define your own istart and istop if not running on BU SCC
    njobs=1;
    section=ceil(ntile/njobs);
    % the $SGE-TASK-ID environment variable read in is CHARACTER, need to transfer to number
    id=1;%str2num(id);
    istart=1;%(id-1)*section+1;
    istop=section;
         % create directories for all results
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
        Zsize = str2num(name_dat{4}); Xrpt = 1; Xsize=str2num(name_dat{5}); Yrpt = 1; Ysize = str2num(name_dat{6});
%         Zsize=232;
%         Xsize=1000;
%         Ysize=1000;
%         Xrpt=1;
%         Yrpt=1;
        dim1=[Zsize Xrpt Xsize Yrpt Ysize];     % tile size for reflectivity 
 
        if strcmp(sys,'Thorlabs')
            dim1=[400 1 400 1 400];
%             dim1=[137 1 1000 1 1000];
        end
        name1=strcat('ref-',num2str(islice),'-',num2str(iFile),'-',num2str(Zsize),'-',num2str(Xsize),'-',num2str(Ysize),'.dat'); % gen file name for reflectivity
        
        % load reflectivity data
        ifilePath = [datapath,name1];
        ref = uint16(ReadDat_single(ifilePath, dim1)/2*65535);
        % load retardance data
        if(strcmp(sys,'PSOCT'))
            dim2=[54 Xrpt Xsize Yrpt Ysize];   % tile size for retardance, downsampled by 4 in Z 
            name2=strcat('ret-',num2str(islice),'-',num2str(iFile),'-',num2str(54),'-',num2str(Xsize),'-',num2str(Ysize),'.dat');% gen file name for retardance
            retPath=[datapath,name2];
            ret = uint16(ReadDat_single(retPath, dim2));
        end
        
        message=strcat('Tile No. ',string(coord),' is read.', datestr(now,'DD:HH:MM'),'\n');
        fprintf(message);
        

 
                  
         % saving corrected tiles to folder. Optional
         if(strcmp(sys,'PSOCT'))
           start_pxl=1;
           name1=strcat(num2str(islice),'-',num2str(iFile),'-',num2str(size(ref,1)-start_pxl+1),'-',num2str(size(ref,2)),'-',num2str(size(ref,3)),'.dat'); % gen file name for reflectivity
           FILE_ref=strcat(datapath, 'new/','ref-', name1);
           FID=fopen(FILE_ref,'w');
           fwrite(FID,uint16(ref(start_pxl:end,:,:)),'uint16');
           fclose(FID);
           
           name2=strcat(num2str(islice),'-',num2str(iFile),'-',num2str(size(ret,1)),'-',num2str(size(ret,2)),'-',num2str(size(ret,3)),'.dat'); % gen file name for reflectivity
           FILE_ret=strcat(datapath, 'new/','ret-', name2);
           FID=fopen(FILE_ret,'w');
           fwrite(FID,uint16(ret),'uint16');
           fclose(FID);
         end
         
         %
        fprintf(strcat('Tile No. ',coord,' is reconstructed.', datestr(now,'DD:HH:MM'),'\n'));
    end   
  
    fprintf(strcat('Slice No. ',num2str(islice),' is stitched.', datestr(now,'DD:HH:MM'),'\n'));

end