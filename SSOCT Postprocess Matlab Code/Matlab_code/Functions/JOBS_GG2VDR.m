%% Generate job file for launchpad calculating GG2VDR
function JOBS_GG2VDR(filename0,datapath0, Start_file,N_file,jobsavepath)
jobfilename='GG2VDR.sh';
if nargin<5
    jobsavepath= '/projectnb/npboctiv/ns/Jianbo/BU-SCC/JOBS/';  % job.txt file save path
end
SubFunctionPath='/projectnb/npboctiv/ns/Jianbo/BU-SCC/Functions'; % sub functions Path on SCC server
SCCFunctionPath='/projectnb/npboctiv/ns/Jianbo/BU-SCC/SCCFunctions'; % SCC submit function Path on SCC server

%%%%% load file, select any one of the same segmentation files %%%%%%%%%%
filename=filename0(1:3);
ispctrm=filename0(end);
pathparts=strsplit(datapath0,'/');
jobpath0=['/',fullfile(pathparts{1:end-2}),'/'];

if jobpath0(end-1) =='-'
    path0=jobpath0(1:end-1);
elseif jobpath0(end-2) =='-'
    path0=jobpath0(1:end-2);
end
filefolder1=pathparts{end-1};
N_GG=str2num(filefolder1(6:8));
N_pixel=str2num(filefolder1(10:13));
nz=str2num(filefolder1(21:23)); 
nx=str2num(filefolder1(25:27)); % total number of ALines per Bscan
ny0=str2num(filefolder1(29:31)); 
ntau=str2num(filefolder1(33:34));
%%% calculated parts information %%%%%%%%
Ny_per_iGG=ny0/N_GG;
prompt={'Number of subGG','Fit with? (0:Fit; 1: FitOld2; 2: FitOld1)', 'Number of Bscan per Y segment','Objective (10/40)','Aline rate (k Hz)','Spectral pixle','GG nz','GG nx','GG ny'};
infoParts=inputdlg(prompt,'Parts infor', 1,{num2str(N_GG),'0',num2str(Ny_per_iGG),'10','76',num2str(N_pixel),num2str(nz),num2str(nx),num2str(ny0)});

N_GG=str2num(infoParts{1});  % number of Y segments
wfit=str2num(infoParts{2});  % Fitting method selection
Ny_per_iGG=str2num(infoParts{3}); % number of Bscan per Y segments
Objective=str2num(infoParts{4}); 
PRSinfo.fAline=str2num(infoParts{5})*1000;  % Hz
N_pixel=str2num(infoParts{6}); 
nz=str2num(infoParts{7}); 
nx=str2num(infoParts{8});  
ny0=str2num(infoParts{9});  
N_spctrm=floor(2048/N_pixel);
%% Generate job.txt file
dz=3.29*2048/N_pixel;
if Objective == 10
    PRSinfo.FWHM=[3.3 dz]*1e-6; % lateral and axial resolution, m
elseif Objective == 40
    PRSinfo.FWHM=[0.9 dz]*1e-6; % lateral and axial resolution, m
end
PRSinfo.Lam=[1310 170]*1e-9; % [center wavelength, bandwidth], m

if wfit==0
    sltfit='SCC_DLSOCT_C_GG2VDR(datapath,iGG,N_GG,N_spctrm); ';
elseif wfit==1
    sltfit='SCC_DLSOCT_CN_GG2VDR(datapath,iGG,N_GG,N_spctrm); ';
elseif wfit==2
    sltfit='SCC_DLSOCT_CO_GG2VDR(datapath, xzr, f_Aline, iGG,N_GG,N_spctrm); ';
end

%% SCC node/core request 
pathInfo=strsplit(datapath0,'/');
jobname=strjoin(pathInfo(end-4:end-3),'-');

prompt3={'# jobs','# cores per job','Memory per core','wall time','job name','email notify? (Y/N)'};
inputSCCinfo=inputdlg(prompt3,'SCC request parameter', 1,{num2str(N_GG),'1','8','6',['GG2VDR-',jobname],'N'});
Njobs=(inputSCCinfo{1});       % number of jobs to be submitted
Ncores=(inputSCCinfo{2});      % number of cores requested for each job
MemperCore=(inputSCCinfo{3});  % memory per core
WallTime=(inputSCCinfo{4});    % specify wall time
JobName=inputSCCinfo{5};              % Job name
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

fid=fopen([jobsavepath, jobfilename],'wt');
for ifile=1:N_file
    datapath=[path0,num2str(ifile+Start_file-1),'/',pathparts{end-1},'/'];
    
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
        'iGG=$SGE_TASK_ID; ',...
        'N_GG=',num2str(N_GG),'; ',...
        'N_spctrm=',num2str(N_spctrm),'; ',...
        sltfit,...
        'diary off; exit"']];
    fprintf(fid,job_cmd);
    save([datapath,'PRSinfo.mat'], 'PRSinfo')
end
fclose(fid);

fid=fopen([datapath0, jobfilename],'wt');
for ifile=1:N_file
    datapath=[path0,num2str(ifile+Start_file-1),'/',pathparts{end-1},'/'];
    
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
        'iGG=$SGE_TASK_ID; ',...
        'N_GG=',num2str(N_GG),'; ',...
        'N_spctrm=',num2str(N_spctrm),'; ',...
        sltfit,...
        'diary off; exit"']];
    fprintf(fid,job_cmd);
    save([datapath,'PRSinfo.mat'], 'PRSinfo')
end
fclose(fid);


disp('Job GG2VDR.sh saved')
disp(jobpath0);