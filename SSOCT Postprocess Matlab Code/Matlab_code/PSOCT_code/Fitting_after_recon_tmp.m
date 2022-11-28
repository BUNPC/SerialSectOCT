folder='/projectnb2/npbssmic/ns/201128_PSOCT_Ann_7694/';
id=str2num(id);
datapath=strcat(folder,'dist_corrected/'); 
% add subfunctions for the script. Change directory if not running on BU SCC
addpath('/projectnb/npbssmic/s/Matlab_code/fitting_code');
addpath('/projectnb/npbssmic/s/Matlab_code/PostProcessing');
addpath('/projectnb/npbssmic/s/Matlab_code/PSOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code/ThorOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code');

nslice=24; 
create_dir(nslice, folder); 
cd(datapath);
filename0=dir(strcat('ref-1-*.dat')); % count #tiles per slice
ntile=length(filename0);
% define total number of slices
% create_dir(nslice, datapath);
   njobs=45;
   section=ceil(ntile/njobs);
    % the $SGE-TASK-ID environment variable read in is CHARACTER, need to transfer to number
   
   istart=(id-1)*section+1;
   istop=id*section;

for islice=8:6:nslice
    cd(datapath);
    filename0=dir(strcat('ref-',num2str(islice),'-*.dat')); 
    for iFile=istart:istop
        if ~isfile(strcat(folder,'fitting/vol',num2str(islice),'/bfg-',num2str(islice),'-',num2str(iFile),'.mat'))

        name=strsplit(filename0(iFile).name,'.');  
        name_dat=strsplit(name{1},'-');
        slice_index=islice;
        coord=num2str(iFile);
        % Xrpt and Yrpt are x and y scan repetition, default = 1
        Zsize = str2num(name_dat{4}); Xrpt = 1; Xsize=str2num(name_dat{5}); Yrpt = 1; Ysize = str2num(name_dat{6});
        dim1=[Zsize Xrpt Xsize Yrpt Ysize];     % tile size for reflectivity 
%         dim1=[100 1 1100 1 1100];
        name1=strcat('ref-',num2str(islice),'-',num2str(iFile),'-',num2str(Zsize),'-',num2str(Xsize),'-',num2str(Ysize),'.dat'); % gen file name for reflectivity
        % load reflectivity data
        ifilePath = [datapath,name1];
        ref = single(ReadDat_int16(ifilePath, dim1))./65535*2; 
        name1=strcat('ret-',num2str(islice),'-',num2str(iFile),'-',num2str(62),'-',num2str(Xsize),'-',num2str(Ysize),'.dat'); % gen file name for reflectivity
        % load reflectivity data
        ifilePath = [datapath,name1];
        ret = single(ReadDat_int16(ifilePath, [62 1 1000 1 1000]))./65535*pi; 
        message=strcat('Tile No. ',string(coord),' is read.', datestr(now,'DD:HH:MM'),'\n');
        fprintf(message);

        Optical_fitting_tmp(ref,ret,islice, coord, folder);
        end
    end
end

sys = 'PSOCT';
% specify mosaic parameters, you can get it from Imagej stitching
xx=-216;    % xx is the X displacement of two adjacent tile align in the X direction
xy=2;     % xy is the Y displacement of two adjacent tile align in the X direction, default to 0
yy=216;    % yy is the Y displacement of two adjacent tile align in the Y direction
yx=2;      % xx is the X displacement of two adjacent tile align in the Y direction, default to 0
numX=10;    % #tiles in X direction
numY=9;    % #tiles in Y direction
Xoverlap=0.15;   % overlap in X direction
Yoverlap=0.15;   % overlap in Y direction
disp=[xx xy yy yx];
mosaic=[numX numY Xoverlap Yoverlap];
pattern = 'bidirectional';  % mosaic pattern, could be bidirectional or unidirectional
pxlsize=[1000 1000];
% AIP_stitch(datapath,disp,mosaic,pxlsize,islice,pattern,sys);  
%     Mus_stitch_True(folder,disp,mosaic,pxlsize./4,islice,pattern,sys);           % stitch mus
%     Mub_stitch('mub', folder,disp,mosaic,pxlsize./4,islice,pattern,sys);
%     Ret_stitch('bfg', folder,disp,mosaic,pxlsize./4,islice,pattern,sys);
