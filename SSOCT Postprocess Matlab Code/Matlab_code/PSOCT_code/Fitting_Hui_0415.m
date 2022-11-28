datapath='/projectnb2/npbssmic/ns/myelin_content_scattering_correlation_paper_data/cerebellum/';

% add subfunctions for the script. Change directory if not running on BU SCC
addpath('/projectnb/npbssmic/s/Matlab_code/fitting_code');
addpath('/projectnb/npbssmic/s/Matlab_code/PostProcessing');
addpath('/projectnb/npbssmic/s/Matlab_code/PSOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code/ThorOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code');
cd(datapath);

filename0=dir(strcat('*_cropped.nii')); % count #tiles per slice
ntile=length(filename0);
nslice=1; % define total number of slices
create_dir(nslice, datapath);
cd(datapath);
id=5;%str2num(id);
   njobs=12;
   section=ceil(ntile/njobs);
    % the $SGE-TASK-ID environment variable read in is CHARACTER, need to transfer to number

   istart=(id-1)*section+1;
   istop=id*section;
% load('surface.mat');
for islice=1
%         create_dir(islice, folder); 
    cd(datapath);
    filename0=dir(strcat('*_cropped.nii')); 
    for iFile=istart:istop


        name=strsplit(filename0(iFile).name,'.');  
        name_dat=strsplit(name{1},'_');
        slice_index=islice;
        coord=str2num(name_dat{3});%num2str(iFile);
        % Xrpt and Yrpt are x and y scan repetition, default = 1
%         Zsize = str2num(name_dat{4}); Xrpt = 1; Xsize=str2num(name_dat{5}); Yrpt = 1; Ysize = str2num(name_dat{6});
%         dim1=[Zsize Xrpt Xsize Yrpt Ysize];     % tile size for reflectivity 
% %         dim1=[100 1 1100 1 1100];
%         name1=strcat('co-',num2str(islice),'-',num2str(iFile),'-',num2str(Zsize),'-',num2str(Xsize),'-',num2str(Ysize),'.dat'); % gen file name for reflectivity
%         % load reflectivity data
%         ifilePath = [datapath,name1];
%         co = single(ReadDat_int16(ifilePath, dim1))./65535*2; 
%         name1=strcat('cross-',num2str(islice),'-',num2str(iFile),'-',num2str(Zsize),'-',num2str(Xsize),'-',num2str(Ysize),'.dat'); % gen file name for reflectivity
%         % load reflectivity data
%         ifilePath = [datapath,name1];
%         cross = single(ReadDat_int16(ifilePath, dim1))./65535*2; 
        ref=Read_nii(datapath,filename0(iFile).name);

        message=strcat('Tile No. ',string(coord),' is read.', datestr(now,'DD:HH:MM'),'\n');
        fprintf(message);
%         ref = FOV_curvature_correction(ref, surface, size(ref,1), size(ref,2), size(ref,3));  
        %% for PTSD sample only
        % tissue surface too shallow
%         tmp=co(1:end-20,:,:);
%         co(1:10,:,:)=co(end-19:end-10,:,:);
%         co(11:end-10,:,:)=tmp;
% 
%         tmp=cross(1:end-20,:,:);
%         cross(1:10,:,:)=cross(end-19:end-10,:,:);
%         cross(11:end-10,:,:)=tmp;

        Optical_fitting_Hui_0415(ref,islice, coord, datapath);

    end
end

sys = 'PSOCT';
% specify mosaic parameters, you can get it from Imagej stitching
xx=-216;    % xx is the X displacement of two adjacent tile align in the X direction
xy=2;     % xy is the Y displacement of two adjacent tile align in the X direction, default to 0
yy=216;    % yy is the Y displacement of two adjacent tile align in the Y direction
yx=2;      % xx is the X displacement of two adjacent tile align in the Y direction, default to 0
numX=40;    % #tiles in X direction
numY=24;    % #tiles in Y direction
Xoverlap=0.15;   % overlap in X direction
Yoverlap=0.15;   % overlap in Y direction
disp=[xx xy yy yx];
mosaic=[numX numY Xoverlap Yoverlap];
pattern = 'bidirectional';  % mosaic pattern, could be bidirectional or unidirectional
pxlsize=[350 350];
% AIP_stitch(datapath,disp,mosaic,pxlsize,islice,pattern,sys);  
    Mus_stitch_Hui('mus',datapath,datapath,disp,mosaic,pxlsize,islice,pattern,sys);           % stitch mus
%     Mub_stitch('mub', folder,disp,mosaic,pxlsize./4,islice,pattern,sys);
%     Ret_stitch('bfg', folder,disp,mosaic,pxlsize./4,islice,pattern,sys);
