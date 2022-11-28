%% combine DLSOCT3DPART calculated result and save
function Combine_VDR(filename,datapath0, Start_file,N_file)
pathparts=strsplit(datapath0,'/');

datapath_base0=fullfile(pathparts{1:end-3});
datapath_base=['/',datapath_base0(1:end-1)];
savepath_base=['/',fullfile(pathparts{1:end-4})];
% if datapath0(end-49) =='-'
%     fileindex=str2num(datapath0(end-48));
%     datapath_base=datapath0(1:end-49);
%     savepath_base=datapath0(1:end-74);
% elseif datapath0(end-50) =='-'
%     fileindex=str2num(datapath0(end-49:end-48));
%     datapath_base=datapath0(1:end-50);
%     savepath_base=datapath0(1:end-75);
% end

filefolder1=pathparts{end-1};
filefolder2=pathparts{end-2};
N_VDR=str2num(filefolder2(6:8));
N_pixel=str2num(filefolder2(10:13));
nz=str2num(filefolder2(21:23)); 
nx=str2num(filefolder2(25:27)); % total number of ALines per Bscan
ny0=str2num(filefolder2(29:31)); 
ntau=str2num(filefolder2(33:34));

ny_per_iVDR=ny0/N_VDR;
%%% calculated parts information %%%%%%%%
prompt={'Number of VDR segments', 'Number of Bscan per VDR segment','GG nz','GG nx','GG ny'};
infoParts=inputdlg(prompt,'Parts infor', 1,{num2str(N_VDR),num2str(ny_per_iVDR),num2str(nz),num2str(nx),num2str(ny0)});
N_VDR=str2num(infoParts{1});  % number of Y segments
ny_per_iVDR=str2num(infoParts{2}); % number of Bscan per Y segments
nz=str2num(infoParts{3});  % number of Y segments
nx=str2num(infoParts{4});  % number of Y segments
ny0=str2num(infoParts{5});  % number of Y segments
%%%% data size %%%%%%%%%%%%%%%%%%%%%%%%%%
% nz=str2num(datapath(end-15:end-13));      % number of layers in z
% nx=str2num(datapath(end-11:end-9));      % number of Alines per Bscan
% ny=str2num(datapath(end-7:end-5));      % number of Bscans of RR
%%%%%
%% add MATLAB functions' path
% addpath('D:\OCT Imaging\Data Process CODE\CODE-BU\Functions') % Path on JTOPTICS
addpath('/projectnb/npboctiv/ns/Jianbo/OCT/CODE/BU-SCC/Functions') % subFunction Path on SCC server
addpath('/projectnb/npboctiv/ns/Jianbo/OCT/CODE/BU-SCC/GUI') % GUI path on SCC server
%% Load partial results and combine %%%%%%%%%%%
for ifile=1:N_file
    idatapath=[datapath_base,num2str(ifile+Start_file-1),'/',filefolder2,'/',filefolder1,'/'];
    disp(['Loading and combining - ',num2str(ifile+Start_file-1),'... ', datestr(now,'DD:HH:MM')])
    Msa = zeros(nz,nx,ny0);  Mfa = Msa;  Da = Msa;  Va= Msa;  Ra=Msa;
    for i_VDR=1:N_VDR
        Start_Bscan=(i_VDR-1)*ny_per_iVDR+1;
        End_Bscan=i_VDR*ny_per_iVDR;
        
        if exist([idatapath, 'VDR',num2str(N_VDR),'-',num2str(i_VDR), '.mat'])==0
            disp(['skipped *-',num2str(N_VDR),'-',num2str(i_VDR), '.mat'])
        else
            disp(['Loading and Combining ',num2str(i_VDR)])
            ifileSname=[num2str(N_VDR),'-',num2str(i_VDR), '.mat'];
            load([idatapath,'VDR',ifileSname]);
            Vta(:,:,Start_Bscan:End_Bscan)=Vt;
            Vza(:,:,Start_Bscan:End_Bscan)=Vz;
            Da(:,:,Start_Bscan:End_Bscan)=D;
            Ra(:,:,Start_Bscan:End_Bscan)=R;
            Msa(:,:,Start_Bscan:End_Bscan)=Ms;
            Mfa(:,:,Start_Bscan:End_Bscan)=Mf;
            
%             Vt(:,:,Start_Bscan:End_Bscan)= LoadMAT(idatapath,['Vt' ifileSname]);
%             Vz(:,:,Start_Bscan:End_Bscan)= LoadMAT(idatapath,['Vz' ifileSname]);
% %             SVz(:,:,Start_Bscan:End_Bscan)= LoadMAT(idatapath,['SVz' ifileSname]);
%             D(:,:,Start_Bscan:End_Bscan)= LoadMAT(idatapath,['D' ifileSname]);
%             Ms(:,:,Start_Bscan:End_Bscan)= LoadMAT(idatapath,['Ms' ifileSname]);
%             Mf(:,:,Start_Bscan:End_Bscan)= LoadMAT(idatapath,['Mf' ifileSname]);
%             R(:,:,Start_Bscan:End_Bscan)= LoadMAT(idatapath,['R' ifileSname]);
%             GGf(:,:,Start_Bscan:End_Bscan,:)= LoadMAT(idatapath,['GGf' ifileSname]);
        end
    end
    disp(['Results Loaded and combined ', datestr(now,'DD:HH:MM')])
%     Vsign=sign(Vza);
%     Vsign(Vsign~=-1)=1;
    V=sqrt(Vza.^2+Vta.^2); % Total velocity
    %% Save combined results %%%%%%%%%%%%%%%%%%%%%%%5
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     savefolder=['/VDRRESULTS-',num2str(ifile+Start_file-1)];
%     savepath=[savepath_base, savefolder, '/'];
    savepath=[savepath_base, '/'];
%     if exist(savepath)
%     else
%         mkdir(savepath_base,savefolder);
%     end
    %%%
    clear Vt Vz D R Ms Mf
    Vt=Vta; Vz=Vza; D=Da; R=Ra; Ms=Msa; Mf=Mfa;
    disp(['Saving results ... ', datestr(now,'DD:HH:MM')])
    save([savepath, 'DLSOCT-',pathparts{9},'.mat'],'-v7.3','D','Vt','Vz','V','Ms','Mf','R')
%     save([savepath, 'D', '.mat'],'D')
%     save([savepath, 'Vt','.mat'],'Vt')
%     save([savepath, 'Vz','.mat'],'Vz')
%     save([savepath, 'V','.mat'],'V')
%     save([savepath, 'MS', '.mat'],'Ms')
%     save([savepath, 'Mf', '.mat'],'Mf')
%     save([savepath, 'R', '.mat'],'R')
%     save([savepath, 'GGfit', '.mat'],'GGf')
    disp(['Finished VDR combination,', datestr(now,'DD:HH:MM')]);
    disp(savepath);
end
