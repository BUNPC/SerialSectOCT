%% Generate job file for launchpad calculating Dat2Mf
function JOBS_Dat2AG(filename0,datapath0, Start_file,N_file, intDk, jobsavepath)
jobfilename='Dat2AG.sh';
if nargin<5
    jobsavepath= '/projectnb/npboctiv/ns/Jianbo/BU-SCC/JOBS/';  % job.txt file save path
end
SubFunctionPath='/projectnb/npboctiv/ns/Jianbo/BU-SCC/Functions'; % sub functions Path on SCC server
SCCFunctionPath='/projectnb/npboctiv/ns/Jianbo/BU-SCC/SCCFunctions'; % SCC submit function Path on SCC server
%% Load data information
[Dim0, fNameBase,fIndex]=GetNameInfoRaw(filename0);
nk = Dim0.nk; nxRpt = Dim0.nxRpt; nx=Dim0.nx; nyRpt = Dim0.nyRpt; ny0 = Dim0.ny;
%% Light source information %%%%
lam0=1310; % nm, light source center frequency
lam_bw=170; % nm, bandwidth of light source 
Lam=[lam0 lam_bw];
if nyRpt>nxRpt
    RptBscan=1;
else
    RptBscan=0;
end


%%  Check surface %%%%%%
%% Load data_k to check surface
filePath=[datapath0,filename0];
disp(['Loading data for surface check... ', num2str(floor(ny0/2)), ', ',datestr(now,'DD:HH:MM')]);
dim=Dim0; dim.ny=1;
[data_ori] = ReadDat_int16(filePath, dim, floor(ny0/2)); % NII_ori: nk_Nx_ny,Nx=nt*nx;  floor(N_kfile/2)
data_k=DAT2k(data_ori,intDk);
disp(['Data loaded and processed to data_k,', datestr(now,'DD:HH:MM'),'\n', ...
    'data k to RR...']);
data_k_spctrm=data_k(1:nk,:,:);
%%
[nk,Nx,ny]=size(data_k_spctrm);
nz = round(nk/2);
RR_original = zeros(nz,Nx,ny,'single');
for iy=1:ny
    RRy = ifft(data_k_spctrm(:,:,iy));
    RR_original(:,:,iy) = RRy(1:nz,:);
end
%% select z range for data processing
fig=figure;
imagesc(abs((squeeze(max(RR_original(:,:,:),[],3)))));caxis([0 5])
xlabel('Y');ylabel('Z');ylim([1 300]);title('MIP along X')
% caxis([0 5])
disp(['Select brain surface and stack start layer in figure']);
[XY_surf, Z_surf]=ginput(3);
close(fig);
%     prompt2={'Surface','Start Z_seg',['Length Z_seg (axial resolution: ',num2str(dZ),')']};
prompt2={'Surface','Start Z_seg','End Z_seg','Num_subSpectrum'};
inputZseg=inputdlg(prompt2,'Z Segment parameter', 1,{num2str(floor(Z_surf(1))),num2str(floor(Z_surf(2))),num2str(floor(Z_surf(3))),'1'});
z_seg_surf=str2num(inputZseg{1});
z_seg_start=str2num(inputZseg{2});  %
z_seg_end=str2num(inputZseg{3});  %
nSubSpctrm=str2num(inputZseg{4}); % number of subspectrum for speckle reduction
LengthZ=z_seg_end-z_seg_start;
%%%%
Dim=[nk, nxRpt, nx, nyRpt, ny0];
Proc_option=[z_seg_start,z_seg_end, nSubSpctrm, intDk];  
datapath=['',datapath0,''];
%% path information 
pathInfo=strsplit(datapath0,'/');
jobname=strjoin(pathInfo(end-2:end-1),'-');
%% SCC node/core request 
prompt3={'# jobs','# cores per job','Memory per core','wall time','job name','email notify? (Y/N)'};
inputSCCinfo=inputdlg(prompt3,'SCC request parameter', 1,{num2str(N_file),'1','8','6',jobname,'N'});
Njobs=(inputSCCinfo{1});       % number of jobs to be submitted
Ncores=(inputSCCinfo{2});      % number of cores requested for each job
MemperCore=(inputSCCinfo{3});  % memory per core
WallTime=(inputSCCinfo{4});    % specify wall time
JobName=['Dat2AG-',inputSCCinfo{5}];              % Job name
EmailNote=inputSCCinfo{6};             % Email notify ?
if EmailNote=='Y' || EmailNote=='y'
    prompt4={'email address'};
    inputEmail=inputdlg(prompt4,'User email', 1,{'jianbo@bu.edu'});
    Emadd=(inputEmail{1});       % user's email address
    Emailinfo=['#$ -m ea','\n',...
        ['#$ -M ' Emadd],'\n'];
else
    Emailinfo=['\n'];
end

%%%%
fid=fopen([jobsavepath, jobfilename],'wt');
filename00=['',fNameBase,''];
job_cmd=['#! /bin/bash -l','\n'...
    ['#$ -pe omp ', Ncores],'\n',...
    ['#$ -l mem_per_core=',MemperCore,'G'], '\n',...
    ['#$ -l h_rt=',WallTime,':00:00'], '\n',...
    ['#$ -N ',JobName],'\n',...
    ['#$ -t 1-',Njobs],'\n',...
    Emailinfo,...
    'module load matlab/2017a','\n',...
    ['matlab -nodisplay -r ',...
    '"diary on; '...
    'addpath(''',SCCFunctionPath,'''); '...
    'addpath(''',SubFunctionPath,'''); ',...
    'datapath=''', datapath,'''; ',...
    'filename0=''',filename00,'''; ',...
    'Proc_option=[', num2str(Proc_option), ']; ',...
    'Dim=[',num2str(Dim), ']; ',...
    'iFile=$SGE_TASK_ID; ',...
    'SCC_ANGIO_Dat2AG(datapath, filename0,Proc_option, Dim, iFile); ',...
    'diary off; exit"']];
    fprintf(fid,job_cmd);
fclose(fid);
%% save Dat2AG processing information in data path
fid=fopen([datapath0, jobfilename],'wt');
filename00=['',fNameBase,''];
job_cmd=['#! /bin/bash -l','\n'...
    ['#$ -pe omp ', Ncores],'\n',...
    ['#$ -l mem_per_core=',MemperCore,'G'], '\n',...
    ['#$ -l h_rt=',WallTime,':00:00'], '\n',...
    ['#$ -N ',JobName],'\n',...
    ['#$ -t 1-',Njobs],'\n',...
    Emailinfo,...
    'module load matlab/2017a','\n',...
    ['matlab -nodisplay -r ',...
    '"diary on; '...
    'addpath(''',SCCFunctionPath,'''); '...
    'addpath(''',SubFunctionPath,'''); ',...
    'datapath=''', datapath,'''; ',...
    'filename0=''',filename00,'''; ',...
    'Proc_option=[', num2str(Proc_option), ']; ',...
    'Dim=[',num2str(Dim), ']; ',...
    'iFile=$SGE_TASK_ID; ',...
    'SCC_ANGIO_Dat2AG(datapath, filename0,Proc_option, Dim, iFile); ',...
    'diary off; exit"']];
    fprintf(fid,job_cmd);
fclose(fid);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(['Job Dat2AG.txt saved,', datestr(now,'DD:HH:MM')]);
disp(datapath0);
