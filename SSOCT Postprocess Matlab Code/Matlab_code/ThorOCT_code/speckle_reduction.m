function I_out = speckle_reduction(I_in, lambda, step_size, a, b, e)
% speckle reduction based on Divya's code
%   I_in: input image stack
%   lambda: regularization parameter
%   step_size: step size for regularization
%   a,b,c : generalized gamma distribution parameter

% use default gamma distribution if not specified
    if nargin < 2
        lambda = 0.3;
        step_size = 0.1;
        a = 12.63;
        b = 0.77;
        e = 6.96;
    elseif nargin < 6
        a = 12.63;
        b = 0.77;
        e = 6.96;
    end
    I_out=zeros(size(I_in));
    for i=1:size(I_in,1)
        tmp = squeeze(I_in(i,:,:));
        tmp_ds = denoise_Tikhonov_ggd_mm(tmp, lambda, step_size, tmp, a, b, e, 'off');
        I_out(i,:,:) = tmp_ds;
    end
    disp('Speckle Reduction is Done');
end

