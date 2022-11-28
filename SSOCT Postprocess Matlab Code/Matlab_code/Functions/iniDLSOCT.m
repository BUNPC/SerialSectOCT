%% DLSOCT initial guess of Vt0, D0, Vz0, CPU-based
% Input:
    % GG, 2D array, (nVox,nTau), nVox=nz*nx*ny
    % Vz0: 1D array, [nVox,1], initial value, m/s
    % Ms0: 1D array, [nVox,1], initial value for Ms
    % Mf0: 1D array, [nVox,1], initial value for Mf
    % PRSinfo: processing information
    % PRSinfo.FWHM: PSF (T, Z), m
    % PRSinfo.fAline: DAQ Aline rate, Hz
    % PRSinfo.Lam: [light source center, wavelength bandwidth], m
    % PRSinfo.Dim: GG dimension: [nz,nx,ny,nTau]
% Output: 
    % Vt: 1D array, [nVox,1], initial guess for Vt, in m/s
    % Vz: 1D array, [nVox,1], initial guess for Vz, in m/s
    % D: 1D array, [nVox,1], initial guess for D, m^2/s
    % R: 1D array, [nVox,1], fitting accuracy with initial guesses
% Jianbo Tang, 20190731
function [Vt,Vz,D,R]=iniDLSOCT(GG, Vz0, Ms0, Mf0, PRSinfo)
%% I. DAQ parameter
Sigma=PRSinfo.FWHM*0.7/(2*sqrt(2*log(2))); % intensity-based sigma, full width at the 1/e maximum value
Sigma2=2*Sigma;
k0 = 2*pi/PRSinfo.Lam(1);   % wave number, /m
n=1.35; % refractive index
q=2*n*k0;

[nVox,nTau]=size(GG); % nVox=nz*nx*ny
nz=PRSinfo.Dim(1); nx=PRSinfo.Dim(2); ny=PRSinfo.Dim(3); 
if nVox>100*400*5
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
CR=(abs(GG(:,1))>abs(GG(:,2))).*(abs(GG(:,1))>0.5); % threshold criteria
%% II. fit for a meshgrid of Vt and D
mVt=(zeros(nVoxPchk,11,nTau)); mVz=(zeros(nVoxPchk,5,nTau));
tau=[1:nTau]/PRSinfo.fAline; % time lag, s
for iChk=1:nyChk
    iVoxStart=(iChk-1)*nVoxPchk+1;
    iVoxEnd=iChk*nVoxPchk;
    StepD=5;  % um^2/s
    NmVt=11;
    mVt0=[0:NmVt-1]/(NmVt-1);
    [mVt,mVt00,~]=ndgrid(min(60./abs(Vz0(iVoxStart:iVoxEnd)*1e3),15)*1e-3.*Mf0(iVoxStart:iVoxEnd).^1.5,mVt0,tau);
    mVt=mVt.*mVt00;
    StepVt=mVt(:,2,1)-mVt(:,1,1);
    mD=[0:StepD:90]*1e-12; % m^2/s, diffusion coefficient
    NmD=length(mD); 
    [mVz, ~]=ndgrid(Vz0(iVoxStart:iVoxEnd),tau);
    [mMs, ~]=ndgrid(Ms0(iVoxStart:iVoxEnd),tau);
    [mMf, Tau]=ndgrid(Mf0(iVoxStart:iVoxEnd),tau);
    GGi=(single(zeros(nVoxPchk,nTau,NmVt,NmD)));
%     %% complex g1
%     for iVt=1:NmVt
%         for iD=1:NmD
%             GGi(:,:,iVt,iD)=mMs + mMf.*exp(-permute(mVt(:,iVt,:),[1,3,2]).^2.*Tau.^2/(Sigma2(1))^2-mVz.^2.*Tau.^2/(Sigma2(2))^2)...
%                 .*exp(-q^2*Tau.*mD(iD)).*exp(1i*q*mVz.*Tau);
%         end
%     end
%     RR=1 - (sum( abs(repmat((GG(iVoxStart:iVoxEnd,:)),[1,1,NmVt,NmD])-GGi).^2,2))...
%         ./ repmat(sum( abs((GG(iVoxStart:iVoxEnd,:))-mean((GG(iVoxStart:iVoxEnd,:)),2)).^2,2),[1,1,NmVt,NmD]);
    %% real part of g1 
    for iVt=1:NmVt
        for iD=1:NmD
            GGi(:,:,iVt,iD)=mMs + mMf.*exp(-permute(mVt(:,iVt,:),[1,3,2]).^2.*Tau.^2/(Sigma2(1))^2-mVz.^2.*Tau.^2/(Sigma2(2))^2)...
                .*exp(-q^2*Tau.*mD(iD)).*cos(q*mVz.*Tau);
        end
    end
    RR=1 - (sum( abs(repmat(real(GG(iVoxStart:iVoxEnd,:)),[1,1,NmVt,NmD])-GGi).^2,2))...
        ./ repmat(sum( abs(real(GG(iVoxStart:iVoxEnd,:))-mean(real(GG(iVoxStart:iVoxEnd,:)),2)).^2,2),[1,1,NmVt,NmD]); 
    
    RR=permute(RR,[1,3,4,2]);
    [mR0,RI]=max(RR(:,:),[],2);
    [MIvt, MId]=ind2sub([NmVt,NmD],RI);
    Vt(iVoxStart:iVoxEnd,1)=(mVt(:,1,1)+(MIvt-1).*StepVt); % m/s
    D(iVoxStart:iVoxEnd,1)=((MId-1)*StepD.*CR(iVoxStart:iVoxEnd))*1e-12; % m^2/s
    R(iVoxStart:iVoxEnd,1)=(mR0);
end
Vz=(Vz0);