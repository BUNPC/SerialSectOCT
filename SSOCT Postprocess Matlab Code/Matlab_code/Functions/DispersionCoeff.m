function [PhaseDC]=DispersionCoeff(data_ori, AutoCorrPeakCut)
% input: 1) Dat: spectrum after substracted by reference spectrum, 
%        2) AutoCorrPeakCut: remove the depth (z space) before DC plane (remove the top surface reflection of cover glass)
% OriginalBuffer is Jones which is already fft(FilteredBuffer)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get interpolated wavelengths
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\\
AlineLength = 1024;
OriginalLineLength1 = 1024;
Start1=1;
PaddingFactor=1;
PaddingLength = AlineLength*PaddingFactor;
InterpolationParameters = [PaddingLength,OriginalLineLength1,Start1];
[LamSpec0, LamSpecItp, Kitp]=OCTSpecPara;

[nk,Nx,ny]=size(data_ori);
Dat(:,:) = data_ori(:,:) - repmat(mean(data_ori(:,:),2),[1 Nx*ny]);

Dat_k (:,:)= interp1(LamSpec0(Start1:OriginalLineLength1-1+Start1,:), Dat(:,:), LamSpecItp(Start1:OriginalLineLength1-1+Start1,:),'linear','extrap');
RR = Buffer2Jones(Dat_k, PaddingFactor, AutoCorrPeakCut);

AlineLength = size(Kitp,1);
NumFiles = size(RR, 2); % should be 4, one for each position of the mirror
for ifile=1:NumFiles
    DepthProfile = abs(RR(:,ifile));
    PixMax(ifile) = find(DepthProfile == max(DepthProfile(1:50)));%((i-1)*100+1:end,:)));
%     PixMax(ifile) = find(DepthProfile == max(DepthProfile(DCsurf(1):DCsurf(1)+DCsurf(2))));%((i-1)*100+1:end,:)));
end

FFTNzeropadded=zeros(AlineLength,NumFiles);         % zeropad
for ifile=1:NumFiles                         % shift coherence function around 0
    L = 2*PixMax(ifile)-2;
    FFTNshift = zeros(L,1);
    FFTNshift(1:L/2+1) = RR(PixMax(ifile):PixMax(ifile)+L/2,ifile);
    FFTNshift(end-(L/2-1):end) = RR(PixMax(ifile)-L/2:PixMax(ifile)-1,ifile);
    FFTNzeropadded(1:L/2,ifile)=FFTNshift(1:L/2);
    FFTNzeropadded(end-(L/2-1):end,ifile)=FFTNshift(end-(L/2-1):end);
end

% figure,plot(abs(FFTNzeropadded));title('FFTNzeropadded');
clear FFTNshift
FFTNifft=ifft(FFTNzeropadded);                    % inverse fft
clear FFTNzeropadded
% figure,plot(abs(FFTNifft));title('FFTNifft');
FFTNangle=angle(FFTNifft);                        % determine phase
FFTNunwrapangle=unwrap(FFTNangle,[],1);           % unwrap
Phase = FFTNunwrapangle;
% for kk=1:size(PhaseT,2)
%     Phase(:,kk)=PhaseT(:,kk)-PhaseT(AlineLength/2,kk);
% end
numbercoef=9;
lock=AlineLength/2;
Kscut = Kitp(AlineLength/8:end-AlineLength/8);
x = Kitp-Kitp(lock);
Phasecut(:,1:NumFiles) = Phase(AlineLength/8:end-AlineLength/8, 1:NumFiles);
for ifile=1:NumFiles
    clear FitCoef
    FitCoef=polyfit((Kscut-Kitp(lock)),Phasecut(:,ifile),numbercoef); % fit polynomial fit
    y(:,ifile)=polyval(FitCoef,(Kscut-Kitp(lock)));
    FitToDispersion(:,ifile)=FitCoef(10)*x.^0+FitCoef(9)*x.^1+FitCoef(8)*x.^2+FitCoef(7)*x.^3+FitCoef(6)*x.^4+FitCoef(5)*x.^5+FitCoef(4)*x.^6+FitCoef(3)*x.^7+FitCoef(2)*x.^8+FitCoef(1)*x.^9;
    FitToDisp(:,ifile)=FitCoef(8)*x.^2+FitCoef(7)*x.^3+FitCoef(6)*x.^4+FitCoef(5)*x.^5+FitCoef(4)*x.^6+FitCoef(3)*x.^7+FitCoef(2)*x.^8+FitCoef(1)*x.^9;
    FitCoefM(:,ifile)=FitCoef;
end
PhaseDC = mean(exp(-1i.*FitToDisp),2);


% DispCurveBuff1 = FitToDisp;
% %%%%%%%%%%%%%%%%
% PhaseCorrection = exp(-1i.*FitToDisp);
% DispCompBuffer = Dat_k.* PhaseCorrection;
% %phase corrected coherence function
% Jones11 = Buffer2Jones(DispCompBuffer, PaddingFactor, AutoCorrPeakCut);
% CoherenceFunction1 = abs(Jones11);
% figure; plot([1:length(CoherenceFunction1)],CoherenceFunction1); grid on
