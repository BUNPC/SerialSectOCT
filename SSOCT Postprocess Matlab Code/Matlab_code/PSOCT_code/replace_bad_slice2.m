folder='/projectnb2/npbssmic/ns/201128_PSOCT_Ann_7694/';
datapath=strcat(folder,'dist_corrected/'); 

% add subfunctions for the script. Change directory if not running on BU SCC
addpath('/projectnb/npbssmic/s/Matlab_code/fitting_code');
addpath('/projectnb/npbssmic/s/Matlab_code/PostProcessing');
addpath('/projectnb/npbssmic/s/Matlab_code/PSOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code/ThorOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code');

cd(datapath);
filename0=dir(strcat('ref-2-*.dat')); % count #tiles per slice
ntile=length(filename0);
nslice=24; % define total number of slices

    njobs=1;
    section=ceil(ntile/njobs);
    % the $SGE-TASK-ID environment variable read in is CHARACTER, need to transfer to number
    id=2;%str2num(id);
    istart=1;%(id-1)*section+1;
    istop=section;

for islice=id
    filename0=dir(strcat('ref-',num2str(islice),'-*.dat')); 
    for iFile=istart:istop
        name=strsplit(filename0(iFile).name,'.');  
        name_dat=strsplit(name{1},'-');
        slice_index=islice;
        coord=num2str(iFile);
        % Xrpt and Yrpt are x and y scan repetition, default = 1
        Zsize = str2num(name_dat{4}); Xrpt = 1; Xsize=str2num(name_dat{5}); Yrpt = 1; Ysize = str2num(name_dat{6});
        dim1=[Zsize Xrpt Xsize Yrpt Ysize];     % tile size for reflectivity 
        name1=strcat('ref-',num2str(islice),'-',num2str(iFile),'-',num2str(Zsize),'-',num2str(Xsize),'-',num2str(Ysize),'.dat'); % gen file name for reflectivity
        % load reflectivity data
        ifilePath = [datapath,name1];
        ref = ReadDat_int16(ifilePath, dim1)./65535*2; 
        message=strcat('Tile No. ',string(coord),' is read.', datestr(now,'DD:HH:MM'),'\n');
        fprintf(message);
        name1=strcat(num2str(islice),'-',num2str(iFile),'-',num2str(size(ref,1)+27),'-',num2str(size(ref,2)),'-',num2str(size(ref,3)),'.dat'); % gen file name for reflectivity
       FILE_ref=strcat(datapath, 'replace/ref-', name1);
       FID=fopen(FILE_ref,'w');
       fwrite(FID,[ref;zeros(27,1000,1000)],'int16');
       fclose(FID);
    end
end
