%% g1 is calculated with same data length PRSinfo.g1_nt
% calculate 3D g1, return [nz,nx,ny,nTau]
% input:
    % RR: [nz, nx, ny, nxRpt]
    % PRSinfo.g1_Start: start time for g1 calculation
    % PRSinfo.g1_nt: number of time poiPRSinfo.g1_nts for g1 calculation
    % PRSinfo.g1_ntau: number of g1 time lag
% output:
    % GG: [nz, nx, ny, nTau]
function GG = RR2g1(RR, PRSinfo)
[nz, nx, ny, nxRpt] = size(RR) ;
if PRSinfo.g1_nt>nxRpt-PRSinfo.g1_ntau
    PRSinfo.g1_nt=nxRpt-PRSinfo.g1_ntau;
    disp(['Warning: PRSinfo.g1_nt is larger than nxRpt-PRSinfo.g1_ntau, and is modified to be nxRpt-PRSinfo.g1_ntau=',num2str(PRSinfo.g1_nt),'!']);
end
%%%% g1 = mean((yi*)*(y(i+tau))/mean(yi**yi);
temp_deno=zeros(nz,nx,ny,PRSinfo.g1_nt);
Numer=zeros(nz,nx,ny,PRSinfo.g1_ntau);
temp_deno(:,:,:,:)=(conj(RR(:,:,:,PRSinfo.g1_Start:PRSinfo.g1_Start-1+PRSinfo.g1_nt))).*(RR(:,:,:,PRSinfo.g1_Start:PRSinfo.g1_Start-1+PRSinfo.g1_nt));
for itau = 1:PRSinfo.g1_ntau
    temp_numer(:,:,:,itau,:)=(conj(RR(:,:,:,PRSinfo.g1_Start:PRSinfo.g1_Start-1+PRSinfo.g1_nt))).*(RR(:,:,:,itau+PRSinfo.g1_Start:itau+PRSinfo.g1_Start-1+PRSinfo.g1_nt));
end
Denom=repmat(mean(temp_deno,4),[1,1,1,PRSinfo.g1_ntau]); % calculate the denomenator
Numer=(mean(temp_numer,5));
GG = Numer./Denom;

