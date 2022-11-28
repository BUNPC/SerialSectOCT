clear all; close all; clc;
folder='/projectnb/npbssmic/ns/210121_fiber_spectrum/';
addpath('/projectnb/npbssmic/s/Matlab_code/PostProcessing/');
addpath('/projectnb/npbssmic/s/Matlab_code/Spectral_Binning/');
cd(folder);
B_mag_files=dir('*depth4.dat');
num_files=length(B_mag_files);

xpix = 2500;
ypix = 1250;

x=2500;
z=2048;
y=1250;


% in order to keep only center frequency use Gaussian windowing
% make your own Gaussian window with 1024 samples
tic
%for i = 1%:length(num_files)
    fileID = fopen(B_mag_files(1).name);
    data = uint16(fread(fileID,[z,x*y],'uint16'));
    data = reshape(data,z,x,y);
%     xmin = 1200;
%     xmax = 1600;
%     ymin = 900;
%     ymax = 1100;
    xmin = 1200;
    xmax = 1600;
    ymin = 400;
    ymax = 800;
    xsize = xmax-xmin+1;
    ysize = ymax-ymin+1;
    data = double(data(:,xmin:xmax,ymin:ymax));
    data_linear = reshape(data,z, xsize*ysize);   
    %Perform spectral binning
    numBins = 32;%16;
    OCT_IMG = Dat2RR_linear(data_linear, numBins, xsize, ysize);    
%end
toc
%save('Spec_binned_data.mat','OCT_IMG');

% show images of each bin
% for nbin = 1:numBins
%     img = reshape(mean(OCT_IMG(:,:,:,nbin)),xsize, ysize);
%     figure1 = figure; imagesc(img);
%     title(strcat('bin = ',num2str(nbin)));
%     colormap gray;
%     size_name = strcat('_',num2str(xmin),':',num2str(xmax),'x',num2str(ymin),':',num2str(ymax));
%     fig_name = strcat('Results/',num2str(nbin),'_',num2str(numBins),size_name,'.png');
%     saveas(figure1,fig_name);
% end
%% Calculate reflectance vs wavelength
% reflectance = zeros(numBins, 8);
   % z_val = [25 33 41 49 57];
% for nbin = 1:numBins
%     for nz = 1:5
%         reflectance(nbin, nz) = mean(mean(OCT_IMG(z_val(nz),:,:,nbin)));
%     end
% end
% wn_min = 7168;
% wn_max = 7968;
% wn_dif = (wn_max - wn_min)/numBins;
% wavenum = wn_min + wn_dif/2:wn_dif:wn_max;
% figure;
% hold on;
% for nz = 1:5
%     plot(wavenum, reflectance(:,nz));
% end
% xlabel('Wavenumber, cm^{-1}')
% ylabel('Reflectance')
% legend('z = 25','z = 33', 'z = 41', 'z = 49', 'z = 57')
% hold off;

%% save as tiff
% 
% size_name = strcat('_',num2str(xmin),':',num2str(xmax),'x',num2str(ymin),':',num2str(ymax));
% 
% depth = 32;
% img_tiff = squeeze(OCT_IMG(depth,:,:,:));
% tiffname=strcat('Results/',num2str(depth),size_name,'.tif');
% save_tiff(img_tiff, tiffname);
% 
% depth = 16;
% img_tiff = squeeze(OCT_IMG(depth,:,:,:));
% tiffname=strcat('Results/',num2str(depth),size_name,'.tif');
% save_tiff(img_tiff, tiffname);
% 
% %img_tiff = squeeze(max(OCT_IMG));
% 
% function save_tiff(img_tiff, tiffname)
%     s=uint16(65535*mat2gray(img_tiff)); 
% 
%     for i=1:size(s,3)
%         t = Tiff(tiffname,'a');
%         image=squeeze(s(:,:,i));
%         tagstruct.ImageLength     = size(image,1);
%         tagstruct.ImageWidth      = size(image,2);
%         tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
%         tagstruct.BitsPerSample   = 16;
%         tagstruct.SamplesPerPixel = 1;
%         tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
%         tagstruct.Compression = Tiff.Compression.None;
%         tagstruct.Software        = 'MATLAB';
%         t.setTag(tagstruct);
%         t.write(image);
%         t.close();
%     end
% end

%% find spectral slope image
reflectance = squeeze(max(OCT_IMG));
wn_min = 7168;
wn_max = 7968;
wn_dif = (wn_max - wn_min)/numBins;
wavenum = wn_min + wn_dif/2:wn_dif:wn_max;
ss = zeros(size(reflectance,1), size(reflectance,2));
for bin_end = 29
    bin_start = 1;
    wv_end = wavenum(bin_end);
    wv_start = wavenum(bin_start);
    wv_dif = (wv_end - wv_start);
    spectral_slope = reflectance(:,:,bin_end)-reflectance(:,:,bin_start);
    ss = ss + spectral_slope;
end
ss_total = ss/(30-11);
figure1 = figure; imagesc(ss_total);
title(strcat('Spectral slope for',32,num2str(wv_start),'-', num2str(wv_end),'cm^{-1}'));
colormap gray;
% size_name = strcat('_',num2str(xmin),':',num2str(xmax),'x',num2str(ymin),':',num2str(ymax));
% fig_name = strcat('Results/',num2str(nbin),'_',num2str(numBins),size_name,'.png');
% saveas(figure1,fig_name);

%% show images at certain depth
depth = 32;
img = squeeze(OCT_IMG(depth,:,:,:));
img_new = max(img,[],3);
figure2 = figure;
imagesc(img_new); colormap gray;
saveas(figure2, 'img_32.png')

depth = 1;
img = squeeze(OCT_IMG(depth,:,:,:));
img_new = max(img,[],3);
figure2 = figure;
imagesc(img_new); colormap gray;
saveas(figure2, 'img_1.png')

depth = 32/2;
img = squeeze(OCT_IMG(depth,:,:,:));
img_new = max(img,[],3);
figure3 = figure;
imagesc(img_new); colormap gray;
saveas(figure3, 'img_16.png')

img = squeeze(max(OCT_IMG));
img_new = max(img,[],3);
figure4 = figure;
imagesc(img_new); colormap gray;
saveas(figure4, 'img_max.png')
