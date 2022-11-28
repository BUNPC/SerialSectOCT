%% DLS-OCT process, CPU-based
% input:  GG: [nVox,nTau], nVox=nz*nx*ny
% PRSinfo: processing information
% PRSinfo.FWHM: (transverse, axial), m
% PRSinfo.fAline: DAQ Aline rate, Hz
% PRSinfo.Lam: [light source center, wavelength bandwidth], m
% PRSinfo.Dim: GG orginal dimension: [nz,nx,ny,nTau]
% output:
    % Ms, Mf, R, [nz,nx,ny]
    % Vt, mm/s, [nz,nx,ny]
    % Vz, mm/s, [nz,nx,ny]
    % D, um^2/s, [nz,nx,ny]
    % GGf, GG fitting results, [nVox, nTau], nVox=nz*nx*ny
% subFunctions:
    % function [Vz]=GG2Vz(GG, PRSinfo, nItp)
        % function ACF = aCorr(DAT, dim)
    % function [Vt,Vz,D,R]=iniDLSOCT(GG, Vz0, Ms0, Mf0, PRSinfo)
%%%%%%%%%%%%%%% EXAMPLE %%%%%%%%%%%%%%%%%%%%%%
% PRSinfo.FWHM=[3.3 3.3]*1e-6; %(transverse, axial), m
% PRSinfo.fAline=46e3; % DAQ Aline rate, Hz
% PRSinfo.Lam=[1310 170]*1e-9; % [light source center, wavelength bandwidth], m
% PRSinfo.Dim=[100,400,10,25]; % [nz,nx,nyPchk,nTau]
% [Ms, Mf, Vt, Vz, D, R, GGf]=GG2VDR(GG, PRSinfo); 
function [Ms, Mf, Vt, Vz, D, R, GGf]=GG2VDR(GG, PRSinfo)
%% constant %%%%%%%%%%%%
Sigma=PRSinfo.FWHM*0.7/(2*sqrt(2*log(2))); % intensity-based sigma
Sigma2=2*Sigma;
dt = 1/PRSinfo.fAline;  
k0 = 2*pi/PRSinfo.Lam(1); % /m
% dk = ( 2*pi/(PRSinfo.Lam(1)-PRSinfo.Lam(2)/2)-2*pi/(PRSinfo.Lam(1)+PRSinfo.Lam(2)/2) )/2*sqrt(2*log(2));
n = 1.35;  q = 2*n*k0; 
[nVox,nTau]=size(GG);
nz=PRSinfo.Dim(1); nx=PRSinfo.Dim(2); ny=PRSinfo.Dim(3); 
tau = [1:nTau]*dt; % time lag, s
t = tau; tn = t / tau(end);
%% 1, determine the initial guess of vz0, Ms0, Me0, and Mf0
[vz0]=GG2Vz(GG, PRSinfo, 10); % m/s
% [vz0]=GG2Vz_GPU(GG2, PRSinfo, 10); % m/s
Ms0 = min(max(real(FindCOR(GG(:,ceil(end/2):end))),0),max(mean(real(GG(:,floor(end*2/3):end)),2),0));
Me0=1-abs(GG(:,1));
Mf0=max(1-Ms0-Me0,0);
CR=(Mf0>0.08);
[Vt0,Vz0,D0,R0]=iniDLSOCT(GG, vz0, Ms0, Mf0, PRSinfo);
% [Vt0,Vz0,D0,R0]=iniDLSOCT_GPU(GG2, vz0, Ms0, Mf0, PRSinfo);
%% 2. Fitting constraint
Fmin_cstrn(:,:,1)=[Ms0-0.1 Ms0+0.1];   % Ms constrain
Fmin_cstrn(:,:,2)=[max(Mf0-0.05, 0) min(Mf0+0.1,1-Ms0)];   % MfR constrain
Fmin_cstrn(:,:,3)=[0.5*Vt0 1.3*Vt0]*tau(end)/(Sigma2(1)); % Vt constrain
Fmin_cstrn(:,:,4)=sign(Vz0).*[0.8*abs(Vz0) 1.3*abs(Vz0)]*tau(end);  % Vz constrain
Fmin_cstrn(:,:,5)=[0.8*D0 min(D0*1.3,100*1e-12)]*q^2*tau(end); % D constrain
%% 3. non-linear least square fitting
fitC0(:,:,1) = double(Ms0); % initials
fitC0(:,:,2) = double(Mf0); % initials
fitC0(:,:,3) = double(Vt0*tau(end)/(Sigma2(1))); % initials
fitC0(:,:,4) = double(Vz0*tau(end)); % initials
fitC0(:,:,5) = double(D0*q^2*tau(end)); % initials
Tn=(tn);
Fmin_cstrn=double(Fmin_cstrn);
warning('off');
fit = @(c) sum( abs(c(:,1,1)+ c(:,1,2).*exp( -(c(:,1,3).*Tn).^2-(c(:,1,4).*Tn).^2/(Sigma2(2).^2) -c(:,1,5).*Tn ).*exp(1i*q*c(:,1,4).*Tn) - GG ).^2 ,2);
[fitC, fval] = fmincon(fit, fitC0, [],[],[],[], ...
    [Fmin_cstrn(:,1,1) Fmin_cstrn(:,1,2) Fmin_cstrn(:,1,3) Fmin_cstrn(:,1,4) Fmin_cstrn(:,1,5)], ...
    [Fmin_cstrn(:,2,1) Fmin_cstrn(:,2,2) Fmin_cstrn(:,2,3) Fmin_cstrn(:,2,4) Fmin_cstrn(:,2,5)], ...
    [], optimset('Display','off','TolFun',1e-6,'TolX',1e-6));%
Ms=reshape(fitC(:,1,1),[nz,nx,ny]); 
Mf=reshape(fitC(:,1,2),[nz,nx,ny]);  
Vt=reshape(fitC(:,1,3).*CR,[nz,nx,ny])/(tau(end)/(Sigma2(1)))*1e3; % mm/s
Vz=reshape(fitC(:,1,4).*CR,[nz,nx,ny])/tau(end)*1e3;  % mm/s
D=reshape(fitC(:,1,5).*CR,[nz,nx,ny])/(q^2*tau(end))*1e12; % um^2/s
GGf=fitC(:,:,1)+fitC(:,:,2).*exp( -(fitC(:,:,3).*Tn).^2-fitC(:,:,4).^2/(Sigma2(2).^2).*Tn.^2 -fitC(:,:,5).*Tn).*exp(1i*q*fitC(:,:,4).*Tn);
R=(reshape((1-sum(abs(GG-GGf).^2,2)./sum(abs((GG)-mean(GG,2)).^2,2)).*CR,[nz,nx,ny]));  
