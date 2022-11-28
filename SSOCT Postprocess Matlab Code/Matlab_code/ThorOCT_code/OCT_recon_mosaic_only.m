sys='Thorlabs';

% displacement parameters
xx=199;
xy=-4;
yy=197;
yx=10;
disp=[xx xy yy yx];
% mosaic parameters
numX=48;
numY=39;
Xoverlap=0.5;
Yoverlap=0.5;
mosaic=[numX numY Xoverlap Yoverlap];    
% pxlsize=[size(slice,2) size(slice,3)];
pattern = 'unidirectional';
    
datapath  = strcat('/projectnb/npbssmic/ns/200617_Thorlabs/');
addpath('/projectnb/npbssmic/s/Matlab_code');

cd(datapath);

pxlsize=[400 400];

Mosaic(datapath,disp,mosaic,pxlsize,1,pattern,sys);
