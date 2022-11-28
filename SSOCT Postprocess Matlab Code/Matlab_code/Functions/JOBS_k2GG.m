%% Generate job file for launchpad calculating k2GG
function JOBS_k2GG
defaultpath='/autofs/cluster/MOD/OCT/Jianbo/EXPERIMENT/1209Mouse3/40xRegion3/AstopDLSOCT/RAW-1024-100-00500-001-500-1';
jobsavepath= '/autofs/cluster/MOD/OCT/Jianbo/CODE/Deployed/';  % job.txt file save path
jobfilename='k2GG.txt';
%%%%% load file, select any one of the same segmentation files %%%%%%%%%%
[filename0,datapath0]=uigetfile(defaultpath);
filename=filename0(1:9);
N_kfile=str2num(filename(7:8));
pathparts=strsplit(datapath0,'/');
filefolder=pathparts{end-1};
nk=str2num(filefolder(5:8)); 
nxRpt=str2num(filefolder(10:12)); nx=str2num(filefolder(14:18)); % total number of ALines per Bscan
nyRpt=str2num(filefolder(20:22)); ny0=str2num(filefolder(24:26));
dim0=[nk, nxRpt, nx, nyRpt, ny0];
%%%% set data process parameter %%%%%%%%%%%%%%%%%
Num_Bscan=ny0; % optional, specify number of Bscan used for calculation, optional
if nx>1000
    Num_Aline=Num_Bscan;
    OVERLAP_Ascan=1; 
else
    Num_Aline=nx; % specify number of Alines for each Bscan,
    OVERLAP_Ascan=0;
end
%%%%%%%%%%%%%%%%%%%%%
ntau=25;    % # of time lag to calculate the field autocorrelation funciton, g1

%%
clear inputNum
%% choose data process options %%%%%%%%%%%%%%%%%%
prompt={'Num k files','Number of spectrum (k) segments','N_Aline','N_Bscan','N_t','N_tau', ...
    'Overlab Ascans when reshaping? (0:N; 1:Y)','GG Voxel AVG?','Truncate z?','Moving window avg?','Lowpass filt?','Image_shift?'};
inputNum=inputdlg(prompt,'', 1,{num2str(N_kfile),'1',num2str(Num_Aline),num2str(Num_Bscan),'100',num2str(ntau), ...
    num2str(OVERLAP_Ascan),'0','1','0','0','0'});

N_kfile=str2num(inputNum{1});  % number of segments
N_spctrm=str2num(inputNum{2});  % number of segments
Num_Aline=str2num(inputNum{3});  % number of Aline
Num_Bscan=str2num(inputNum{4});  % number of segments
nT=str2num(inputNum{5});  % number of segments
ntau=str2num(inputNum{6});  % number of segments
OVERLAP_Ascan=str2num(inputNum{7});  % number of segments
GG_Neib_AVG=str2num(inputNum{8});  % number of segments
trunc_z=str2num(inputNum{9});  % number of segments
MW_AVG=str2num(inputNum{10});  % number of segments
Lowpassfilt=str2num(inputNum{11});  % number of segments
Image_shift=str2num(inputNum{12});  % number of segments
%%%% specify the 3D portion that to be calculated, optional
%% add MATLAB functions' path
% addpath('D:\PJ DLS-OCT\CODE\Functions') % Path on JTOPTICS
addpath('/autofs/cluster/MOD/OCT/Jianbo/CODE/Functions') % Path on server

%% input spectrum segmentation information %%%%%%%%%%
switch N_spctrm
    case 1
        prompt={'Number of camera pixes'};
        inputNumPix=inputdlg(prompt,'Segment parameter', 1,{'1024'});
        Num_pixel=str2num(inputNumPix{1});  % number of segments
    case 2
        Num_pixel=512;  % number of segments
    case 3
        Num_pixel=341;  % number of segments
    case 4
        Num_pixel=256;  % number of segments
end
%% axial resolution reduced due to segmentation
lam0_s=1.310; % light source center frequency, nm
lam_bw=0.170;  % bandwidth, nm
n=1.35;
dZ=2*log(2)*lam0_s.^2/(pi*lam_bw*n)*(1024/Num_pixel);
LengthZ=floor(100/(1024/Num_pixel)); % default length of Z_seg
%%  Check surface %%%%%%
%% Load data_k to check surface
disp(['Loading data for surface check... ']);
filenameChSuf=[filename, num2str(ceil(N_kfile/2))];
data_kChSuf=LoadMAT(datapath0, filenameChSuf);
data_k_spctrm=data_kChSuf(1:Num_pixel,:,:);
%%
[nk,Nx,ny]=size(data_k_spctrm);
nz = round(nk/2);
RR_original = zeros(nz,Nx,ny,'single');
for iy=1:ny
    RRy = ifft(data_k_spctrm(:,:,iy));
    RR_original(:,:,iy) = RRy(1:nz,:);
end
fig=figure;
subplot(1,2,1);imagesc(abs((squeeze(max(RR_original(:,:,:),[],2)))))
xlabel('Y');ylabel('Z');ylim([1 100]);title('MIP along X')
subplot(1,2,2);imagesc(abs((squeeze(max(RR_original(:,:,:),[],3)))))
xlabel('X');ylabel('Z');ylim([1 100]);title('MIP along Y')
disp(['Select the surface location in figure']);
[XY_surf, Z_surf]=ginput(1);
close(fig);
prompt={'Start Z_seg',['Length Z_seg (axial resolution: ',num2str(dZ),')']};
inputZseg=inputdlg(prompt,'Z Segment parameter', 1,{num2str(floor(Z_surf)),num2str(LengthZ)});
z_seg0=str2num(inputZseg{1});  % number of segments
LengthZ=str2num(inputZseg{2});
%%%%
XYTTauDim=[Num_Aline,Num_Bscan, nT, ntau];
Proc_option=[MW_AVG,Lowpassfilt,Image_shift,OVERLAP_Ascan,GG_Neib_AVG,trunc_z,z_seg0,LengthZ];  
datapath=['''',datapath0,''''];
filename00=['''',filename0,''''];
%%%%
fid=fopen([jobsavepath, jobfilename],'wt');
for ikfile=1:N_kfile
     job_cmd=['./run_Cluster_DLSOCT_B_k2GG.sh $MCR ', datapath,' ', filename00, ' ', '''',num2str(Proc_option),'''', ' ', ...
         '''',num2str(XYTTauDim),'''', ' ','''',num2str(Num_pixel),'''', ' ','''',num2str(N_kfile),'''', ' ','''',num2str(ikfile),'''','\n'];
     fprintf(fid,job_cmd);
end
fclose(fid);
%%
savefolder=[num2str(Num_pixel,'%04d'),'-',num2str(LengthZ,'%03d'),'-',num2str(Num_Aline,'%03d'),'-',num2str(Num_Bscan,'%03d'),'-',num2str(nT,'%03d'),'_',num2str(ntau,'%03d')];
savepath=[datapath0, '/', savefolder, '/'];
if exist(savepath)
else
    mkdir(datapath0,savefolder);
end
ny_seg=Num_Bscan/N_kfile; % number of Bscan per ikfile (Ysegment)
%%%% save axial resolution
save([savepath,'dZ', '.mat'],'dZ')
%% save GG process information
%%%%
fid=fopen([savepath, jobfilename],'wt');
for ikfile=1:N_kfile
     job_cmd=['./run_Cluster_DLSOCT_B_k2GG.sh $MCR ', datapath,' ', filename00, ' ', '''',num2str(Proc_option),'''', ' ', ...
         '''',num2str(XYTTauDim),'''', ' ','''',num2str(Num_pixel),'''', ' ','''',num2str(N_kfile),'''', ' ','''',num2str(ikfile),'''','\n'];
     fprintf(fid,job_cmd);
end
fclose(fid);

fid=fopen([savepath, 'RRGG', '-INFO.txt'],'wt');
GG_INFO=['Data information of data_k-',': ','Dimension (nk_nxRpt_nx_nyRpt_ny): ',num2str(nk),'_',num2str(nxRpt),'_',num2str(nx),'_',num2str(nyRpt),'_',num2str(ny0), '\n','\n'...
    'Data information of RR.mat: ',  'Dimension (nz_nx_ny): ', num2str(LengthZ),'_',num2str(Num_Aline*2),'_',num2str(Num_Bscan),'\n' ...
    'Data information of RR Segments: ',  'Dimension (nz_nx_nyseg): ', num2str(LengthZ),'_',num2str(Num_Aline*2),'_',num2str(ny_seg),'\n\n' ...
    'Data information of GG.mat: ',  'Dimension (nz_nx_ny_ntau): ', num2str(LengthZ),'_',num2str(Num_Aline),'_',num2str(Num_Bscan), '_',num2str(ntau), '\n' ...
    'Data information of GG Segments: ',  'Dimension (nz_nx_ny_ntau): ', num2str(LengthZ),'_',num2str(Num_Aline),'_',num2str(ny_seg), '_',num2str(ntau), '\n\n' ...
    'RR process methods: MWAVG-',num2str(MW_AVG), '\n'...
    '                    Lowpass-', num2str(Lowpassfilt),'\n'...
    '                    Image shift-', num2str(Image_shift),'\n'...
    '                    Overlap Ascan-', num2str(OVERLAP_Ascan),'\n'...
    '                    GG neighbering AVG-',num2str(GG_Neib_AVG),'\n','\n' ...  
    '                    Z_seg: ',  num2str(z_seg0),'-',num2str(z_seg0+LengthZ), '\n', ...
    '    Axial resolution (um): ',  num2str(dZ), '\n\n', ...
    '     # Spectral segmentation: ',  num2str(N_spctrm), '\n', ...
    'number of pixel per Spec_seg: ',  num2str(Num_pixel),'\n'];
fprintf(fid,GG_INFO);
fclose(fid);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Job k2GG.txt saved')
disp(savepath)
    
