clear all;

%% ----------------------------------------- %%
% Note Jan 23:

% Current version of code does resampling, background extraction, 
% dispersion compensation, FFT and data stripping, MIP/AIP generation.

% Write to TIF images, stitching and blending was done in a seperate script.

% Will implement the surface finding function for data stripping soon.
% Current algorithm needs some further testing.

% Will also integrate write to TIF images, stitching and blending in the
% same script soon.

% - Jiarui Yang
%%%%%%%%%%%%%%%%%%%%%%%
%% set file path
datapath  = strcat('/projectnb2/npbssmic/ns/220207_P3/NIR_OCT/500um_tissue/');

% add subfunctions for the script
addpath('/projectnb/npbssmic/s/Matlab_code/ThorOCT_code');

% get the directory of all image tiles
cd(datapath);

%% get data information
%% change these parameters to appropriate values!
%[dim, fNameBase,fIndex]=GetNameInfoRaw(filename0(iFile).name);
nk = 2048; nxRpt = 1; nx=600; nyRpt = 2; ny = 600;
dim=[nk nxRpt nx nyRpt ny];

filename0=dir(strcat('RAW-*-2.dat'));

for i=1:length(filename0)
    ifilePath=[datapath,filename0(i).name];
    disp(['Start loading file ', datestr(now,'DD:HH:MM')]);
    [data_ori] = ReadDat_int16(ifilePath, dim); % read raw data: nk_Nx_ny,Nx=nt*nx
    disp(['Raw_Lamda data of file. ', ' Calculating RR ... ',datestr(now,'DD:HH:MM')]);
    data=Dat2RR(data_ori,-0.235);
    slice=abs(data(1:600,:,:));
end

% save as tiff

s=slice(:,1:2:end,:);

MAT2TIFF(s,strcat(datapath,'ref.tif'));

