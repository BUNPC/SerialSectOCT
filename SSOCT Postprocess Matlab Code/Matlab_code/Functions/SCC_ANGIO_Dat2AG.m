%% OCTA,RR_complex
%% Angiogram OCT, Bscan repeated twice, data: nz_(nx*2)_ny
function SCC_ANGIO_Dat2AG(datapath, filename0,Proc_option, Dim, iFile)
%% add MATLAB functions' path
% addpath('D:\OCT Imaging\Data Process CODE\CODE-BU\Functions') % Path on JTOPTICS
addpath('/projectnb/npboctiv/s/Jianbo/CODE/OCT/CODE/BU-SCC/Functions') % Path on SCC server
% filePath information
ifilename=[filename0,num2str(iFile,'%d')];
ifilePath=[datapath,ifilename,'.dat'];
%% get data information
[Dim, fNameBase,fIndex]=GetNameInfoRaw(filename0);
nk = Dim.nk; nxRpt = Dim.nxRpt; nx=Dim.nx; nyRpt = Dim.nyRpt; ny = Dim.ny;
%% File numbers
z_seg=Proc_option(1:2);
LengthZ=z_seg(2)-z_seg(1)+1;
Nspec=1;%Proc_option(3);
intDk=Proc_option(4);
%% Angiogram calculation 
%%%%%%
nSubPixel=floor(nk/Nspec); % number of pixels for each sub spectrum

disp(['Start loading EXP data-', num2str(iFile), ', ',datestr(now,'DD:HH:MM')]);
[data_ori] = ReadDat_int16(ifilePath, Dim); % read raw data: nk_Nx_ny,Nx=nt*nx
disp(['Raw_Lamda data of EXP data-', num2str(iFile), ' Loaded. DAT2k ... ',datestr(now,'DD:HH:MM')]);
DAT_k=DAT2k(data_ori,intDk);
for ispec=1:Nspec % used for calculating multiple subspectrum, eg. Nspec=[1 2 3 4 8]. set to 1 if calculating only one Nsepc, eg. Nspec=4.
    disp(['Start processing ith spectrum-', num2str(ispec), ', #pix=',num2str(nSubPixel),', ',datestr(now,'DD-HH:MM:SS')]);
    DAT_k_ispec((ispec-1)*nSubPixel+1:ispec*nSubPixel,:,:)=DAT_k((ispec-1)*nSubPixel+1:ispec*nSubPixel,:,:);
    RR0 = ifft(DAT_k_ispec,[],1); % RR0(nz,nX,ny)
    disp(['RR', ', iSpectrum/Nspec=',num2str(ispec),'/',num2str(Nspec),' is calculated, ',datestr(now,'DD-HH:MM:SS')]);
    %% OCTA processing and averaging
    RR=permute(reshape(RR0(z_seg(1):z_seg(2),:,:),[LengthZ,nxRpt,nx,nyRpt,ny]),[1 3 5 2 4]); % RR(nz,nx,ny,nxRpt,nyRpt)
    AG=RR2AG(RR); % CPU-based
end
savename=['AG','-',num2str(iFile)];
% savenameInt=['RRzInt','-(',num2str(z_seg),')','-',num2str(iFile)];
save([datapath, savename, '.mat'],'-v7.3','AG')
% save([datapath, savenameInt, '.mat'],'Int')
disp(['Data saved, ', datestr(now,'DD:HH:MM')])

% figure;
% imagesc(log(squeeze(max(abs(Aavg),[],1)))); colormap(hot);colorbar
% figure;
% subplot(2,1,1);imagesc(x_coor,z_coor,(squeeze(max(abs(Aavg(:,115,:)),[],2)))); colormap(hot);colorbar
% subplot(2,1,2);imagesc(x_coor,z_coor,(squeeze(max(abs(Aavg(:,100:130,:)),[],2))));colormap(hot); colorbar
    