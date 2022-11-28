clear all; close all; clc;
folder='/projectnb/npbssmic/ns/210121_fiber_spectrum/';
addpath('/projectnb/npbssmic/s/Matlab_code/PostProcessing/');
addpath('/projectnb/npbssmic/s/Matlab_code/Spectral_Binning/');
cd(folder);
B_mag_files=dir('*depth1.dat');
num_files=length(B_mag_files);

xpix = 2500;
ypix = 1250;
numBins = 2;

x = 2500;
z = 2048;
y = 1250;


% in order to keep only center frequency use Gaussian windowing
% make your own Gaussian window with 1024 samples
tic
%for i = 1%:length(num_files)
    fileID = fopen(B_mag_files(1).name);
    data = uint16(fread(fileID,[z,x*y],'uint16'));
    data = reshape(data,z,x,y);
    xmin = 1200;
    xmax = 1600;
    ymin = 900;
    ymax = 1100;
    data = double(data(xmin:xmax,ymin:ymax));
    %Perform spectral binning
    %data = reshape(data,z,x,y);
    %OCT_IMG = Dat2RR(data, 2);
    OCT_IMG = Dat2RR(data, numBins);    
%end
toc
save('Spec_binned_data_linear.mat','OCT_IMG');

