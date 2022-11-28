%% capillary RBC velocity measurement, prDOCT, CPU calculation based
% Vz=w/(2*n*k0); k0=2*pi/Lambda0;
% Vz, high pass filter->move window std of imag(RR)->unwrap mask->phased resolved
% RR: [nz,nx,ny,nt]
% PRSinfo.fAline: data acquistion rate, Hz
% PRSinfo.Lam: light source [centerWavelength Bandwidth], m
% PRSinfo.HPknl: PRSinfo.HPknl=HP_filter_kernel(2.5*1e-3,1/PRSinfo.fAline); % FC=100HZ -> Omega=5*1e-3; FC=200HZ -> Omega=2.5*1e-3; FC=500HZ -> Omega=1*1e-3; 
% output: Vz, m/s
%%%%%%%%%%%%%%%%%%%%%%%%%% EXAMPLE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PRSinfo.fAline=76e3;  % Hz,
% PRSinfo.Lam=[1310 170]*1e-9;  % light source [centerWavelength Bandwidth], m
% PRSinfo.HPknl=HP_filter_kernel(2.5*1e-3,1/PRSinfo.fAline); % FC=100HZ -> Omega=5*1e-3; FC=200HZ -> Omega=2.5*1e-3; FC=500HZ -> Omega=1*1e-3; 
% [nz,nx,nyChk,nxRpt]=size(RR);
% Vz=RR2Vz(RR, PRSinfo);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Vz, aRBC]=RR2Vz(RR, PRSinfo)
%% OCT system parameter
dt=1/PRSinfo.fAline; % s
n=1.35; % optic refractive index
k0=2*pi/PRSinfo.Lam(1); 
[nz,nx,ny,nt]=size(RR);
RR2=reshape(RR,[nz*nx*ny,nt]);
HPknl=PRSinfo.HPknl;
%% Identify RBC using moving window std method
Length_MW=50; % moving window size;
for it=1:nt
    RRMWstd(:,it)=std(abs(RR2(:,it:min(it+Length_MW, nt))),1,2);
end
RR_norm_std=std(abs(RR2)./mean(abs(RR2),2),1,2);
RRMWstd_std=std(RRMWstd,1,2);
% %% 
RR_max=max(abs(RR2),[],2);
cRR=(RR_norm_std>0.3).*(RR_max>0.5).*(RRMWstd_std>0.08);
%% Vz calculation
RRHP=conv2(HPknl,1, RR2,'same');
RRUnwrap=movmean(unwrap(angle(RRHP),[],2),5,2);
ST=(RRUnwrap(:,end)-RRUnwrap(:,1))/nt*1/2; % Slope Threshold based on the difference of the last and fisrt unwraped phase
PS=diff(RRUnwrap,1,2); % Phase Difference of the slope
sRBC=bsxfun(@gt,PS.*sign(ST),ST.*sign(ST)*1.2); % slope greater than the slope threshold, identified as RBC flowing through
aRBC=sum(PS.*sRBC,2);
[ntRBC]=sum(sRBC,2);
w=reshape(aRBC./(ntRBC*dt).*cRR,[nz,nx,ny]);
Vz=w/(2*n*k0); % m/s
    
