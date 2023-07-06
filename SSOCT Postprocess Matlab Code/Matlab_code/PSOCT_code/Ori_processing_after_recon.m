% specify dataset directory
OCTpath  = '/projectnb2/npbssmic/ns/remote_folder/';  % OCT data path. 
datapath=strcat(OCTpath,'dist_corrected/'); 
P2path = '/projectnb2/npbssmic/ns/Ann_Mckee_samples_20T/NC_6839_2P/';   % 2P file path
% add subfunctions for the script. Change directory if not running on BU SCC
addpath('/projectnb/npbssmic/s/Matlab_code/fitting_code');
addpath('/projectnb/npbssmic/s/Matlab_code/PostProcessing');
addpath('/projectnb/npbssmic/s/Matlab_code/PSOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code/ThorOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code');
cd(datapath);

filename0=dir(strcat('ori-2-*.dat')); % count #tiles per slice
ntile=1419;%length(filename0);
nslice=2; % define total number of slices
create_dir(nslice, OCTpath);  
njobs=nslice;
section=ceil(nslice/njobs);
%     the $SGE-TASK-ID environment variable read in is CHARACTER, need to transfer to number
id=2;%str2num(id);
istart=(id-1)*section+1;
istop=id*section;
cd(datapath);
for islice=istart:istop
    cd(datapath);
    for iFile=1:ntile
        filename0=dir(strcat('ori-',num2str(islice),'-',num2str(iFile),'-*.dat'));
        if length(filename0)==1
            name=strsplit(filename0(1).name,'.');  
            name_dat=strsplit(name{1},'-');
            slice_index=islice;
            % Xrpt and Yrpt are x and y scan repetition, default = 1
            Zsize = str2num(name_dat{4}); Xrpt = 1; Xsize=str2num(name_dat{5}); Yrpt = 1; Ysize = str2num(name_dat{6});
            dim1=[Zsize Xrpt Xsize Yrpt Ysize];     % tile size for reflectivity 
            name1=strcat('ori-',num2str(islice),'-',num2str(iFile),'-',num2str(Zsize),'-',num2str(Xsize),'-',num2str(Ysize),'.dat'); % gen file name for reflectivity

            % load reflectivity data
            ifilePath = [datapath,name1];
            ori = ReadDat_int16(ifilePath, dim1)./65535*180; 
           
            message=strcat('Tile No. ',string(iFile),' is read.', datestr(now,'DD:HH:MM'),'\n');
            fprintf(message);
            filename=strcat(OCTpath,'/surf/vol',num2str(islice),'/',num2str(iFile),'.mat'); 
            load(filename);
            [X Y]=meshgrid(0.1:30);
            [Xv Yv]=meshgrid(0.1:0.0991:29.8);
            Vq=interp2(X,Y,sur,Xv,Yv);
            sur=round(Vq);
            ori2D=Gen_ori_2D(ori,sur,40);

            % Saving retardance AIP.tif
            Ori2D=single(Ori2D);
            tiffname=strcat(OCTpath,'orientation/vol',num2str(islice),'/','ORI.tif');
            SaveTiff(Ori2D,1,tiffname);
        else
            Ori2D=single(zeros(1000,1000));
            tiffname=strcat(OCTpath,'orientation/vol',num2str(islice),'/','ORI.tif');
            SaveTiff(Ori2D,1,tiffname);
        end
        
    end
    sys = 'PSOCT';
    % specify mosaic parameters, you can get it from Imagej stitching
    xx=200;    % xx is the X displacement of two adjacent tile align in the X direction
    xy=0;     % xy is the Y displacement of two adjacent tile align in the X direction, default to 0
    yy=200;    % yy is the Y displacement of two adjacent tile align in the Y direction
    yx=0;      % xx is the X displacement of two adjacent tile align in the Y direction, default to 0
    numX=43;    % #tiles in X direction                                                            ADJUST FOR EACH SAMPLE!!!
    numY=33;    % #tiles in Y direction                                                            ADJUST FOR EACH SAMPLE!!!
    Xoverlap=0.24;   % overlap in X direction
    Yoverlap=0.24;   % overlap in Y direction
    disp=[xx xy yy yx];
    mosaic=[numX numY Xoverlap Yoverlap];
    pxlsize=[300 300];
    pattern = 'bidirectional'; 
    stitch=1;
    Ori_stitch('ori2D', P2path,OCTpath,disp,mosaic,pxlsize,islice,pattern,sys,stitch,0.04);                    % stitch orientation
    Gen_ori_RGB(OCTpath,islice, 0.015);
    message=strcat('slcie No. ',string(islice),' is stitched.', datestr(now,'DD:HH:MM'),'\n');
    fprintf(message);
end
