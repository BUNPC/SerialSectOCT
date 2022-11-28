%% combine phase resolved Vz
function Combine_prVzNg1OCTA(filename0,datapath0, Start_file,N_file)

filename=filename0(1:7);
[Vcmap, Vzcmap, Dcmap, Mfcmap, Rcmap]=Colormaps_DLSOCT;
if datapath0(end-3) =='-'
    fileindex=str2num(datapath0(end-2:end-1));
    path_base=datapath0(1:end-3);
else
    fileindex=str2num(datapath0(end-1));
    path_base=datapath0(1:end-2);
end
fileInfo=strsplit(filename0,'-');

N_kfile=str2num(fileInfo{2});
pathparts=strsplit(datapath0,'/');
filefolder=pathparts{end-1};

Num_pixel=str2num(filefolder(1:4));
nz=str2num(filefolder(6:8)); 
nx=str2num(filefolder(10:12)); % total number of ALines per Bscan
ny0=str2num(filefolder(14:16)); 
nT=str2num(filefolder(18:20));
ntau=str2num(filefolder(23:24));

% N_spctrm=floor(2048/Num_pixel);
N_spctrm=1;
ny_seg=ny0/N_kfile;
%%% calculated parts information %%%%%%%%
N_subGG=ny0/5;
prompt={'Number of iVzfile (Dat2GG)', 'Number of Bscan per Y segment','Vz nz','Vz nx','Vz ny'};
infoParts=inputdlg(prompt,'Parts infor', 1,{num2str(N_kfile),num2str(ny_seg),num2str(nz),num2str(nx),num2str(ny0)});

N_kfile=str2num(infoParts{1});  % number of Y segments
Ny_Per_seg=str2num(infoParts{2}); % number of Bscan per Y segments
nz=str2num(infoParts{3});  % number of Z depth
nx=str2num(infoParts{4});  % number of Aline
ny0=str2num(infoParts{5});  % number of Bscan

for ifile=1:N_file
    idatapath=[path_base,num2str(ifile+Start_file-1),'/'];
    for ispctrm=1:N_spctrm
        disp(['Loading and combining ', num2str(ifile+Start_file-1), ', ispctrm=', num2str(ispctrm),', ', datestr(now,'DD:HH:MM')])
        
        for ikfile=1:N_kfile
            iprVzname=['prVz',num2str(ispctrm),'-',num2str(N_kfile,'%02d'),'-',num2str(ikfile)];
%             ig1Vzname=['g1Vz',num2str(ispctrm),'-',num2str(N_kfile,'%02d'),'-',num2str(ikfile)];
            ig1AGname=['g1AG',num2str(ispctrm),'-',num2str(N_kfile,'%02d'),'-',num2str(ikfile)];
%             iVrbcname=['Vrbc',num2str(ispctrm),'-',num2str(N_kfile,'%02d'),'-',num2str(ikfile)];
            
            if exist([idatapath, iprVzname, '.mat'])==0
                disp(['skiped ',num2str(ikfile), '.mat'])
            else
                disp(['Combining.. ', num2str(ikfile),', ',datestr(now,'DD:HH:MM')])
                prVz(:,:,(ikfile-1)*Ny_Per_seg+1:ikfile*Ny_Per_seg)= LoadMAT(idatapath,iprVzname);
%                 g1Vz(:,:,(ikfile-1)*Ny_Per_seg+1:ikfile*Ny_Per_seg)= LoadMAT(idatapath,ig1Vzname);
                g1AG(:,:,(ikfile-1)*Ny_Per_seg+1:ikfile*Ny_Per_seg,:)= LoadMAT(idatapath,ig1AGname);
%                 Vrbc(:,:,(ikfile-1)*Ny_Per_seg+1:ikfile*Ny_Per_seg)= LoadMAT(idatapath,iVrbcname);
                
            end
        end
       
        %% SAVE RESULTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        savepath=[idatapath, '/'];
        nameprVz=['prVz']; %
%         nameg1Vz=['g1Vz']; %
        nameg1AG=['g1AG']; %
%         nameVrbc=['Vrbc']; %
        disp(['Saving Vz&g1AG... ', datestr(now,'DD:HH:MM')])
        save([savepath,nameprVz, '.mat'],'prVz','-v7.3')
%         save([savepath,nameg1Vz, '.mat'],'g1Vz','-v7.3')
        save([savepath,nameg1AG, '.mat'],'g1AG','-v7.3')
%         disp(['Saving Vrbc... ', datestr(now,'DD:HH:MM')])
%         save([savepath,nameVrbc, '.mat'],'Vrbc','-v7.3')
        disp(['Data saved', datestr(now,'DD:HH:MM')])

    end
    disp(['Finished Vz&g1AG combination,', datestr(now,'DD:HH:MM')]);
    disp(savepath);
end
Vz3Dpr=imgaussfilt3(prVz,0.5);   
figure;
imagesc(squeeze(max(abs(Vz3Dpr(:,:,:)),[],1)).*sign(squeeze(mean(Vz3Dpr(:,:,:),1)))); 
colormap(Vzcmap); caxis([-2 2]); colorbar
title('prVz')
axis equal; axis tight;

% Vz3Dg1=imgaussfilt3(g1Vz,0.5);
% Fig=figure;
% set(Fig,'Position',[300 500 1000 400]);
% subplot(1,2,1)
% imagesc(squeeze(max(abs(Vz3Dpr(:,:,:)),[],1)).*sign(squeeze(mean(Vz3Dpr(:,:,:),1)))); 
% colormap(Vzcmap); caxis([-2 2]); colorbar
% title('prVz')
% axis equal; axis tight;
% subplot(1,2,2)
% imagesc(squeeze(max(abs(Vz3Dg1(:,:,:)),[],1)).*sign(squeeze(mean(Vz3Dg1(:,:,:),1)))); 
% colormap(Vzcmap); caxis([-2 2]); colorbar
% title('g1Vz')
% axis equal; axis tight;

% g1OCTA plot
g1AGV=imgaussfilt3(g1AG(:,:,:,1),1.1);  % dynamic index  
% difAglGG=imgaussfilt3(g1AG(:,:,:,2),1.1);
% difAglGG(difAglGG>-3)=1;  % threshold to show only large descending flow
g1AGD=g1AG(:,:,:,2); % flow direction
[Vcmap, Vzcmap, Dcmap, Mfcmap, Rcmap, g1OCTAcmap]=Colormaps_DLSOCT;
g1AGMIP=squeeze(max(g1AGV,[],1)).*squeeze(min(g1AGD,[],1));
figure;
imagesc(g1AGMIP);
colorbar; colormap (g1OCTAcmap);caxis([-1 1]); 
axis equal; axis tight;
title('g1OCTA')
