%% denoise_Tikhonov_gamma_mm
%% Author: Divya Varadarajan
% This function removes OCT speckle using a majorize-minimize based optimization framework.
%% Inputs
% y_vol : Noisy OCT data
% lambda :  regularization parameter
% step size : optimization step size
% y0 :  flag to choose initialization. (not supported yet) -
%                 default uses noisy image as initialization

%% Outputs:
% mm_denoised_data : Denoised MRI data

%%
function [mm_denoised_data] = denoise_Tikhonov_ggd_mm(y_vol, lambda,step_size, y0,a,b,e,dispIter)
% volume size
N1=size(y_vol,1);
N2 = size(y_vol,2);
if nargin <3
    options.step_size = 1;
else
    options.step_size = step_size;
end
if nargin < 8
    options.Display = 'off'; % 'iter'; %
else
    options.Display = dispIter;
end

options.GradObj = 'on';
options.MaxFunEvals = 20; %20 % SPIE 10
options.TolX = 1e-10; %1e-6;
options.TolFun = 1e-20; %1e-6;
options.step_size_scale_iter = 0.4; % 0.7

[D,Dp]  = createDNoBoundary(N1,N2); %createDWithPeriodicBoundary
Dp_l = lambda(:).*Dp;

Nslice = size(y_vol,3);
for nz = 1:Nslice,
    y = vect(double(y_vol(:,:,nz)));
    xo = y*0;
    if nargin<4,       
        xnew = y;
    else
        xnew = y0;        
    end
    
    iter = 0;
    while (norm(xo(:)-xnew(:))/norm(xnew(:)) > 1e-6 && iter<20)
        iter = iter+1;
        xo = xnew;
        [xnew] = gradient_descent_ggd(@mm_ggd_tikhonov_func, y, xo, D,Dp_l,a,b,e, options);
    end
    xnew(isnan(xnew)) = 0;
    mm_denoised_data(:,:,nz) = reshape(abs(xnew),[N1,N2]);
end

end
