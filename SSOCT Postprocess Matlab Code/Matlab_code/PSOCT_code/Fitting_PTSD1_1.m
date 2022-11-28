
% id=str2num(id);

folder='/projectnb2/npbssmic/ns/Ann_PTSD1/Ann_PTSD1_1/';
datapath=strcat(folder,'dist_corrected/');
% add subfunctions for the script. Change directory if not running on BU SCC
addpath('/projectnb/npbssmic/s/Matlab_code/fitting_code');
addpath('/projectnb/npbssmic/s/Matlab_code/PostProcessing');
addpath('/projectnb/npbssmic/s/Matlab_code/PSOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code/ThorOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code');
cd(datapath);

filename0=dir(strcat('co-1-*.dat')); % count #tiles per slice
ntile=length(filename0);
nslice=9; % define total number of slices
create_dir(nslice, folder);
cd(datapath);

njobs=1;
section=ceil(ntile/njobs);
% the $SGE-TASK-ID environment variable read in is CHARACTER, need to transfer to number

istart=1;%(id-1)*section+1;
istop=0;%section;

for islice=1:9%id
    cd(datapath);
    filename0=dir(strcat('co-1-*.dat')); 
    for iFile=istart:istop
        name=strsplit(filename0(iFile).name,'.');  
        name_dat=strsplit(name{1},'-');
        slice_index=islice;
%         coord=num2str(iFile);
        % Xrpt and Yrpt are x and y scan repetition, default = 1
        Zsize = str2num(name_dat{4}); Xrpt = 1; Xsize=str2num(name_dat{5}); Yrpt = 1; Ysize = str2num(name_dat{6});
        dim1=[Zsize Xrpt Xsize Yrpt Ysize];     % tile size for reflectivity 

        name1=strcat('co-',num2str(islice),'-',num2str(iFile),'-',num2str(Zsize),'-',num2str(Xsize),'-',num2str(Ysize),'.dat'); % gen file name for reflectivity

        ifilePath = [datapath,name1];
        co = single(ReadDat_int16(ifilePath, dim1))./65535*2; 
        name1=strcat('cross-',num2str(islice),'-',num2str(iFile),'-',num2str(Zsize),'-',num2str(Xsize),'-',num2str(Ysize),'.dat'); % gen file name for reflectivity

        ifilePath = [datapath,name1];
        cross = single(ReadDat_int16(ifilePath, dim1))./65535*2; 
        message=strcat('Tile No. ',string(iFile),' is read.', datestr(now,'DD:HH:MM'),'\n');
        fprintf(message);

%         ref=sqrt(co.^2+cross.^2);
%             start_pixel=1; % approx +40 px from straing point !!!!!!
%             mip=squeeze(max(ref(start_pixel:start_pixel+60,:,:),[],1));
%             mip=single(mip);
%             tiffname=strcat(folder,'mip/vol',num2str(id),'/','MIP.tif');
%             if iFile==1
%                 t = Tiff(tiffname,'w');
%             else
%                 t = Tiff(tiffname,'a');
%             end
%             tagstruct.ImageLength     = size(mip,1);
%             tagstruct.ImageWidth      = size(mip,2);
%             tagstruct.SampleFormat    = Tiff.SampleFormat.IEEEFP;
%             tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
%             tagstruct.BitsPerSample   = 32;
%             tagstruct.SamplesPerPixel = 1;
%             tagstruct.Compression     = Tiff.Compression.None;
%             tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
%             tagstruct.Software        = 'MATLAB';
%             t.setTag(tagstruct);
%             t.write(mip);
%             t.close();
        %% for PTSD sample only
        % tissue surface too shallow
        tmp=co(1:end-20,:,:);
        co(1:20,:,:)=co(end-19:end,:,:);
        co(21:end,:,:)=tmp;

        tmp=cross(1:end-20,:,:);
        cross(1:20,:,:)=cross(end-19:end,:,:);
        cross(21:end,:,:)=tmp;

        Optical_fitting_PTSD1(co,cross,islice, iFile, folder);

    end
    sys = 'PSOCT';
% specify mosaic parameters, you can get it from Imagej stitching
xx=-216;    % xx is the X displacement of two adjacent tile align in the X direction
xy=2;     % xy is the Y displacement of two adjacent tile align in the X direction, default to 0
yy=216;    % yy is the Y displacement of two adjacent tile align in the Y direction
yx=2;      % xx is the X displacement of two adjacent tile align in the Y direction, default to 0
numX=11;    % #tiles in X direction
numY=9;    % #tiles in Y direction
Xoverlap=0.15;   % overlap in X direction
Yoverlap=0.15;   % overlap in Y direction
disp=[xx xy yy yx];
mosaic=[numX numY Xoverlap Yoverlap];
pattern = 'bidirectional';  % mosaic pattern, could be bidirectional or unidirectional
pxlsize=[1000 1000];
P2path=folder;%'/projectnb2/npbssmic/ns/Ann_PTSD1_1/';
% AIP_stitch(datapath,disp,mosaic,pxlsize,islice,pattern,sys);  
%     for islice=1:2
Mus_stitch_PTSD1('mus',P2path,folder,disp,mosaic,pxlsize./10,islice,pattern,sys);           % stitch mus
Mub_stitch_PTSD1('mub', P2path,folder,disp,mosaic,pxlsize./10,islice,pattern,sys);
R2_stitch_7694('R2', folder, folder,disp,mosaic,pxlsize./10,islice,pattern,sys)
%     %     Ret_stitch('bfg', folder,disp,mosaic,pxlsize./4,islice,pattern,sys);
% %     rewrite_aip_tiles(folder,islice,numX*numY);
% %     Bfg_stitch_PTSD1('bfg', P2path, folder,disp,mosaic,pxlsize./10,islice,pattern,sys)
% %     MIP_stitch_PTSD1('mip', P2path,folder,disp,mosaic,pxlsize,islice,pattern,sys)
%     end
end

