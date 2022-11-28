% Convert raw spectrum data to k space
% it can be further used for split spectrum compounding

function DAT_k = DAT2k(DAT, intDk, bavgfrm)
% Dat: spectrum data, [nk, nx, ny]
% choose parameter for lamda-k interpolation
if nargin < 2
	intDk = -0.19;
    bavgfrm = 1;
end
if nargin < 3
	bavgfrm = 1;
end
% substract the reference signal, Subtract mean
[nk,Nx,ny] = size(DAT);
if bavgfrm == 1
    DAT = DAT - repmat(mean(DAT(:,:),2),[1 Nx ny]);
else
    DAT = DAT - repmat(mean(DAT(:,:,:),2),[1 Nx 1]);
end
%%%%
nz = round(nk/2);
%% transform from lamda to k, lamda-k interpolation, and ifft
if intDk ~= 0
    k = linspace(1-intDk/2, 1+intDk/2, nk);
    lam = 1./fliplr(k);
    %% lamda to k space
    DAT_k = interp1(lam, DAT, linspace(min(lam),max(lam),length(lam)), 'linear');
end
