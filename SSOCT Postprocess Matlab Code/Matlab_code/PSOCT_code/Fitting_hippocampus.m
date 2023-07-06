datapath='/projectnb2/npbssmic/ns/Hui_Wang_samples/hippocampus/';

% add subfunctions for the script. Change directory if not running on BU SCC
addpath('/projectnb/npbssmic/s/Matlab_code/fitting_code');
addpath('/projectnb/npbssmic/s/Matlab_code/PostProcessing');
addpath('/projectnb/npbssmic/s/Matlab_code/PSOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code/ThorOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code');
cd(datapath);

filename0=dir(strcat('Jones_*.mat')); % count #tiles per slice
ntile=length(filename0);
nslice=1; % define total number of slices
create_dir(nslice, datapath);
cd(datapath);
njobs=1;
ds_factor=4;
section=ceil(ntile/njobs);
% the $SGE-TASK-ID environment variable read in is CHARACTER, need to transfer to number
istart=1;
istop=section;
load('sur.mat');
for islice=1
    cd(datapath);
    filename0=dir(strcat('Jones_*.mat')); 
    for iFile=istart:istop
        name=strsplit(filename0(iFile).name,'.');  
        name_dat=strsplit(name{1},'_');
        slice_index=islice;
        load(strcat(datapath,filename0(iFile).name));
%         IJones=IJones./sum;
        IJones=sqrt(IJones);
        message=strcat('Tile No. ',string(iFile),' is read.', datestr(now,'DD:HH:MM'),'\n');
        fprintf(message);
        IJones = FOV_curvature_correction(IJones, sur, size(IJones,1), size(IJones,2), size(IJones,3));  
        aip=single(squeeze(mean(IJones(51:150,:,:),1)));
        save(strcat(datapath,'aip/vol1/aip',num2str(iFile),'.mat'),'aip');
        tiffname=strcat(datapath,'aip/vol1/',num2str(iFile),'_aip','.tif');
        SaveTiff(aip,1,tiffname);
        
        Optical_fitting_finalized(IJones./3000, zeros(size(IJones)), islice, iFile, datapath,      0.1,       130,       100,     ds_factor, 54,    0);

    end
end

stitch=0;
sys = 'PSOCT';
% specify mosaic parameters, you can get it from Imagej stitching
xx=400;    % xx is the X displacement of two adjacent tile align in the X direction
xy=2;     % xy is the Y displacement of two adjacent tile align in the X direction, default to 0
yy=-400;    % yy is the Y displacement of two adjacent tile align in the Y direction
yx=2;      % xx is the X displacement of two adjacent tile align in the Y direction, default to 0
numX=10;    % #tiles in X direction
numY=10;    % #tiles in Y direction
Xoverlap=0.20;   % overlap in X direction
Yoverlap=0.20;   % overlap in Y direction
disp=[xx xy yy yx];
mosaic=[numX numY Xoverlap Yoverlap];
pattern = 'bidirectional';  % mosaic pattern, could be bidirectional or unidirectional
pxlsize=[512 512];
Mus_stitch('mus', '', datapath,disp,mosaic,pxlsize./ds_factor,islice,pattern,sys,ds_factor,stitch);          
Mub_stitch('mub', '', datapath,disp,mosaic,pxlsize./ds_factor,islice,pattern,sys,ds_factor,stitch);
% Bfg_stitch('bfg', '', datapath,disp,mosaic,pxlsize./ds_factor,islice,pattern,sys,ds_factor,stitch);
% BKG_stitch('BKG', '', datapath,disp,mosaic,pxlsize./ds_factor,islice,pattern,sys,ds_factor,stitch);
R2_stitch( 'R2',  '', datapath,disp,mosaic,pxlsize./ds_factor,islice,pattern,sys,ds_factor,stitch);
ZF_stitch( 'zf',  '', datapath,disp,mosaic,pxlsize./ds_factor,islice,pattern,sys,ds_factor,stitch);
ZR_stitch( 'zr',  '', datapath,disp,mosaic,pxlsize./ds_factor,islice,pattern,sys,ds_factor,stitch);
%     Ret_stitch('bfg', folder,disp,mosaic,pxlsize./4,islice,pattern,sys);
