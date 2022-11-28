folder= '/projectnb2/npbssmic/ns/Ann_Mckee_samples_20T/NC_6839/';
datapath=strcat(folder,'dist_corrected/'); 
P2path = '/projectnb2/npbssmic/ns/Ann_Mckee_samples_20T/NC_6839_2P/';   % 2P file path
% add subfunctions for the script. Change directory if not running on BU SCC
addpath('/projectnb/npbssmic/s/Matlab_code/fitting_code');
addpath('/projectnb/npbssmic/s/Matlab_code/PostProcessing');
addpath('/projectnb/npbssmic/s/Matlab_code/PSOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code/ThorOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code');
cd(datapath);

filename0=dir(strcat('ori-1-*.dat')); % count #tiles per slice
ntile=88;%length(filename0);
nslice=16; % define total number of slices
create_dir(nslice, folder);  
njobs=4;
section=ceil(nslice/njobs);
%     the $SGE-TASK-ID environment variable read in is CHARACTER, need to transfer to number
id=str2num(id);
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
            filename=strcat(folder,'/surf/vol',num2str(islice),'/',num2str(iFile),'.mat'); 
            load(filename);
            [X Y]=meshgrid(0.1:100);
             [Xv Yv]=meshgrid(0.1:0.0991:99.1);
             Vq=interp2(X,Y,sur,Xv,Yv);
             sur=round(Vq);
             Ori2D=Gen_ori_2D(ori,sur,40);

            % Saving retardance AIP.tif
            Ori2D=single(Ori2D);
            tiffname=strcat(folder,'orientation/vol',num2str(islice),'/','ORI.tif');
            if iFile==1
                t = Tiff(tiffname,'w');
            else
                t = Tiff(tiffname,'a');
            end
            tagstruct.ImageLength     = size(Ori2D,1);
            tagstruct.ImageWidth      = size(Ori2D,2);
            tagstruct.SampleFormat    = Tiff.SampleFormat.IEEEFP;
            tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
            tagstruct.BitsPerSample   = 32;
            tagstruct.SamplesPerPixel = 1;
            tagstruct.Compression     = Tiff.Compression.None;
            tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
            tagstruct.Software        = 'MATLAB';
            t.setTag(tagstruct);
            t.write(Ori2D);
            t.close();
        else
            Ori2D=single(zeros(1000,1000));
            tiffname=strcat(folder,'orientation/vol',num2str(islice),'/','ORI.tif');
            if iFile==1
                t = Tiff(tiffname,'w');
            else
                t = Tiff(tiffname,'a');
            end
            tagstruct.ImageLength     = size(Ori2D,1);
            tagstruct.ImageWidth      = size(Ori2D,2);
            tagstruct.SampleFormat    = Tiff.SampleFormat.IEEEFP;
            tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
            tagstruct.BitsPerSample   = 32;
            tagstruct.SamplesPerPixel = 1;
            tagstruct.Compression     = Tiff.Compression.None;
            tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
            tagstruct.Software        = 'MATLAB';
            t.setTag(tagstruct);
            t.write(Ori2D);
            t.close();
        end
        
    end
    sys = 'PSOCT';
    % specify mosaic parameters, you can get it from Imagej stitching
    xx=866;    % xx is the X displacement of two adjacent tile align in the X direction
    xy=0;     % xy is the Y displacement of two adjacent tile align in the X direction, default to 0
    yy=866;    % yy is the Y displacement of two adjacent tile align in the Y direction
    yx=0;      % xx is the X displacement of two adjacent tile align in the Y direction, default to 0
    numX=11;    % #tiles in X direction
    numY=8;    % #tiles in Y direction
    Xoverlap=0.07;   % overlap in X direction
    Yoverlap=0.07;   % overlap in Y direction
    disp=[xx xy yy yx];
    mosaic=[numX numY Xoverlap Yoverlap];
    pattern = 'bidirectional';  % mosaic pattern, could be bidirectional or unidirectional
    pxlsize=[1000 1000];

    Ori_stitch('ori2D', P2path,folder,disp,mosaic,pxlsize,islice,pattern,sys); 
    Gen_ori_RGB(folder,islice, 0.1);
    message=strcat('slcie No. ',string(islice),' is stitched.', datestr(now,'DD:HH:MM'),'\n');
    fprintf(message);
end
