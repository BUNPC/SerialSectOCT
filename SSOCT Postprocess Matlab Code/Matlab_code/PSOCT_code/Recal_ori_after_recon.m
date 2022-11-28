datapath  = '/projectnb2/npbssmic/ns/PSOCT-qBRM_fiber_struct/sample03/';
P2path = '/projectnb2/npbssmic/ns/PSOCT-qBRM_fiber_struct/sample03_2P/';   % 2P file path
reconpath=strcat(datapath,'dist_corrected/'); 

% add subfunctions for the script. Change directory if not running on BU SCC
addpath('/projectnb/npbssmic/s/Matlab_code/fitting_code');
addpath('/projectnb/npbssmic/s/Matlab_code/PostProcessing');
addpath('/projectnb/npbssmic/s/Matlab_code/PSOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code/ThorOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code');

cd(reconpath);
ntile=14*7;
nslice=10; % define total number of slices
njobs=1;
section=ceil(ntile/njobs);
sys='PSOCT';
xx=780;    % xx is the X displacement of two adjacent tile align in the X direction
xy=0;     % xy is the Y displacement of two adjacent tile align in the X direction, default to 0
yy=780;    % yy is the Y displacement of two adjacent tile align in the Y direction
yx=0;      % xx is the X displacement of two adjacent tile align in the Y direction, default to 0
numX=14;    % #tiles in X direction
numY=7;    % #tiles in Y direction
Xoverlap=0.23;   % overlap in X direction
Yoverlap=0.23;   % overlap in Y direction
disp=[xx xy yy yx];
mosaic=[numX numY Xoverlap Yoverlap];
pxlsize=[1000 1000];
pattern = 'bidirectional';  % mosaic pattern, could be bidirectional or unidirectional
% load distortion corre
% the $SGE-TASK-ID environment variable read in is CHARACTER, need to transfer to number
id=1;%str2num(id);
istart=11;%(id-1)*section+1;
istop=section;

for islice=id
    cd(reconpath);
    filename0=dir(strcat('ori-',num2str(islice),'-*.dat')); 
    for iFile=istart:istop
        name=strsplit(filename0(1).name,'.');  
        name_dat=strsplit(name{1},'-');
        slice_index=islice;
        % Xrpt and Yrpt are x and y scan repetition, default = 1
        Zsize = str2num(name_dat{4}); Xrpt = 1; Xsize=str2num(name_dat{5}); Yrpt = 1; Ysize = str2num(name_dat{6});
        dim1=[Zsize Xrpt Xsize Yrpt Ysize];     % tile size for reflectivity 
        name1=strcat(reconpath,'ori-',num2str(islice),'-',num2str(iFile),'-',num2str(Zsize),'-',num2str(Xsize),'-',num2str(Ysize),'.dat'); % gen file name for reflectivity
        if isfile(name1)
            % load reflectivity data
            ori = ReadDat_int16(name1, dim1)./65535*180; 
        else
            ori=zeros(Zsize,Xsize,Ysize);
        end
        message=strcat('Tile No. ',string(iFile),' is read.', datestr(now,'DD:HH:MM'),'\n');
        fprintf(message);
        load(strcat(datapath,'surf/vol',num2str(islice),'/',num2str(iFile),'.mat'));
%         sur=round(sur-min(sur(:)));
        [X Y]=meshgrid(0.1:100);
        [Xv Yv]=meshgrid(0.1:0.0991:99.1);
        Vq=interp2(X,Y,sur,Xv,Yv);
        sur=round(Vq);
        
        ori2D=Gen_ori_2D(ori,sur,40);
        
        % Saving orientation ORI.tif
        ori2D=single(ori2D);
        tiffname=strcat(datapath,'orientation/vol',num2str(slice_index),'/','ORI.tif');
        if iFile==1
            t = Tiff(tiffname,'w');
        else
            t = Tiff(tiffname,'a');
        end
        tagstruct.ImageLength     = size(ori2D,1);
        tagstruct.ImageWidth      = size(ori2D,2);
        tagstruct.SampleFormat    = Tiff.SampleFormat.IEEEFP;
        tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
        tagstruct.BitsPerSample   = 32;
        tagstruct.SamplesPerPixel = 1;
        tagstruct.Compression     = Tiff.Compression.None;
        tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
        tagstruct.Software        = 'MATLAB';
        t.setTag(tagstruct);
        t.write(ori2D);
        t.close();

    end
    Ori_stitch('ori2D', P2path,datapath,disp,mosaic,pxlsize,islice,pattern,sys); 
    message=strcat('slice No. ',string(islice),' is fitted and stitched.', datestr(now,'DD:HH:MM'),'\n');
    fprintf(message);
end


