clear all;

%% Add code to load your OCT data

filename=dir('ref-5-15-*.dat');
dim=[237 1 1000 1 1000];
slice=ReadDat_int16(filename(1).name,dim);
% I=double(permute(slice,[2 3 1]));
I=double(squeeze(slice(55,1:500,501:1000)));

%% Parameters from GGD fitting
a = 12.63;
b = 0.77;
e = 6.96;

%% Optimization or MM-despeckle parameters
% lambda  - regularization parameter (fixed), dont need a loop, can
% remove the loop, optional user input if someone wants to change
% lambda = 0.007 (not normalized)
% lam = [100 300 350 400 450 500 5000 6000:1000:10000 15000:5000:40000]; 
lambda = 0.3;

% gradient descent step size - might have to tweak this value to work for
% your data. step_size = 1 (not normalized)
step_size = 0.01:0.01:0.2;

%% MM-despeckle
ind = 0;

for ss = step_size
    
    ind = ind+1; % for regularization
    disp('Denoising begin');
    indv = 0;
  
    for nz = 1:size(I,3) % parfor might work , loop for slices
        % Optional normalization. You can use Imean = 1; I2 = I(nx,:,nv);
        % to remove normalization.
        % Code is faster with normalization as it has to work with lower
        % value numbers.    
        % Imean = mean(vect(I(:,:,nz)));
        Imean = 1;
        I2 = I(:,:,nz)/Imean; 
        
        tic
        tmp = denoise_Tikhonov_ggd_mm(I2, lambda,ss,I2,a,b,e,'off')'*Imean;
        I_den(:,:,nz,ind) = tmp;
        I_sc(ind) = std(tmp(:))/mean(tmp(:));
        toc
    end
    disp('Done');
end

%% Save I_den
I_den=squeeze(I_den);
%save('I_den.mat', 'I_den');
MAT2TIFF(I_den,'I_den2.tif');
