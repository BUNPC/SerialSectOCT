%% Generate job file for launchpad calculating Dat2Mf
function JOBS_Dat2Mf(filename0,datapath0, Start_file,N_file)
jobsavepath= '/projectnb/npboctiv/ns/Jianbo/OCT/CODE/BU-SCC/JOBS/';  % job.txt file save path
jobfilename='Dat2Mf.sh';
SubFunctionPath='/projectnb/npboctiv/ns/Jianbo/OCT/CODE/BU-SCC/Functions'; % sub functions Path on SCC server
SCCFunctionPath='/projectnb/npboctiv/ns/Jianbo/OCT/CODE/BU-SCC/JOBS/SCCFunctions'; % SCC submit function Path on SCC server
%% Load data information
[dim0, fNameBase,fIndex]=GetNameInfoRaw(filename0);
nk = dim0(1); nxRpt = dim0(2); nx=dim0(3); nyRpt = dim0(4); ny0 = dim0(5);
%%%% set data process parameter %%%%%%%%%%%%%%%%%
Num_Bscan=ny0; % optional, specify number of Bscan used for calculation, optional
if nx>2000
    Num_Aline=Num_Bscan;
    OVERLAP_Ascan=1; 
else
    Num_Aline=nx; % specify number of Alines for each Bscan,
    OVERLAP_Ascan=0;
end
%%%%%%%%%%%%%%%%%%%%%
ACF_nTau=25;      % default # of time lag to calculate the field autocorrelation funciton, g1
N_Ysegs=ny0/10;   % default number of subYseg
%% Light source information %%%%
lam0=1310; % nm, light source center frequency
lam_bw=170; % nm, bandwidth of light source 
Lam=[lam0 lam_bw];
if nyRpt>nxRpt
    RptBscan=1;
else
    RptBscan=0;
end
%% choose data process options %%%%%%%%%%%%%%%%%%
clear inputNum
prompt1={['Num Ysegs (nY=',num2str(Num_Bscan),', nX=',num2str(Num_Aline),', NxRpt=',num2str(nxRpt),', NyRpt=',num2str(nyRpt),')'],...
    'RptA_Start (nARpt Process)','RptA_Inerval (nARpt Process)','RptA_n (nARpt Process)',...
    'ACF_Start (ACF Process)','ACF_nt (ACF Process)','ACF_nTau (ACF Process)',...
    'N_Aline(DAQ)','N_Bscan(DAQ)','N_xRpt(DAQ)','N_yRpt(DAQ)'};
inputNum1=inputdlg(prompt1,'', 1,{num2str(N_Ysegs),'1','1',num2str(max(nxRpt,nyRpt)), ...
    '1','100',num2str(ACF_nTau), ...
    num2str(Num_Aline),num2str(Num_Bscan),num2str(nxRpt),num2str(nyRpt)});
N_Ysegs=str2num(inputNum1{1});    % number of segments
%% extract repeated alines from DAQ nxRpt, for repeated Ascan only
RptA_start=str2num(inputNum1{2});    % selecte start Aline repeat 
RptA_Interval=str2num(inputNum1{3});    % interval 
RptA_n=str2num(inputNum1{4});        % total number of extracted Alines
%% ACF calculation parameters
ACF_Start=str2num(inputNum1{5});       % start time for ACF calculation
ACF_nt=str2num(inputNum1{6});       % number of time points for ACF calculation
ACF_nTau=str2num(inputNum1{7});       % number of ACF time lag
%% DAQ info
Num_Aline=str2num(inputNum1{8});  % number of Aline
Num_Bscan=str2num(inputNum1{9});  % number of Bscans
n_xRpt=str2num(inputNum1{10});     % number of Ascan repeat
n_yRpt=str2num(inputNum1{11});     % number of Bscan repeat
%%
prompt2={'RR high pass filter?','Save all RR?','Number of speckle angiography?','Repeat Bscan for ACF?'...
    'Number of spectrum (k) segments','Dispersion compensation?','GG Voxel AVG?','Truncate z?','Overlab Ascans when reshaping? (0:N; 1:Y)'};
inputNum2=inputdlg(prompt2,'', 1,{'0','0','3',num2str(RptBscan),...
    '1','0','0','1', num2str(OVERLAP_Ascan)});
%% data process parameters
RRHPF=str2num(inputNum2{1});  % neib avg for different depth
SaveRRall=str2num(inputNum2{2});  % save RR choice
Nspk_angio=str2num(inputNum2{3});  % skeckle angio
RptBscan=str2num(inputNum2{4});    % Repeat Bscan for ACF calculation

N_spctrm=str2num(inputNum2{5});   % number of splited spectrum
DComp=str2num(inputNum2{6});  % Dispersion compensation
GG_Neib_AVG=str2num(inputNum2{7});   % ACF neghboring avg
trunc_z=str2num(inputNum2{8});   % optional
OVERLAP_Ascan=str2num(inputNum2{9});  % optional
%% data process and save parameters
NeibNorm=0;     % optional
MW_AVG=0;       % optional
Lowpassfilt=0;  % optional
Image_shift=0;  % optional
%%%% 
ny_seg=Num_Bscan/N_Ysegs; % number of Bscan per ikfile (Ysegment)
ARpt_extract=[RptA_start,RptA_Interval,RptA_n];
%% input spectrum segmentation information %%%%%%%%%%
Num_pixel=floor(nk/N_spctrm);
%% axial resolution reduced due to segmentation
lam0_s=1.310; % light source center frequency, nm
lam_bw=0.170;  % bandwidth, nm
n=1.35;
dZ=2*log(2)*lam0_s.^2/(pi*lam_bw*n)*(2048/Num_pixel);
LengthZ=floor(100/(2048/Num_pixel)); % default length of Z_seg
%%  Check surface %%%%%%
%% Load data_k to check surface
filePath=[datapath0,filename0];
disp(['Loading data for surface check... ', num2str(floor(N_Ysegs/2)), ', ',datestr(now,'DD:HH:MM')]);
dim=[nk, nxRpt, nx, nyRpt, 1];
[data_ori] = ReadDat_int16(filePath, dim, floor(N_Ysegs/2),ARpt_extract,RptBscan); % NII_ori: nk_Nx_ny,Nx=nt*nx;  floor(N_kfile/2)
dimK=[nk, RptA_n, nx, nyRpt, 1];
dimK(4)=1;
data_k=Dat2k(data_ori,dimK);
disp(['Data loaded and processed to data_k,', datestr(now,'DD:HH:MM'),'\n', ...
    'data k to RR...']);
data_k_spctrm=data_k(1:Num_pixel,:,:);
%%
[nk,Nx,ny]=size(data_k_spctrm);
nz = round(nk/2);
RR_original = zeros(nz,Nx,ny,'single');
for iy=1:ny
    RRy = ifft(data_k_spctrm(:,:,iy));
    RR_original(:,:,iy) = RRy(1:nz,:);
end
fig=figure;
imagesc(abs((squeeze(max(RR_original(:,:,:),[],3)))));caxis([0 5])
xlabel('Y');ylabel('Z');ylim([1 300]);title('MIP along X')
% caxis([0 5])
disp(['Select brain surface and stack start layer in figure']);
if DComp==1
    [XY_surf, Z_surf]=ginput(2);
    close(fig);
    prompt2={'DC_AutoCut','Start Z_seg',['Length Z_seg (axial resolution: ',num2str(dZ),')']};
    inputZseg=inputdlg(prompt2,'Z Segment parameter', 1,{num2str(floor(Z_surf(1))),num2str(floor(Z_surf(2))),num2str(LengthZ)});
    DC_AutoCut=str2num(inputZseg{1});
    z_seg0=str2num(inputZseg{2});  % number of segments
    LengthZ=str2num(inputZseg{3});
    [PhaseDC]=DispersionCoeff(data_ori(:,1:n_xRpt:end), DC_AutoCut);
    DC=1;
else 
    [XY_surf, Z_surf]=ginput(3);
    close(fig);
%     prompt2={'Surface','Start Z_seg',['Length Z_seg (axial resolution: ',num2str(dZ),')']};
    prompt2={'Surface','Start Z_seg','End Z_seg'};
    inputZseg=inputdlg(prompt2,'Z Segment parameter', 1,{num2str(floor(Z_surf(1))),num2str(floor(Z_surf(2))),num2str(floor(Z_surf(3)))});
    z_seg_surf=str2num(inputZseg{1});
    z_seg0=str2num(inputZseg{2});  % number of segments
    LengthZ=str2num(inputZseg{3})-str2num(inputZseg{2});
    DC=0;
end
%%%%
Dim=[nk, nxRpt, nx, nyRpt, ny0];
N_Mf_AVG=1;
XYTTauDim=[Num_Aline,Num_Bscan,RptA_start,RptA_Interval, RptA_n,N_Mf_AVG, ACF_Start,ACF_nt,ACF_nTau];
Proc_option=[MW_AVG,Lowpassfilt,Image_shift,OVERLAP_Ascan,GG_Neib_AVG,trunc_z,z_seg0,LengthZ,NeibNorm,DC,RRHPF,SaveRRall, Nspk_angio, RptBscan];  
datapath=['',datapath0,''];
%% path information 
pathInfo=strsplit(datapath0,'/');
jobname=strjoin(pathInfo(end-2:end-1),'-');
%% SCC node/core request 
prompt3={'# jobs','# cores per job','Memory per core','wall time','job name','email notify? (Y/N)'};
inputSCCinfo=inputdlg(prompt3,'SCC request parameter', 1,{num2str(N_Ysegs),'1','8','6',jobname,'N'});
Njobs=(inputSCCinfo{1});       % number of jobs to be submitted
Ncores=(inputSCCinfo{2});      % number of cores requested for each job
MemperCore=(inputSCCinfo{3});  % memory per core
WallTime=(inputSCCinfo{4});    % specify wall time
JobName=['Dat2Mf-',inputSCCinfo{5}];              % Job name
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
for ifile=1:N_file
    ifilename=[fNameBase,num2str(Start_file+ifile-1),'.dat'];
    filename00=['',ifilename,''];
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
        'XYTTauDim=[',num2str(XYTTauDim),']; ',...
        'Num_pixel=', num2str(Num_pixel), '; ',...
        'N_Ysegs=',num2str(N_Ysegs), '; ',...
        'i_Yseg=$SGE_TASK_ID; ',...
        'SCC_DLSOCT_A_Dat2Mf(datapath, filename0,Proc_option, Dim, XYTTauDim, Num_pixel,N_Ysegs,i_Yseg); ',...
        'diary off; exit"']];
    fprintf(fid,job_cmd);
end
fclose(fid);
%%

%% save Dat2Mf process information
%%%%
for ifile=1:N_file
    savefolder=[num2str(Num_pixel,'%04d'),'-',num2str(LengthZ,'%03d'),'-',num2str(Num_Aline,'%03d'),'-',num2str(Num_Bscan,'%03d'),...
    '-',num2str(ACF_nt,'%03d'),'_',num2str(ACF_nTau,'%03d'),...
    '-',num2str(RptA_start),'-',num2str(RptA_Interval),'-',num2str(RptA_n),'-',num2str(ifile+Start_file-1)];
    savepath=[datapath0, '/', savefolder, '/'];
    if exist(savepath)
    else
        mkdir(datapath0,savefolder);
    end
end
%%%% save axial resolution
save([savepath,'dZ', '.mat'],'dZ')
if DComp==1
    save([savepath,'PhaseDC', '.mat'],'PhaseDC');
end

fid=fopen([savepath, jobfilename],'wt');
for ifile=1:N_file
    ifilename=[fNameBase,num2str(Start_file+ifile-1),'.dat'];
    filename00=['',ifilename,''];
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
        'XYTTauDim=[',num2str(XYTTauDim),']; ',...
        'Num_pixel=', num2str(Num_pixel), '; ',...
        'N_Ysegs=',num2str(N_Ysegs), '; ',...
        'i_Yseg=$SGE_TASK_ID; ',...
        'SCC_DLSOCT_A_Dat2Mf(datapath, filename0,Proc_option, Dim, XYTTauDim, Num_pixel,N_Ysegs,i_Yseg); ',...
        'diary off; exit"']];
    fprintf(fid,job_cmd);
end
fclose(fid);
if SaveRRall==1
    RRmatInfo=['Dimension (nz_nx_ny_nxRpt): ', num2str(LengthZ),'_',num2str(Num_Aline),'_',num2str(Num_Bscan),'_',num2str(RptA_n)];
else
    RRmatInfo=['Dimension (nz_nx_ny): ', num2str(LengthZ),'_',num2str(Num_Aline*2),'_',num2str(Num_Bscan)];
end

fid=fopen([savepath, 'RRGG', '-INFO.txt'],'wt');
GG_INFO=['Data information of Dat',': ','Dimension (nk_nxRpt_nx_nyRpt_ny): ',num2str(nk),'_',num2str(nxRpt),'_',num2str(nx),'_',num2str(nyRpt),'_',num2str(ny0), '\n','\n'...
    '(Num of ikfile, ny_per ikfile): ', num2str(N_Ysegs),', ',num2str(ny_seg),'\n'...
    'Data structure each ikfile (nk_nxRpt_nx_nyRpt_ny, Nx=nxRpt*nx*nyRpt): ', num2str(nk),'_',num2str(nxRpt),'_',num2str(nx),'_',num2str(nyRpt),'_',num2str(ny_seg),'\n\n',...
    'Data information of RR.mat: ',  RRmatInfo,'\n' ...
    'Data information of RR Segments: ',  'Dimension (nz_nx_nyseg): ', num2str(LengthZ),'_',num2str(Num_Aline*2),'_',num2str(ny_seg),'\n\n' ...
    'Data information of GG.mat: ',  'Dimension (nz_nx_ny_ntau): ', num2str(LengthZ),'_',num2str(Num_Aline),'_',num2str(Num_Bscan), '_',num2str(ACF_nTau), '\n' ...
    'Data information of GG Segments: ',  'Dimension (nz_nx_ny_ntau): ', num2str(LengthZ),'_',num2str(Num_Aline),'_',num2str(ny_seg), '_',num2str(ACF_nTau), '\n\n' ...
    'RR process methods: MWAVG-',num2str(MW_AVG), '\n'...
    '                    Lowpass-', num2str(Lowpassfilt),'\n'...
    '                    Image shift-', num2str(Image_shift),'\n'...
    '                    Overlap Ascan-', num2str(OVERLAP_Ascan),'\n'...
    '                    Truncate z-', num2str(trunc_z),'\n'...
    '                    GG neighbering AVG-',num2str(GG_Neib_AVG),'\n','\n' ...  
    '                    (Lamda0, BW): ', num2str(Lam),'\n\n'...
    '                    Surface: ',  num2str(z_seg_surf), '\n', ...
    '                    Z_seg: ',  num2str(z_seg0),'-',num2str(z_seg0+LengthZ), '\n', ...
    '    Axial resolution (um): ',  num2str(dZ), '\n\n', ...
    '     # Spectral segmentation: ',  num2str(N_spctrm), '\n', ...
    'number of pixel per Spec_seg: ',  num2str(Num_pixel),'\n'];
fprintf(fid,GG_INFO);
fclose(fid);

fid=fopen([datapath0, '/', savefolder, '-INFO.txt'],'wt');
fprintf(fid,GG_INFO);
fclose(fid);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(['Job Dat2Mf.txt saved,', datestr(now,'DD:HH:MM')]);
disp(savepath);
