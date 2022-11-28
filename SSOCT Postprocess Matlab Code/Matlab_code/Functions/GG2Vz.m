%% g1 based Vz calcualtion, CPU
% formula: 2pi/T=2n*2pi/Lambda*Vz => Vz=Lambda/(2nT), n is the optical refractive index
% input: 
    % GG, 2D array, (nVox,nTau), nVox=nz*nx*ny
    % PRSinfo: processing information
    % PRSinfo.FWHM: (transverse, axial), m
    % PRSinfo.fAline: DAQ Aline rate, Hz
    % PRSinfo.Lam: [light source center, wavelength bandwidth], m
    % PRSinfo.Dim: GG dimension: [nz,nx,ny,nTau]
    % nItp: resampling
% output: 
    % Vz, 1D, [nVox,1], m/s
%%%%%%%%%%%%%%% EXAMPLE %%%%%%%%%%%%%%%%%%%%%%
% PRSinfo.FWHM=[3.3 3.3]*1e-6; %(transverse, axial), m
% PRSinfo.fAline=46e3; % DAQ Aline rate, Hz
% PRSinfo.Lam=[1310 170]*1e-9; % [light source center, wavelength bandwidth], m
% PRSinfo.Dim=[100,400,10,25]; % [nz,nx,nyPchk,nTau]
% nItp=10;
% [Vz]=GG2Vz(GG, PRSinfo, nItp);  % m/s
function [Vz]=GG2Vz(GG, PRSinfo, nItp)
if nargin<3
    nItp=10;
end
n=1.35; % tissue refractivity 
rFrameItp=PRSinfo.fAline*nItp;
nz=PRSinfo.Dim(1); nx=PRSinfo.Dim(2); ny=PRSinfo.Dim(3); 
if nz*nx*ny>100*400*5
    if rem(ny,5)==0
        nyPchk=5;
    else
        nyPchk=1;
    end
    nyChk=ny/nyPchk;
else
    nyPchk=ny;
    nyChk=ny/nyPchk;
end
nVoxPchk=nz*nx*nyPchk;
%% I. resampling
[nVox,nTau]=size(GG); % nVox=nz*nx*ny
for iChk=1:nyChk
    iGG=(GG((iChk-1)*nVoxPchk+1:iChk*nVoxPchk,:));
    sTau=linspace(1,nTau,nTau).';
    rsTau=linspace(1,nTau,nTau*nItp).';
    GGI=movmean(interp1(sTau,imag(iGG).',rsTau,'linear'),10,1); %[nVox,nTau]
    CR=(max(abs(GGI(1:10*nItp,:)),[],1)>=0.06).*((abs(iGG(:,1))>0.3)).'; % threshold criteria
    ACF=aCorr(GGI,1);
    diffACF=(sign(diff(ACF,1,1))==1);
    [vACF,incsACF]=max(diffACF,[],1);
    HalfCyc=incsACF(1,:);
    HalfCyc(vACF==0)=nTau*nItp;
    Tvz=HalfCyc/rFrameItp*2; % period, s
    Vz((iChk-1)*nVoxPchk+1:iChk*nVoxPchk,1)=(((PRSinfo.Lam(1)./(2*n*Tvz).*sign(mean(GGI(1:3,:),1)).*CR).')); % absolute value of axial velocity, m/s
end
