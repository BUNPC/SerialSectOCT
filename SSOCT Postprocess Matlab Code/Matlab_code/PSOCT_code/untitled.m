folder  = '/projectnb2/npbssmic/ns/remote_folder/';
P2path = '/projectnb2/npbssmic/ns/feature_paper_sample/';   % 2P file path
datapath=strcat(folder,'dist_corrected/'); 

% add subfunctions for the script. Change directory if not running on BU SCC
addpath('/projectnb/npbssmic/s/Matlab_code/fitting_code');
addpath('/projectnb/npbssmic/s/Matlab_code/PostProcessing');
addpath('/projectnb/npbssmic/s/Matlab_code/PSOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code/ThorOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code');

cd(datapath);
ntile=270;
nslice=108; % define total number of slices
njobs=1;
section=ceil(ntile/njobs);

sys = 'PSOCT';
% specify mosaic parameters, you can get it from Imagej stitching
xx=866;    % xx is the X displacement of two adjacent tile align in the X direction
xy=0;     % xy is the Y displacement of two adjacent tile align in the X direction, default to 0
yy=866;    % yy is the Y displacement of two adjacent tile align in the Y direction
yx=0;      % xx is the X displacement of two adjacent tile align in the Y direction, default to 0
numX=18;    % #tiles in X direction
numY=15;    % #tiles in Y direction
Xoverlap=0.15;   % overlap in X direction
Yoverlap=0.15;   % overlap in Y direction
disp=[xx xy yy yx];
mosaic=[numX numY Xoverlap Yoverlap];
pattern = 'bidirectional';  % mosaic pattern, could be bidirectional or unidirectional
pxlsize=[1000 1000];

% the $SGE-TASK-ID environment variable read in is CHARACTER, need to transfer to number
id=36;%str2num(id);
istart=3;%(id-1)*section+1;
istop=section;

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
            co = ReadDat_int16(name1, dim1)./65535*2; 
            name1=strcat(datapath,'cross-',num2str(islice),'-',num2str(iFile),'-',num2str(Zsize),'-',num2str(Xsize),'-',num2str(Ysize),'.dat'); % gen file name for reflectivity
            % load reflectivity data
            cross = ReadDat_int16(name1, dim1)./65535*2; 
        else
            co=zeros(Zsize,Xsize,Ysize);
            cross=zeros(Zsize,Xsize,Ysize);
        end
        message=strcat('Tile No. ',string(iFile),' is read.', datestr(now,'DD:HH:MM'),'\n');
        fprintf(message);
        
        Optical_fitting_immune2surf(co, cross,islice, iFile, folder, 0.018, 130, 80, 60);
         
    end
%     rewrite_aip_tiles(folder,islice,numX*numY);
    Bfg_stitch('bfg', P2path,folder,disp,mosaic,pxlsize./10,islice,pattern,sys);
    MIP_stitch('mip', P2path,folder,disp,mosaic,pxlsize,islice,pattern,sys);
    Ret_stitch('ret_aip', P2path,folder,disp,mosaic,pxlsize,islice,pattern,sys);  
    AIP_stitch(P2path,folder,disp,mosaic,pxlsize,islice,pattern,sys);  
    Mus_stitch('mus',P2path,folder,disp,mosaic,pxlsize./10,islice,pattern,sys);           % stitch mus
    Mub_stitch('mub', P2path,folder,disp,mosaic,pxlsize./10,islice,pattern,sys);
    BaSiC_shading_and_ref_stitch(islice,P2path,folder, 270, 65, 44); 
    message=strcat('slice No. ',string(islice),' is fitted and stitched.', datestr(now,'DD:HH:MM'),'\n');
    fprintf(message);
end


