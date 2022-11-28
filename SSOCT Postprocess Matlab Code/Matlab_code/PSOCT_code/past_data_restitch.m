addpath('/projectnb/npbssmic/s/Matlab_code/fitting_code');
addpath('/projectnb/npbssmic/s/Matlab_code/PostProcessing');
addpath('/projectnb/npbssmic/s/Matlab_code/PSOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code/ThorOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code');
datapath  = '/projectnb2/npbssmic/ns/210310_PSOCT_4x4x2cm_BA44_45_milestone/';
nslice=147; % define total number of slice
njobs=10; % number of jobs per slice in SCC parallel processing, default to be 1
% specify OCT system name
sys = 'PSOCT';
% specify mosaic parameters, you can get it from Imagej stitching
%% xx yy is positive for dataset acquired after sep 06
xx=866;    % xx is the X displacement of two adjacent tile align in the X direction
xy=0;     % xy is the Y displacement of two adjacent tile align in the X direction, default to 0
yy=866;    % yy is the Y displacement of two adjacent tile align in the Y direction
yx=0;      % xx is the X displacement of two adjacent tile align in the Y direction, default to 0
numX=14;    % #tiles in X direction
numY=16;    % #tiles in Y direction
Xoverlap=0.15;   % overlap in X direction
Yoverlap=0.15;   % overlap in Y direction
disp=[xx xy yy yx];
mosaic=[numX numY Xoverlap Yoverlap];
pxlsize=[1000 1000];
pattern = 'bidirectional';  % mosaic pattern, could be bidirectional or unidirectional
id=str2num(id);   
section=ceil(nslice/njobs);
istart=(id-1)*section+1;
istop=(id)*section;
for islice=istart:istop
    islice
%     rewrite_aip_tiles(datapath,islice,numX*numY);
    AIP_restitch(datapath, datapath,disp,mosaic,pxlsize,islice,pattern,sys);
end