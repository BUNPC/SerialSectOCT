% Convert raw spectrum data to Reflectivity, CPU-based
% input: 
    % DAT [Dim.nk,RptA_n_P*Dim.nx*Dim.nyRpt,Dim.ny], Nx=RptA_n_P*Dim.nx*Dim.nyRpt
    % intpDk: Lambda to k interpolation factor
% output:
    % RR: [nz,Nx,ny]
function RR = DAT2RR(Dat, intpDk, bavgfrm)
% Dat: spectrum data, [nk, nx, ny]
% choose parameter for lamda-k interpolation
if nargin < 2
	intpDk = -0.19;
end
if nargin < 3
	bavgfrm = 0;
end
% substract the reference signal, Subtract mean
[nk,Nx,ny] = size(Dat);
if bavgfrm == 1
    Dat = Dat - repmat(mean(Dat(:,:),2),[1 Nx ny]);
else
    Dat = Dat - repmat(mean(Dat(:,:,:),2),[1 Nx 1]);
end
%%%%
nz = round(nk/2);
%% transform from lamda to k, lamda-k interpolation, and ifft
k = linspace(1-intpDk/2, 1+intpDk/2, nk);
lam = 1./fliplr(k);
%% lamda to k space
data_k = interp1(lam, Dat, linspace(min(lam),max(lam),length(lam)), 'linear');
%% ifft
RR0 = ifft(data_k(:,:,:),[],1);
RR = RR0(1:nz,:,:);



