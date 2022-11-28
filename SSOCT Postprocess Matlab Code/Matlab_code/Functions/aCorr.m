%% autocorrelation calculation, CPU
% DAT: 2D matrix
% dim: specify which dimension to perform autocorrelation 
function ACF = aCorr(DAT, dim)
if dim==2
    DAT=DAT.';
end
[nt, nD] = size(DAT) ;
Deno=sum((conj(DAT(:,:)).*(DAT(:,:))),1);
for itau = 1:nt
    Numer(itau,:)=sum((conj(DAT(1:nt-itau,:))).*(DAT(itau:nt-1,:)),1);
end
ACF = Numer./Deno;
