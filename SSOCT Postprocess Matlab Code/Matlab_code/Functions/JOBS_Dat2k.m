%% generate Dat2k jobs for launchpad calculation
function JOBS_Dat2k(filename0,datapath0)
jobsavepath= '/autofs/cluster/MOD/OCT/Jianbo/CODE/Deployed/';  % job.txt file save path
jobfilename='Dat2k.txt';
%% Load data information
filename=filename0(1:28);
nk=str2num(filename(5:8)); 
nxRpt=str2num(filename(10:12)); nx=str2num(filename(14:18));
nyRpt=str2num(filename(20:22)); ny0=str2num(filename(24:26));
dim0=[nk, nxRpt, nx, nyRpt, ny0];
%% File numbers
N_kfile=ny0/10;   % number of file to be loaded , default value
prompt={['Num of ikfiles, nk_nxRpt_nx_nyRpt_ny=',num2str(dim0)]};
inputNumGG=inputdlg(prompt,'File info', 1,{num2str(N_kfile)});
N_kfile=str2num(inputNumGG{1});  % number of file
%%%%%
ny_seg=floor(ny0/N_kfile); % number Bscans per ikfile 
Nx=nxRpt*nx*nyRpt;
%% Light source information %%%%
lam0=1310; % nm, light source center frequency
lam_bw=170; % nm, bandwidth of light source 
Lam=[lam0 lam_bw];
%% data dimenssion %%%%%%%%%%
Dim=[nk, nxRpt, nx, nyRpt, ny0];
datapath=['''',datapath0,''''];
filename00=['''',filename0,''''];
%%%%
fid=fopen([jobsavepath, jobfilename],'wt');
for ikfile=1:N_kfile
     job_cmd=['./run_Cluster_DLSOCT_A_Dat2k.sh $MCR ', datapath,' ', filename00, ' ', '''',num2str(Dim),'''', ...
         ' ','''',num2str(N_kfile),'''', ' ','''',num2str(ikfile),'''','\n'];
     fprintf(fid,job_cmd);
end
fclose(fid);
%% Dat2k process information save 
savefolder=[filename];
savepath=[datapath0, '/', savefolder, '/'];
if exist(savepath)
else
    mkdir(datapath0,savefolder);
end

fid=fopen([savepath, jobfilename],'wt');
for ikfile=1:N_kfile
     job_cmd=['./run_Cluster_DLSOCT_A_Dat2k.sh $MCR ', datapath,' ', filename00, ' ', '''',num2str(Dim),'''', ...
         ' ','''',num2str(N_kfile),'''', ' ','''',num2str(ikfile),'''','\n'];
     fprintf(fid,job_cmd);
end
fclose(fid);

savename=['data_k',num2str(N_kfile,'%02d')];
data_k_INFO=['       Data information of ', savename,'\n', '\n',  ...
    'Raw data (nk_nxRpt_nx_nyRpt_ny, Nx=nxRpt*nx*nyRpt): ', num2str(nk),'_',num2str(nxRpt),'_',num2str(nx),'_',num2str(nyRpt),'_',num2str(ny0), '\n'...
    '                                      (Lamda0, BW): ', num2str(Lam),'\n\n'...
    '                                      Num of ikfile, ny_per segment): ', num2str(N_kfile),'_',num2str(ny_seg),'\n'...
    'Data structure each ikfile (nk_nxRpt_nx_nyRpt_ny, Nx=nxRpt*nx*nyRpt): ', num2str(nk),'_',num2str(nxRpt),'_',num2str(nx),'_',num2str(nyRpt),'_',num2str(ny_seg)];
fid=fopen([savepath, savename,'-INFO.txt'],'wt');
fprintf(fid,data_k_INFO);
fclose(fid);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Job Dat2k.txt saved')
disp(datapath0)
    
