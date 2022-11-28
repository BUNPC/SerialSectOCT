folder  = '/projectnb2/npbssmic/ns/BA4445_4/';
P2path = '/projectnb2/npbssmic/ns/BA4445_4_2P/';   % 2P file path
datapath=strcat(folder,'dist_corrected/'); 

% add subfunctions for the script. Change directory if not running on BU SCC
addpath('/projectnb/npbssmic/s/Matlab_code/fitting_code');
addpath('/projectnb/npbssmic/s/Matlab_code/PostProcessing');
addpath('/projectnb/npbssmic/s/Matlab_code/PSOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code/ThorOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code');

cd(datapath);
ntile=154;
nslice=120; % define total number of slices
njobs=1;
section=ceil(ntile/njobs);

sys = 'PSOCT';
% specify mosaic parameters, you can get it from Imagej stitching
xx=866;    % xx is the X displacement of two adjacent tile align in the X direction
xy=0;     % xy is the Y displacement of two adjacent tile align in the X direction, default to 0
yy=866;    % yy is the Y displacement of two adjacent tile align in the Y direction
yx=0;      % xx is the X displacement of two adjacent tile align in the Y direction, default to 0
numX=14;    % #tiles in X direction
numY=11;    % #tiles in Y direction
Xoverlap=0.05;   % overlap in X direction
Yoverlap=0.05;   % overlap in Y direction
disp=[xx xy yy yx];
mosaic=[numX numY Xoverlap Yoverlap];
pattern = 'bidirectional';  % mosaic pattern, could be bidirectional or unidirectional
pxlsize=[1000 1000];

% the $SGE-TASK-ID environment variable read in is CHARACTER, need to transfer to number
id=str2num(id);
istart=1;%(id-1)*section+1;
istop=section;
ds_factor=10;

for islice=id
    cd(datapath);
    filename0=dir(strcat('co-',num2str(islice),'-*.dat')); 
    for iFile=istart:istop
        name=strsplit(filename0(1).name,'.');  
        name_dat=strsplit(name{1},'-');
        slice_index=islice;
        % Xrpt and Yrpt are x and y scan repetition, default = 1
        Zsize = str2num(name_dat{4}); Xrpt = 1; Xsize=str2num(name_dat{5}); Yrpt = 1; Ysize = str2num(name_dat{6});
        dim1=[Zsize Xrpt Xsize Yrpt Ysize];     % tile size for reflectivity 
        name1=strcat(datapath,'co-',num2str(islice),'-',num2str(iFile),'-',num2str(Zsize),'-',num2str(Xsize),'-',num2str(Ysize),'.dat'); % gen file name for reflectivity
        if isfile(name1)
            % load reflectivity data
            co = ReadDat_int16(name1, dim1)./65535*4; 
            name1=strcat(datapath,'cross-',num2str(islice),'-',num2str(iFile),'-',num2str(Zsize),'-',num2str(Xsize),'-',num2str(Ysize),'.dat'); % gen file name for reflectivity
            % load reflectivity data
            cross = ReadDat_int16(name1, dim1)./65535*4; 
        else
            co=zeros(Zsize,Xsize,Ysize);
            cross=zeros(Zsize,Xsize,Ysize);
        end
        message=strcat('Tile No. ',string(iFile),' is read.', datestr(now,'DD:HH:MM'),'\n');
        fprintf(message);
        
        %% run this if the tissue surface is too shallow
%         tmp=co(1:end-20,:,:);
%         co(1:20,:,:)=co(end-19:end,:,:);
%         co(21:end,:,:)=tmp;
% 
%         tmp=cross(1:end-20,:,:);
%         cross(1:20,:,:)=cross(end-19:end,:,:);
%         cross(21:end,:,:)=tmp;
        %%
        Optical_fitting_TDE(co, cross,islice, iFile, folder);
%         Optical_fitting(co, cross, islice, iFile, folder, 0.019, 130, 80)
    end
%     rewrite_aip_tiles(folder,islice,numX*numY);
    rewrite_bfg_tiles(folder,islice,numX*numY);
    Bfg_stitch('bfg', P2path,folder,disp,mosaic,pxlsize./ds_factor,islice,pattern,sys,ds_factor);
%     BKG_stitch('BKG', P2path, folder,disp,mosaic,pxlsize./ds_factor,islice,pattern,sys,ds_factor);
%     MIP_stitch('mip', P2path,folder,disp,mosaic,pxlsize,islice,pattern,sys);
%     Ret_stitch('ret_aip', P2path,folder,disp,mosaic,pxlsize,islice,pattern,sys);  
%     AIP_stitch(P2path,folder,disp,mosaic,pxlsize,islice,pattern,sys); 
    rewrite_mus_tiles(folder,islice,numX*numY);
    Mus_stitch('mus',P2path,folder,disp,mosaic,pxlsize./ds_factor,islice,pattern,sys,ds_factor);           % stitch mus
    rewrite_mub_tiles(folder,islice,numX*numY);
    Mub_stitch('mub', P2path,folder,disp,mosaic,pxlsize./ds_factor,islice,pattern,sys,ds_factor);
%     BaSiC_shading_and_ref_stitch(islice,P2path,folder, numX*numY, 60, 44); %8790:70, 7524:60, NC4: 60
    R2_stitch('R2', P2path, folder,disp,mosaic,pxlsize./ds_factor,islice,pattern,sys,ds_factor);
    ZF_stitch('zf', P2path, folder,disp,mosaic,pxlsize./ds_factor,islice,pattern,sys,ds_factor);
    ZR_stitch('zr', P2path, folder,disp,mosaic,pxlsize./ds_factor,islice,pattern,sys,ds_factor);
    message=strcat('slice No. ',string(islice),' is fitted and stitched.', datestr(now,'DD:HH:MM'),'\n');
    fprintf(message);
end


