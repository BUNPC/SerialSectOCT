folder='/projectnb2/npbssmic/ns/Ann_6692/';
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
nslice=32; % define total number of slices
% create_dir(nslice, folder);
cd(datapath);
id=str2num(id);
njobs=1;
section=ceil(ntile/njobs);
% the $SGE-TASK-ID environment variable read in is CHARACTER, need to transfer to number

istart=1;%(id-1)*section+1;
istop=section;

for islice=id
    cd(datapath);
    filename0=dir(strcat('co-1-*.dat')); 
    for iFile=istart:istop
        name=strsplit(filename0(iFile).name,'.');  
        name_dat=strsplit(name{1},'-');
        slice_index=islice;
%         coord=num2str(iFile);
        % Xrpt and Yrpt are x and y scan repetition, default = 1
        Zsize = str2num(name_dat{4}); Xrpt = 1; Xsize=str2num(name_dat{5}); Yrpt = 1; Ysize = str2num(name_dat{6});
        dim1=[Zsize Xrpt Xsize Yrpt Ysize];     % tile size for reflectivity 

        name1=strcat('co-',num2str(islice),'-',num2str(iFile),'-',num2str(Zsize),'-',num2str(Xsize),'-',num2str(Ysize),'.dat'); % gen file name for reflectivity

        ifilePath = [datapath,name1];
        co = single(ReadDat_int16(ifilePath, dim1))./65535*2; 
        name1=strcat('cross-',num2str(islice),'-',num2str(iFile),'-',num2str(Zsize),'-',num2str(Xsize),'-',num2str(Ysize),'.dat'); % gen file name for reflectivity

        ifilePath = [datapath,name1];
        cross = single(ReadDat_int16(ifilePath, dim1))./65535*2; 
        message=strcat('Tile No. ',string(iFile),' is read.', datestr(now,'DD:HH:MM'),'\n');
        fprintf(message);
%         ref=sqrt(co.^2+cross.^2);
%         sur=surprofile2(ref,'PSOCT');
%          surname=strcat(folder,'surf/vol',num2str(islice),'/',num2str(iFile),'.mat');
%          save(surname,'sur');
        Optical_fitting_6692(co,cross,islice, iFile, folder);

    end
    
    sys = 'PSOCT';
% specify mosaic parameters, you can get it from Imagej stitching
xx=-216;    % xx is the X displacement of two adjacent tile align in the X direction
xy=2;     % xy is the Y displacement of two adjacent tile align in the X direction, default to 0
yy=216;    % yy is the Y displacement of two adjacent tile align in the Y direction
yx=2;      % xx is the X displacement of two adjacent tile align in the Y direction, default to 0
numX=9;    % #tiles in X direction
numY=9;    % #tiles in Y direction
Xoverlap=0.15;   % overlap in X direction
Yoverlap=0.15;   % overlap in Y direction
disp=[xx xy yy yx];
mosaic=[numX numY Xoverlap Yoverlap];
pattern = 'bidirectional';  % mosaic pattern, could be bidirectional or unidirectional
pxlsize=[1000 1000];
P2path=folder;
% AIP_stitch(datapath,disp,mosaic,pxlsize,islice,pattern,sys);  
Mus_stitch_6692('mus',P2path,folder,disp,mosaic,pxlsize./10,islice,pattern,sys);           % stitch mus
% Surf_stitch('sur',P2path,folder,disp,mosaic,pxlsize/10,islice,pattern,sys);
% % rewrite_mub_tiles(folder,islice,numX*numY)
Mub_stitch_6692('mub', P2path,folder,disp,mosaic,pxlsize./10,islice,pattern,sys);
%     Ret_stitch('bfg', folder,disp,mosaic,pxlsize./4,islice,pattern,sys);
% rewrite_aip_tiles(folder,islice,numX*numY);
% Bfg_stitch_6692('bfg', P2path, folder,disp,mosaic,pxlsize./10,islice,pattern,sys)
R2_stitch_7694('R2', P2path, folder,disp,mosaic,pxlsize./10,islice,pattern,sys)
% MIP_stitch_6692('mip', P2path,folder,disp,mosaic,pxlsize,islice,pattern,sys)
end

