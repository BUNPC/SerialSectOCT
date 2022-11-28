%% combine DLSOCT3DPART calculated result and save
function Combine_RRGG(filename0,datapath0, Start_file,N_file)

filename=filename0(1:7);

if datapath0(end-3) =='-'
    fileindex=str2num(datapath0(end-2:end-1));
    path_base=datapath0(1:end-3);
else
    fileindex=str2num(datapath0(end-1));
    path_base=datapath0(1:end-2);
end
fileParts=strsplit(filename0,'-');
N_kfile=str2num(fileParts{2});
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
prompt={'Number of subGG after combination (1, 4 or 80)','GG VOXEL AVG? (1:Y; 0:N)','Combine RRstd? (1:Y; 0:N)','Combine RR? (1:Y; 0:N)','Save RR? (1:Y; 0:N)','NyRpt', 'Number of iGGfile (Dat2GG)', 'Number of Bscan per Y segment','GG nz','GG nx','GG ny', 'GG ntau'};
infoParts=inputdlg(prompt,'Parts infor', 1,{num2str(N_subGG),'1','0','0','0','1',num2str(N_kfile),num2str(ny_seg),num2str(nz),num2str(nx),num2str(ny0), num2str(ntau)});

N_subGG=str2num(infoParts{1});  % number of Y segments
GG_Neib_AVG=str2num(infoParts{2});
CombRRstd=str2num(infoParts{3}); 
CombRR=str2num(infoParts{4}); 
SaveRR=str2num(infoParts{5}); 
NyRpt=str2num(infoParts{6});  % number of Y segments
N_kfile=str2num(infoParts{7});  % number of Y segments
Ny_Per_seg=str2num(infoParts{8}); % number of Bscan per Y segments
nz=str2num(infoParts{9});  % number of Z depth
nx=str2num(infoParts{10});  % number of Aline
ny0=str2num(infoParts{11});  % number of Bscan
ntau=str2num(infoParts{12});  % ntau
if SaveRR==1
    CombRR=1;
end
if NyRpt>1
    Ny_Per_seg=NyRpt*Ny_Per_seg;
end
%%%%%
%% Load partial results and combine %%%%%%%%%%%
if N_subGG==4
    NGGXY=2;
elseif N_subGG==1
    NGGXY=1;
elseif N_subGG>4
    NGGXY=N_subGG;
end
%% Gaussian 2D kernel
for x = 1:5
    for y=1:5
        radiusSquared = (x-3).^2 + (y-3).^2 ;
        Gaus_2D(x, y) = 1*exp(-radiusSquared/1.6);
    end
end
    
for ifile=1:N_file
    idatapath=[path_base,num2str(ifile+Start_file-1),'/'];
    for ispctrm=1:N_spctrm
        disp(['Loading and combining ', num2str(ifile+Start_file-1), ', ispctrm=', num2str(ispctrm),', ', datestr(now,'DD:HH:MM')])
        GG_ori = zeros(nz,nx,NyRpt*ny0,ntau);
        
        for ikfile=1:N_kfile
            iGGname=['GG',num2str(ispctrm),'-',num2str(N_kfile,'%02d'),'-',num2str(ikfile)];
            iRRname=['RR',num2str(ispctrm),'-',num2str(N_kfile,'%02d'),'-',num2str(ikfile)];
            iRRstdname=['RRstd',num2str(ispctrm),'-',num2str(N_kfile,'%02d'),'-',num2str(ikfile)];
            
            if exist([idatapath, iGGname, '.mat'])==0
                disp(['skiped ',num2str(ikfile), '.mat'])
            else
                disp(['Combining.. ', num2str(ikfile),', ',datestr(now,'DD:HH:MM')])
                GG_ori(:,:,(ikfile-1)*Ny_Per_seg+1:ikfile*Ny_Per_seg,:)= LoadMAT(idatapath,iGGname);
                %% combine RR
                if CombRR==1
                    if ikfile==1
                        [nz,nx,nyseg,nt]=size(LoadMAT(idatapath,iRRname));
                        RR=zeros(nz,nx,ny0,nt);
                    end
                    RR(:,:,(ikfile-1)*Ny_Per_seg+1:ikfile*Ny_Per_seg,:)=LoadMAT(idatapath,iRRname);
                end
                %% combine RRstd
                if CombRRstd==1 
                    if ikfile==1
                        [nz,nx,nyseg]=size(LoadMAT(idatapath,iRRstdname));
                        RRstd=zeros(nz,nx,ny0);
                    end
                    RRstd(:,:,(ikfile-1)*Ny_Per_seg+1:ikfile*Ny_Per_seg)=LoadMAT(idatapath,iRRstdname);
                end
            end
        end
        %% FocusMask and RRNN
        if CombRR==1
            NeibRange=20;
            RRtavg=mean(RR,4);
            [nz,nx,ny]=size(RRtavg);
            
            for iz=1:nz
                RRiz=squeeze(abs(RRtavg(iz,:,:)));
                RRconv(iz,:,:)=conv2(RRiz, Gaus_2D,'same')/sum(Gaus_2D(:));
            end
            for ix=1:nx
                for iy=1:ny
                    ixx=max(1,ix-NeibRange):2:min(nx,ix+NeibRange-1);
                    iyy=max(1,iy-NeibRange):2:min(ny,iy+NeibRange-1);
                    RRm=abs(RRtavg(:,ixx,iyy));
                    RR_Dep_PFL_Norm=mean(RRm(:,:),2)/max(mean(RRm(:,:),2));
                    RR_Dep_PFL_Norm(RR_Dep_PFL_Norm<0.75)=0;
                    RR_Dep_PFL_Norm(RR_Dep_PFL_Norm>0)=1;
                    FocusMask(:,ix,iy)=RR_Dep_PFL_Norm;
                    %%
                    RRixiyNeib=abs(RRconv(:,[ixx],[iyy]));
                    temp=sort(RRixiyNeib(:,:),2,'descend');
                    RRNN(:,ix,iy)=RRconv(:,ix,iy)./mean(temp(:,1:round(end/3)),2);
                end
            end
        end
        %% voxel averaging
        if GG_Neib_AVG==1 % averaging 3X3 neighbouring elements of ACF
            disp(['Voxel averaging... ', datestr(now,'DD:HH:MM')])
            B_conv=ones(3,3,3);
            for itau=1:ntau
                GG_ori(:,:,:,itau)=convn(squeeze(GG_ori(:,:,:,itau)),B_conv,'same')/numel(B_conv); % average neighboring 3X3X3, voxels
            end
        end
        %% save subGG %%
%         nz=2; % temp
        savefolder=['RRGG','_',num2str(N_subGG,'%03d'),'_',num2str(Num_pixel,'%04d'),'-','0000',num2str(GG_Neib_AVG), ...
            '_',num2str(nz,'%03d'),'_',num2str(nx,'%03d'),'_',num2str(ny0,'%03d'),'_',num2str(ntau,'%02d')];
        savepath=[idatapath, '/', savefolder, '/'];
        if exist(savepath)
        else
            mkdir(idatapath,savefolder);
        end
        
        if N_subGG>4
            GG = zeros(nz,nx,NyRpt*ny0/NGGXY,ntau);
            for iGGy=1:NGGXY
                nameGG=['GG','-',num2str(iGGy),'-',num2str(ispctrm)]; % GG-1-1, # GG-ith subGG-ith spectrum
                %%
                GG=(GG_ori(:,:,(iGGy-1)*(floor(NyRpt*ny0/NGGXY))+1:iGGy*(floor(NyRpt*ny0/NGGXY)),:));
%                 GG(1,:,:,:)=mean(GG_ori(:,:,(iGGy-1)*(floor(NyRpt*ny0/NGGXY))+1:iGGy*(floor(NyRpt*ny0/NGGXY)),:),1); % temp
%                 GG(2,:,:,:)=GG(1,:,:,:); % temp
                %% SAVE RESULTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                disp(['Saving data - ', num2str(iGGy),'...',datestr(now,'DD:HH:MM')])
                save([savepath,nameGG, '.mat'],'GG','-v7.3')
                [nz_GG,nx_GG,ny_GG,nt]=size(GG);
                disp(['Data saved. ', datestr(now,'DD:HH:MM')])
            end
        else
            GG = zeros(nz,nx/NGGXY,NyRpt*ny0/NGGXY,ntau);
            
            for iGGy=1:NGGXY
                for iGGx=1:NGGXY
                    Index_GG=(iGGy-1)*NGGXY++iGGx;
                    nameGG=['GG','-',num2str(Index_GG),'-',num2str(ispctrm)]; % GG-1-1, # GG-ith subGG-ith spectrum
                    GG=(GG_ori(:,(iGGx-1)*(floor(nx/NGGXY))+1:iGGx*(NyRpt*floor(nx/NGGXY)),(iGGy-1)*(floor(ny0/NGGXY))+1:iGGy*(NyRpt*floor(ny0/NGGXY)),:));
                    %%%%% TEMP %%%%
%                     GG(1,:,:,:)=mean(GG_ori(:,:,(iGGy-1)*(floor(NyRpt*ny0/NGGXY))+1:iGGy*(floor(NyRpt*ny0/NGGXY)),:),1); %temp
%                     GG(2,:,:,:)=GG(1,:,:,:); % temp
                    %%%% TEMP %%%%%
                    %% SAVE RESULTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    disp(['Saving data - ', num2str(Index_GG),'...',datestr(now,'DD:HH:MM')])
                    save([savepath,nameGG, '.mat'],'GG','-v7.3')
                    [nz_GG,nx_GG,ny_GG,nt]=size(GG);
                    disp(['Data saved. ', datestr(now,'DD:HH:MM')])
                    %% GG mask for neural cell body motility 
                    GG1=squeeze(abs(GG(:,:,:,1)));
                    GGmin=squeeze(abs(min(GG(:,:,:,:),[],4)));
                    GG_mask=ones(size(GG1));
                    GG_mask(GG1>0.8)=0;
                    GG_mask(GG1-GGmin>0.05)=0;
                    disp(['Saving GG_mask - ', num2str(Index_GG),'...',datestr(now,'DD:HH:MM')])
                    save([savepath,nameGG,'-mask', '.mat'],'GG_mask','-v7.3')
                    disp(['GG_mask saved. ', datestr(now,'DD:HH:MM')])
                    %% 
                    if SaveRR==1
                        RR0=zeros(nz,nx/NGGXY, ny0/NGGXY, nt);
                        Index_RR=(iGGy-1)*NGGXY++iGGx;
                        nameRR=['RR','-',num2str(Index_GG),'-',num2str(ispctrm)]; % GG-1-1, # GG-ith subGG-ith spectrum
                        RR0=(RR(:,(iGGx-1)*(floor(nx/NGGXY))+1:iGGx*(NyRpt*floor(nx/NGGXY)),(iGGy-1)*(floor(ny0/NGGXY))+1:iGGy*(NyRpt*floor(ny0/NGGXY)),:));
                        disp(['Saving RR... ', datestr(now,'DD:HH:MM')])
                        save([savepath,nameRR, '.mat'],'RR0','-v7.3')
                        disp(['Data saved', datestr(now,'DD:HH:MM')])
                    end
                end
            end
        end
        %% SAVE RESULTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if CombRRstd==1
            nameRRstd=['RRstd']; %
            disp(['Saving RRstd... ', datestr(now,'DD:HH:MM')])
            save([savepath,nameRRstd, '.mat'],'RRstd','-v7.3')
            disp(['Data saved', datestr(now,'DD:HH:MM')])
        end
        if CombRR==1
            nameFocusMask=['FocusMask']; % ith spectrum data
            disp(['Saving FocusMask... ', datestr(now,'DD:HH:MM')])
            save([savepath,nameFocusMask, '.mat'],'FocusMask','-v7.3')
            disp(['Data saved', datestr(now,'DD:HH:MM')])
            
            nameRRNN=['RRNN']; % neighbor normalized RR (for neural cell body imaging)
            disp(['Saving RRNN... ', datestr(now,'DD:HH:MM')])
            save([savepath,nameRRNN, '.mat'],'RRNN','-v7.3')
            disp(['Data saved', datestr(now,'DD:HH:MM')])
         
        end
    end
    disp(['Finished RRGG combination,', datestr(now,'DD:HH:MM')]);
    savepath
end

