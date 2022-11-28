%% process data_k with specified process option, return GG,RR
% data_k, ikfile, nk_Nx_nyseg
% XYTTauDim, resize dimention, Num_Aline,Num_Bscan,Num_T, ntau

% function [GG, RR_A]=DLSOCT_k2RRGG(data_k,XYTTauDim,Proc_option)
function [GG, RRsave, Angio_spk,prVz, g1Vz, RRstd]=DLSOCT_k2RRGG(data_k,XYTTauDim,Proc_option)
%% data size
[nk,Nx,ny]=size(data_k);
Num_Aline = XYTTauDim(1); Num_Bscan = XYTTauDim(2); NyRpt=XYTTauDim(3);  NxRpt=XYTTauDim(4); ACF_Start=XYTTauDim(5); ACF_nt=XYTTauDim(6); ACF_nTau=XYTTauDim(7); 

%%% Ascans between adjacent Alines 
Gap_1stA=floor((Nx-NxRpt)/Num_Aline);
%%%%%
MW_AVG=Proc_option(1);         % set value to 1 to average along x
Lowpassfilt=Proc_option(2);    % set value to 1 to filter RR_ori along x
Image_shift=Proc_option(3);    % set value to 1 to shift-cali RR_reshape along nt; 
OVERLAP_Ascan=Proc_option(4);  % set value to 1 to overlap Alines when 
GG_Neib_AVG=Proc_option(5);    % set value to 1 to 3x3x3 averaging GG.
trunc_z=Proc_option(6);        % set value to 1 to specify num of nz
z_seg0=Proc_option(7);
LengthZ=Proc_option(8);
NeibNorm=Proc_option(9);
DC=Proc_option(10); % Dispersion compensation
RRHPF=Proc_option(11); % high pass filtering?
SaveAll=Proc_option(12);
Nspk_angio=Proc_option(13);
RptBscan=Proc_option(14);
intDk=Proc_option(15);
fDAQ=Proc_option(16); % Aline rate, kHz
z_seg=[z_seg0+1,z_seg0+LengthZ];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% OMAG angiography
% n_OMAG_rpt=20;
% for iy=1:ny
%     for iyRpt=1:NyRpt
%         for iA=1:Num_Aline
%             Datak_reshape(:,iA,(iy-1)*NyRpt+iyRpt,1:NxRpt)=squeeze((data_k(:,1+(iyRpt-1)*Num_Aline*NxRpt+NxRpt*(iA-1):(iyRpt-1)*Num_Aline*NxRpt+NxRpt*iA,iy))); % RR: (z_seg)_nx_ny_nt
%         end
%     end
% end
% if ProcAngioOMAG==1
%     for irpt=1:n_OMAG_rpt
%         data_k_diff=Datak_reshape(:,:,:,irpt)-Datak_reshape(:,:,:,NxRpt-n_OMAG_rpt+irpt);
%         Angio_OMAGi(:,:,:,irpt)=(ifft(data_k_diff));
%     end
%     if trunc_z==1
%         Angio_OMAG=squeeze(mean(Angio_OMAGi(z_seg(1):z_seg(2),:,:,:),4));
%     else
%         Angio_OMAG=squeeze(mean(Angio_OMAGi,4));
%     end
% end
%% 
clear RR_ori RR GG
disp(['ifft... ',datestr(now,'DD:HH:MM')]);
nz = round(nk/2);
RR_original = zeros(nz,Nx,ny,'single');
RR0 = ifft(data_k(:,:,:),[],1);
RR_original(:,:,:) = RR0(1:nz,:,:);
%%  truncate %%%%%%
if trunc_z==1
    RR_ori=RR_original(z_seg(1):z_seg(2),:,:);
else
    RR_ori=RR_original;
end
[nzroi, Nx, ny]=size(RR_ori);
num_AscanPBscan=Nx; % Num of Ascans in x_length
clear RR_original
disp(['RR_Ori calculated ',datestr(now,'DD:HH:MM')])
%% Neib normalization %%%%
if NeibNorm==1
    NbNorm=15;
    for x = 1:5
        for y=1:5
            radiusSquared = (x-3).^2 + (y-3).^2 ;
            Gaus_2D(x, y) = 1*exp(-radiusSquared/1.6);
        end
    end
    
    for iz=1:nzroi
        RRiz=squeeze((RR_ori(iz,:,:)));
        %             Img=abs(squeeze(RR(iz,:,:)));
        RRiz=conv2(RRiz, Gaus_2D,'same')/sum(Gaus_2D(:));
        for ix=1:Nx
            for iy=1:ny
                ixx=max(1,ix-NbNorm):3:min(Nx,ix+NbNorm-1);
                iyy=max(1,iy-NbNorm):3:min(ny,iy+NbNorm-1);
                temp=sort(max(RRiz([ixx],[iyy])),'descend');
                RRnorm(ix,iy)=RRiz(ix,iy)/mean(temp(1:round(end/3)));
            end
        end
        %     RRnorm=conv2(RRnorm, Gaus_2D,'same')/sum(Gaus_2D(:));
        RR_ori(iz,:,:)=RRnorm;
    end
    disp(['RR_NeibNorm calculated ',datestr(now,'DD:HH:MM')])
end

%% Optional, process RR_ori %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if MW_AVG==1
    %%%% average RR_ori along x, moving window averaging
    disp(['Moving Window averaging... ',datestr(now,'DD:HH:MM')])
    MWAVG_Core=zeros(7,7);
    MWAVG_Core(4,:)=1;
    for iy=1:ny
        RR_MWAVG(:,:,iy)=conv2(RR_ori(:,:,iy),MWAVG_Core,'same')/7;
    end
    RR_calcu=RR_MWAVG;
    clear RR_MWAVG
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if Lowpassfilt==1
    %% filter RR_ori along X, lowpass filter
    %%%% OPtioinal, lowpass filter parameter %%%%%%%%%%%%%%%%%%%
    x_length=200; %units um
    nfilt=50;  Fstop=100;% set lowpass filter parameter

    disp(['Lowpass filtering... ',datestr(now,'DD:HH:MM')])
    Fs=num_AscanPBscan/x_length*1e6; % Spatial frequency, SamplingPoints/m
    Ld=designfilt('lowpassfir','FilterOrder',nfilt, 'CutoffFrequency',Fstop,'SampleRate', Fs);
    for iz=1:nz
        for iy=1:ny
            RR_filt(iz,:,iy)=filter(Ld, squeeze(RR_ori(iz,:,iy)));
        end
    end
    % grpdelay(Ld,num_Ascan,Fs);
    delay=mean(grpdelay(Ld));
    RR_filt=circshift(RR_filt,-delay,2);
    RR_calcu=RR_filt;
    clear RR_filt
else
    RR_calcu=RR_ori;
    %     clear RR_ori
end
%% reshaping RR_ori %%%%%%%%%%%%
disp(['Start reshaping RR_ori... ',datestr(now,'DD:HH:MM')])
if OVERLAP_Ascan==1 % Reshape RR_ori, Alines OVERLAPED, nt=100, nt!=NX/nx %%%%%%%%%%%
    for iy=1:ny
        for iA=1:Num_Aline
            RR_reshape(:,iA,iy,1:NxRpt)=squeeze((RR_calcu(:,Gap_1stA*(iA-1)+1:Gap_1stA*(iA-1)+NxRpt,iy))); % RR: (z_seg)_nx_ny_100
        end
    end
else  % Reshape RR_ori, NO ALine overlaped, nt=NX/nx %%%%%%%%
    RR_reshape=permute(reshape(RR_calcu(:,:,:),[nzroi,NxRpt,Num_Aline,1,ny]),[1 3 5 2 4]); % reshape RR from [nz,Nx,ny] to [nz,nx,ny,nxRpt,nyRpt], Nx=nx*nxRpt
%     for iy=1:ny
%         
%         for iyRpt=1:NyRpt
%             for iA=1:Num_Aline
%                 RR_reshape(:,iA,(iy-1)*NyRpt+iyRpt,1:NxRpt)=squeeze((RR_calcu(:,1+(iyRpt-1)*Num_Aline*NxRpt+NxRpt*(iA-1):(iyRpt-1)*Num_Aline*NxRpt+NxRpt*iA,iy))); % RR: (z_seg)_nx_ny_nt
%             end
%         end
%     end
end
disp(['Finished reshaping RR_ori: ',datestr(now,'DD:HH:MM')])
%% image shift calibration ? %%%%%%%%%%%%%%
if Image_shift==1
    %%% shift RR_reshape
    disp(['Start calibrating image shifting... ',datestr(now,'DD:HH:MM')])
    RR=RR_shift_cali(RR_reshape); % image shift calibrated
    disp(['Finished calibrating image shifting: ',datestr(now,'DD:HH:MM')]);
else
    RR=RR_reshape;   % for comparison
    
end
clear RR_reshape
[nz,nx,ny,nt]=size(RR);
%% saving
if SaveAll==1
    RRsave=RR;
    %% SPK ANGIO
    % n_spk=3; % number of data for speckle variance analysis
    n_spk_rpt=floor(nt/Nspk_angio); % repeatition averaging
    Angio_spk0=zeros(nz,nx,ny,n_spk_rpt);
    for i_spk_rpt=1:n_spk_rpt
        RR_i_spk_rpt=RR(:,:,:,i_spk_rpt:n_spk_rpt:end);
        [nz,nx,ny,nirpt]=size(RR_i_spk_rpt);
        Angio_spk0(:,:,:,i_spk_rpt)=(squeeze(std(RR_i_spk_rpt.^2./repmat(mean(RR_i_spk_rpt.^2,4),[1,1,1,nirpt]),1,4))).^2;
    end
    Angio_spk=squeeze(mean(Angio_spk0,4));
    %% RRstd
    RRstd=std(abs((RR./repmat(max(RR,[],4),[1,1,1,nt]))),1,4);
else
    RRsave=0;
    Angio_spk=0;
    RRstd=0;
end
% else
%     RRsave(:,1:Num_Aline,:,1)=squeeze(mean(RR(:,:,:,1:floor(NxRpt/2)),4));
%     RRsave(:,1:Num_Aline,:,2)=squeeze(mean(RR(:,:,:,floor(NxRpt/2)+1:end),4));
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% calculate the field autocorrelation function, g1
disp(['Calculating Field ACF, GG... ',datestr(now,'DD:HH:MM')])
if RRHPF==1
    [HPknl]=HP_filter_kernel(2.5*1e-3,21.7*1e-6); % FC=100HZ -> Omega=5*1e-3; FC=200HZ -> Omega=2.5*1e-3; FC=500HZ -> Omega=1*1e-3; 
    [nz,nx,ny,nt]=size(RR);
    RR2=reshape(RR,[nz*nx*ny,nt]);
    RR=reshape(conv2(HPknl,1, RR2,'same'),[nz,nx,ny,nt]);
end
%% 
PRSinfo.g1_Start=ACF_Start;       % start time for g1 calculation
PRSinfo.g1_nt=ACF_nt;       % number of time points for g1 calculation
PRSinfo.g1_ntau=ACF_nTau;
PRSinfo.fAline=fDAQ*1e3; % DAQ Aline rate, Hz
PRSinfo.Lam=[1310 170]*1e-9; % [light source center, wavelength bandwidth], m
GG=RR2g1(RR,PRSinfo); % nz_seg*nx*ny*ntau
%% RR to Vz
PRSinfo.HPknl=HP_filter_kernel(2.5*1e-3,1/PRSinfo.fAline);
prVz=RR2Vz(RR, PRSinfo)*1e3; %mm/s
%% g1 to Vz
CovK=ones(3,3)/9;
for it=1:ACF_nTau
    for iy=1:ny
        GG0(:,:,iy,it)=convn(GG(:,:,iy,it),CovK,'same');
    end
end
PRSinfo.Dim=size(GG0);
g1Vz0=GG2Vz(reshape(GG0, [nz*nx*ny,ACF_nTau]),PRSinfo,10)*1e3; % mm/s
g1Vz=reshape(g1Vz0,[nz,nx,ny]);

% for iz=1:nz
%     for ix=1:nx
%         for iy=1:ny
%             gg=squeeze(GG0(iz,ix,iy,:));
%             g1Vz(iz,ix,iy)=gg2Vz(gg,PRSinfo,20)*1e3; % mm/s
%             rr=squeeze(RR(iz,ix,iy,:));
%             prVz(iz,ix,iy)=rr2Vz(rr,PRSinfo)*1e3; % mm/s
%         end
%     end
% end
% clear RR
clear GG_ori
disp(['Finished calculating Field ACF, GG',datestr(now,'DD:HH:MM')])
