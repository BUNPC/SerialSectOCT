%% OCTA, RR2AG
% input: RR(nz,nx,ny,nxRpt,nyRpt); data is obtained by repeating Bscan
function AG=RR2AG(RR, it0, ncorrect, z, K)
%% 1. phase cross correction
if nargin < 5
	K = ones(size(RR,1),size(RR,2));
end
if nargin < 4
	z = 1:size(RR,1);
end
if nargin < 3
	ncorrect = 3;
end
if nargin < 2
	it0 = 1;
end
RR=squeeze(RR);
% K should be > 0
K = max(K,eps);
% phase(zxzxz)
for nphasecorr = 1:ncorrect
    % phase(z)
    I1 = mean( RR(z,:,:,:) .* repmat(conj(RR(z,:,:,it0)) .* K(z,:).^2 ,[1 1 1 size(RR,4)]) ,1);
    I1 = I1 ./ abs(I1);
    RR = RR ./ repmat(I1,[size(RR,1) 1 1 1]);
    if nphasecorr == ncorrect
        break;
    end
    % phase(x)
    I1 = mean( RR .* repmat(conj(RR(:,:,:,it0)) .* K.^2 ,[1 1 1 size(RR,4)]) ,2);
    I1 = I1 ./ abs(I1);
    RR = RR ./ repmat(I1,[1 size(RR,2) 1 1]);
end
%% 2. Regular OCT angiogram
AG=abs((diff(RR,1,4)));