folder='/projectnb2/npbssmic/ns/210323_PSOCT_Ann_PTSD1_3/';
datapath=strcat(folder,'dist_corrected/'); 

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

%     njobs=1;
%     section=ceil(ntile/njobs);
%     % the $SGE-TASK-ID environment variable read in is CHARACTER, need to transfer to number
    id=str2num(id);
%     id=3*id-2;
%     istart=36;%(id-1)*section+1;
%     istop=section;
for islice=id
    filename0=dir(strcat('co-',num2str(islice),'-*.dat')); 
    for iFile=1:length(filename0)
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
        ref = (ReadDat_int16(ifilePath, dim1)./65535*2).^2; 
        name1=strcat('cross-',num2str(islice),'-',num2str(iFile),'-',num2str(Zsize),'-',num2str(Xsize),'-',num2str(Ysize),'.dat'); % gen file name for reflectivity
        % load reflectivity data
        ifilePath = [datapath,name1];
        ref = ref+(ReadDat_int16(ifilePath, dim1)./65535*2).^2; 
        ref=sqrt(ref);
        message=strcat('Tile No. ',string(coord),' is read.', datestr(now,'DD:HH:MM'),'\n');
        fprintf(message);
        Optical_fitting(ref,id, coord, folder, 3);
    end
end

sys = 'PSOCT';
% specify mosaic parameters, you can get it from Imagej stitching
xx=866;    % xx is the X displacement of two adjacent tile align in the X direction
xy=-8;     % xy is the Y displacement of two adjacent tile align in the X direction, default to 0
yy=866;    % yy is the Y displacement of two adjacent tile align in the Y direction
yx=8;      % xx is the X displacement of two adjacent tile align in the Y direction, default to 0
numX=8;    % #tiles in X direction
numY=8;    % #tiles in Y direction
Xoverlap=0.15;   % overlap in X direction
Yoverlap=0.15;   % overlap in Y direction
disp=[xx xy yy yx];
mosaic=[numX numY Xoverlap Yoverlap];
pattern = 'bidirectional';  % mosaic pattern, could be bidirectional or unidirectional
pxlsize=[1000 1000];
% AIP_stitch(folder,disp,mosaic,pxlsize,id,pattern,sys); 
Mus_stitch('mus',folder,disp,mosaic,pxlsize./10,id,pattern,sys);           % stitch mus
Mub_stitch('mub', folder,disp,mosaic,pxlsize./10,id,pattern,sys);
