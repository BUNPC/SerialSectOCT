folder='/projectnb2/npbssmic/ns/intralipids_PSOCT/intralipids_20_volume/';
datapath=strcat(folder);
% add subfunctions for the script. Change directory if not running on BU SCC
addpath('/projectnb/npbssmic/s/Matlab_code/fitting_code');
addpath('/projectnb/npbssmic/s/Matlab_code/PostProcessing');
addpath('/projectnb/npbssmic/s/Matlab_code/PSOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code/ThorOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code');
cd(datapath);

filename0=dir(strcat('*.dat')); % count #tiles per slice
ntile=length(filename0);
nslice=2; % define total number of slices
create_dir(nslice, folder);
cd(datapath);
id=2;%str2num(id);
njobs=1;
section=ceil(ntile/njobs);
% the $SGE-TASK-ID environment variable read in is CHARACTER, need to transfer to number

istart=1;%(id-1)*section+1;
istop=istart;%section;

for islice=2
    cd(datapath);
    filename0=dir(strcat('*.dat')); 
    for iFile=istart:istop
        name=strsplit(filename0(iFile).name,'.');  
        name_dat=strsplit(name{1},'-');
        slice_index=islice;
%         coord=num2str(iFile);
        % Xrpt and Yrpt are x and y scan repetition, default = 1
        Zsize = str2num(name_dat{3}); Xrpt = 1; Xsize=str2num(name_dat{4}); Yrpt = 1; Ysize = str2num(name_dat{5});
        dim1=[Zsize Xrpt Xsize Yrpt Ysize];     % tile size for reflectivity 

        name1=strcat(num2str(islice),'-',num2str(9),'-',num2str(Zsize),'-',num2str(Xsize),'-',num2str(Ysize),'-AB.dat'); % gen file name for reflectivity

        ifilePath = [datapath,name1];
        amp= single(ReadDat_int16(ifilePath, dim1))./65535*2; 
        cross=amp(:,101:1200,1:1100);
        co=amp(:,101:1200,1101:2200);
        load(strcat(datapath,'curvature.mat'));
        curvature=round(curvature-min(curvature(:)));
        cross = FOV_curvature_correction(cross, curvature, size(cross,1), size(cross,2), size(cross,3));  
        co = FOV_curvature_correction(co, curvature, size(co,1), size(co,2), size(co,3)); 
%         ref=sqrt(cross.^2+co.^2);
%         message=strcat('Tile No. ',string(iFile),' is read.', datestr(now,'DD:HH:MM'),'\n');
%         fprintf(message);

        Optical_fitting_intralipids(co,cross,islice, iFile, folder);

    end
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

% rewrite_mub_tiles(folder,islice,numX*numY)
Mub_stitch_6692('mub', P2path,folder,disp,mosaic,pxlsize./10,islice,pattern,sys);
%     Ret_stitch('bfg', folder,disp,mosaic,pxlsize./4,islice,pattern,sys);
% rewrite_aip_tiles(folder,islice,numX*numY);
% Bfg_stitch_6692('bfg', P2path, folder,disp,mosaic,pxlsize./10,islice,pattern,sys)
R2_stitch_7694('R2', P2path, folder,disp,mosaic,pxlsize./10,islice,pattern,sys)
% MIP_stitch_6692('mip', P2path,folder,disp,mosaic,pxlsize,islice,pattern,sys)