clear all; close all; clc;
folder  = '/projectnb/npbssmic/ns/Ann_Mckee_samples_20T/Ann_NC3/';
P2path = '/projectnb/npbssmic/ns/Ann_Mckee_samples_20T/Ann_NC3_2P/';   % 2P file path
datapath=strcat(folder,'dist_corrected/'); 

% add subfunctions for the script. Change directory if not running on BU SCC
addpath('/projectnb/npbssmic/s/Matlab_code/fitting_code');
addpath('/projectnb/npbssmic/s/Matlab_code/PostProcessing');
addpath('/projectnb/npbssmic/s/Matlab_code/PSOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code/ThorOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code');
addpath(genpath('/projectnb2/npbssmic/s/Matlab_code/gpufit_Anna'));

cd(datapath);
ntile=270;
nslice=108; % define total number of slices
njobs=1;
section=ceil(ntile/njobs);

sys = 'PSOCT';
% specify mosaic parameters, you can get it from Imagej stitching
xx=866;    % xx is the X displacement of two adjacent tile align in the X direction
xy=0;     % xy is the Y displacement of two adjacent tile align in the X direction, default to 0
yy=866;    % yy is the Y displacement of two adjacent tile align in the Y direction
yx=0;      % xx is the X displacement of two adjacent tile align in the Y direction, default to 0
numX=11;    % #tiles in X direction
numY=9;    % #tiles in Y direction
Xoverlap=0.15;   % overlap in X direction
Yoverlap=0.15;   % overlap in Y direction
disp=[xx xy yy yx];
mosaic=[numX numY Xoverlap Yoverlap];
pattern = 'bidirectional';  % mosaic pattern, could be bidirectional or unidirectional
pxlsize=[1000 1000];

% the $SGE-TASK-ID environment variable read in is CHARACTER, need to transfer to number
id=1;%str2num(id);
istart=1;%(id-1)*section+1;
istop=section;

for islice=id
    cd(datapath); 
    filename0=dir(strcat(datapath, 'co-',num2str(islice),'-*.dat'));
    Optical_gpufit_all(filename0, istart, islice, datapath, folder, 0.019, 130, 80);
        %Optical_fitting(co, cross, islice, iFile, folder, 0.019, 130, 80);
%     rewrite_aip_tiles(folder,islice,numX*numY);
    %Bfg_stitch('bfg', P2path,folder,disp,mosaic,pxlsize./10,islice,pattern,sys);
%     MIP_stitch('mip', P2path,folder,disp,mosaic,pxlsize,islice,pattern,sys);
%     Ret_stitch('ret_aip', P2path,folder,disp,mosaic,pxlsize,islice,pattern,sys);  
%     AIP_stitch(P2path,folder,disp,mosaic,pxlsize,islice,pattern,sys);  
     Mus_stitch('mus',P2path,folder,disp,mosaic,pxlsize./10,islice,pattern,sys);           % stitch mus
     Mub_stitch('mub', P2path,folder,disp,mosaic,pxlsize./10,islice,pattern,sys);
%     BaSiC_shading_and_ref_stitch(islice,P2path,folder, 270, 65, 44); 
%     R2_stitch('R2', P2path, folder,disp,mosaic,pxlsize./10,islice,pattern,sys);
%     ZF_stitch('zf', P2path, folder,disp,mosaic,pxlsize./10,islice,pattern,sys);
%     ZR_stitch('zr', P2path, folder,disp,mosaic,pxlsize./10,islice,pattern,sys);
    message=strcat('slice No. ',string(islice),' is fitted and stitched.', datestr(now,'DD:HH:MM'),'\n');
    fprintf(message);
end


