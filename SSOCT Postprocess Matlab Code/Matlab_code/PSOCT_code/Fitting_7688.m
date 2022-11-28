folder='/projectnb2/npbssmic/ns/Ann_7688/';
datapath=strcat(folder,'dist_corrected/');
% add subfunctions for the script. Change directory if not running on BU SCC
addpath('/projectnb/npbssmic/s/Matlab_code/fitting_code');
addpath('/projectnb/npbssmic/s/Matlab_code/PostProcessing');
addpath('/projectnb/npbssmic/s/Matlab_code/PSOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code/ThorOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code');
cd(datapath);

filename0=dir(strcat('ref-1-*.dat')); % count #tiles per slice
ntile=length(filename0);
nslice=50; % define total number of slices
create_dir(nslice, folder);
cd(datapath);
id=str2num(id);
   njobs=1;
   section=ceil(ntile/njobs);
    % the $SGE-TASK-ID environment variable read in is CHARACTER, need to transfer to number

   istart=1;%(id-1)*section+1;
   istop=section;
% load('surface.mat');
for islice=id
    cd(datapath);
    filename0=dir(strcat('ref-1-*.dat')); 
    for iFile=istart:istop
        name=strsplit(filename0(iFile).name,'.');  
        name_dat=strsplit(name{1},'-');
        slice_index=islice;
%         coord=iFile;
        % Xrpt and Yrpt are x and y scan repetition, default = 1
        Zsize = str2num(name_dat{4}); Xrpt = 1; Xsize=str2num(name_dat{5}); Yrpt = 1; Ysize = str2num(name_dat{6});
        dim1=[Zsize Xrpt Xsize Yrpt Ysize];     % tile size for reflectivity 
%         dim1=[100 1 1100 1 1100];
        name1=strcat('ref-',num2str(islice),'-',num2str(iFile),'-',num2str(Zsize),'-',num2str(Xsize),'-',num2str(Ysize),'.dat'); % gen file name for reflectivity
        % load reflectivity data
        ifilePath = [datapath,name1];
        ref = single(ReadDat_int16(ifilePath, dim1))./65535*2; 
        name1=strcat('ret-',num2str(islice),'-',num2str(iFile),'-',num2str(55),'-',num2str(Xsize),'-',num2str(Ysize),'.dat'); % gen file name for reflectivity
        % load reflectivity data
        ifilePath = [datapath,name1];
        ret = single(ReadDat_int16(ifilePath, [55 1 1000 1 1000]))./65535*180; 

        message=strcat('Tile No. ',string(iFile),' is read.', datestr(now,'DD:HH:MM'),'\n');
        fprintf(message);

        start_pixel=10; % approx +40 px from straing point !!!!!!
        mip=squeeze(max(ref(start_pixel:start_pixel+60,:,:),[],1));
        mip=single(mip);
        tiffname=strcat(folder,'mip/vol',num2str(id),'/','MIP.tif');
        if iFile==1
            t = Tiff(tiffname,'w');
        else
            t = Tiff(tiffname,'a');
        end
        tagstruct.ImageLength     = size(mip,1);
        tagstruct.ImageWidth      = size(mip,2);
        tagstruct.SampleFormat    = Tiff.SampleFormat.IEEEFP;
        tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
        tagstruct.BitsPerSample   = 32;
        tagstruct.SamplesPerPixel = 1;
        tagstruct.Compression     = Tiff.Compression.None;
        tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
        tagstruct.Software        = 'MATLAB';
        t.setTag(tagstruct);
        t.write(mip);
        t.close();

        
        Optical_fitting_7688(ref,ret,islice, iFile, folder);

    end
    sys = 'PSOCT';
% specify mosaic parameters, you can get it from Imagej stitching
xx=-216;    % xx is the X displacement of two adjacent tile align in the X direction
xy=2;     % xy is the Y displacement of two adjacent tile align in the X direction, default to 0
yy=216;    % yy is the Y displacement of two adjacent tile align in the Y direction
yx=2;      % xx is the X displacement of two adjacent tile align in the Y direction, default to 0
numX=10;    % #tiles in X direction
numY=10;    % #tiles in Y direction
Xoverlap=0.15;   % overlap in X direction
Yoverlap=0.15;   % overlap in Y direction
disp=[xx xy yy yx];
mosaic=[numX numY Xoverlap Yoverlap];
pattern = 'bidirectional';  % mosaic pattern, could be bidirectional or unidirectional
pxlsize=[1000 1000];
% AIP_stitch(datapath,disp,mosaic,pxlsize,islice,pattern,sys);  
% Mus_stitch_7688('mus',folder,folder,disp,mosaic,pxlsize./10,islice,pattern,sys);           % stitch mus
% Mub_stitch_7688('mub', folder,folder,disp,mosaic,pxlsize./10,islice,pattern,sys);
% R2_stitch_7694('R2', folder, folder,disp,mosaic,pxlsize./10,islice,pattern,sys);
%     Ret_stitch('bfg', folder,disp,mosaic,pxlsize./4,islice,pattern,sys);
rewrite_aip_tiles(folder,islice,numX*numY);
Bfg_stitch_7688('bfg', folder, folder,disp,mosaic,pxlsize./10,islice,pattern,sys)
MIP_stitch_7688('mip', folder,folder,disp,mosaic,pxlsize,islice,pattern,sys)
end

