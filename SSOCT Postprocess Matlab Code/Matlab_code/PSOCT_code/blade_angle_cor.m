folder='/projectnb2/npbssmic/ns/210323_PSOCT_Ann_PTSD1_3/';
datapath=strcat(folder,'dist_corrected/'); 
corrected_path=strcat(datapath,'replace/');
% add subfunctions for the script. Change directory if not running on BU SCC
addpath('/projectnb/npbssmic/s/Matlab_code/fitting_code');
addpath('/projectnb/npbssmic/s/Matlab_code/PostProcessing');
addpath('/projectnb/npbssmic/s/Matlab_code/PSOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code/ThorOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code');

cd(datapath);
filename0=dir(strcat('co-1-*.dat')); % count #tiles per slice
ntile=length(filename0);
nslice=9; % define total number of slices

    njobs=1;
    section=ceil(ntile/njobs);
    % the $SGE-TASK-ID environment variable read in is CHARACTER, need to transfer to number
    id=str2num(id);
%     id=3*id-2;
    istart=1;%(id-1)*section+1;
    istop=section;

for islice=id
    filename0=dir(strcat('co-',num2str(islice),'-*.dat')); 
    for iFile=istart:istop
        name=strsplit(filename0(iFile).name,'.');  
        name_dat=strsplit(name{1},'-');
        slice_index=islice;
        coord=num2str(iFile);
        % Xrpt and Yrpt are x and y scan repetition, default = 1
        Zsize = str2num(name_dat{4}); Xrpt = 1; Xsize=str2num(name_dat{5}); Yrpt = 1; Ysize = str2num(name_dat{6});
        dim1=[Zsize Xrpt Xsize Yrpt Ysize];     % tile size for reflectivity 
        name1=strcat('co-',num2str(islice),'-',num2str(iFile),'-',num2str(Zsize),'-',num2str(Xsize),'-',num2str(Ysize),'.dat'); % gen file name for reflectivity
        % load reflectivity data
        ifilePath = [datapath,name1];
        co = ReadDat_int16(ifilePath, dim1); 
        name1=strcat('cross-',num2str(islice),'-',num2str(iFile),'-',num2str(Zsize),'-',num2str(Xsize),'-',num2str(Ysize),'.dat'); % gen file name for reflectivity
        % load reflectivity data
        ifilePath = [datapath,name1];
        cross = ReadDat_int16(ifilePath, dim1); 
        message=strcat('Tile No. ',string(coord),' is read.', datestr(now,'DD:HH:MM'),'\n');
        fprintf(message);
        z0=(10-floor((iFile-1)/8))*5;
        z0=max(z0,0);
        co_tmp=zeros(200,1000,1000);
        cross_tmp=zeros(200,1000,1000);
        for i=1:1000
            z=ceil(i/200);
            co_tmp(:,i,:)=co(z0+z:z0+z+199,i,:);
            cross_tmp(:,i,:)=cross(z0+z:z0+z+199,i,:);
        end
           start_point=1;
           name1=strcat(num2str(islice),'-',num2str(iFile),'-',num2str(size(cross_tmp,1)-start_point+1),'-',num2str(size(cross_tmp,2)),'-',num2str(size(cross_tmp,3)),'.dat'); % gen file name for reflectivity
           FILE_ref=strcat(corrected_path, 'cross-', name1);
           FID=fopen(FILE_ref,'w');
           fwrite(FID,cross_tmp(start_point:end,:,:),'int16');
           fclose(FID);

           name2=strcat(num2str(islice),'-',num2str(iFile),'-',num2str(size(co_tmp,1)-start_point+1),'-',num2str(size(co_tmp,2)),'-',num2str(size(co_tmp,3)),'.dat'); % gen file name for reflectivity
           FILE_ret=strcat(corrected_path, 'co-', name2);
           FID=fopen(FILE_ret,'w');
           fwrite(FID,co_tmp(start_point:end,:,:),'int16');
           fclose(FID);
    end
end
