datapath='/projectnb2/npbssmic/ns/Hui_Wang_samples/SupFrontal/';

% add subfunctions for the script. Change directory if not running on BU SCC
addpath('/projectnb/npbssmic/s/Matlab_code/fitting_code');
addpath('/projectnb/npbssmic/s/Matlab_code/PostProcessing');
addpath('/projectnb/npbssmic/s/Matlab_code/PSOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code/ThorOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code');
cd(datapath);

filename0=dir(strcat('Jones_*.mat')); % count #tiles per slice
ntile=length(filename0);
nslice=1; % define total number of slices
create_dir(nslice, datapath);
cd(datapath);
id=str2num(id);
njobs=40;
section=ceil(ntile/njobs);
% the $SGE-TASK-ID environment variable read in is CHARACTER, need to transfer to number
istart=(id-1)*section+1;
istop=id*section;
load('surface.mat');
% load('sum_all.mat');
for islice=1
    cd(datapath);
    filename0=dir(strcat('Jones_*.mat')); 
    for iFile=istart:istop
        name=strcat('Jones_',num2str(iFile,'%03.f') ,'.mat');
%         name_dat=strsplit(name{1},'_');
        slice_index=islice;
        load(strcat(datapath,name));
%         IJones=IJones./sum;
        IJones=sqrt(IJones);
        message=strcat('Tile No. ',string(iFile),' is read.', datestr(now,'DD:HH:MM'),'\n');
        fprintf(message);
        IJones = FOV_curvature_correction(IJones, surface, size(IJones,1), size(IJones,2), size(IJones,3));  
        IJones=IJones(:,1:250,:);
        aip=single(squeeze(mean(IJones(111:200,:,:),1)));
%         save(strcat(datapath,'aip/vol1/aip',num2str(iFile),'.mat'),'aip');
%         tiffname=strcat(datapath,'aip/vol1/',num2str(iFile),'_aip','.tif');
%         t = Tiff(tiffname,'w');
%         tagstruct.ImageLength     = size(aip,1);
%         tagstruct.ImageWidth      = size(aip,2);
%         tagstruct.SampleFormat    = Tiff.SampleFormat.IEEEFP;
%         tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
%         tagstruct.BitsPerSample   = 32;
%         tagstruct.SamplesPerPixel = 1;
%         tagstruct.Compression     = Tiff.Compression.None;
%         tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
%         tagstruct.Software        = 'MATLAB';
%         t.setTag(tagstruct);
%         t.write(aip);
%         t.close();
        
        if mean2(aip)>500
            Optical_fitting_Hui_SupFrontal(IJones,islice, iFile, datapath);
        else
            Optical_fitting_Hui_SupFrontal(zeros(size(IJones)),islice, iFile, datapath);
        end

    end
end

sys = 'PSOCT';
% specify mosaic parameters, you can get it from Imagej stitching
xx=190;    % xx is the X displacement of two adjacent tile align in the X direction
xy=2;     % xy is the Y displacement of two adjacent tile align in the X direction, default to 0
yy=-190;    % yy is the Y displacement of two adjacent tile align in the Y direction
yx=2;      % xx is the X displacement of two adjacent tile align in the Y direction, default to 0
numX=40;    % #tiles in X direction
numY=30;    % #tiles in Y direction
Xoverlap=0.30;   % overlap in X direction
Yoverlap=0.30;   % overlap in Y direction
disp=[xx xy yy yx];
mosaic=[numX numY Xoverlap Yoverlap];
pattern = 'bidirectional';  % mosaic pattern, could be bidirectional or unidirectional
pxlsize=[250 350];
% AIP_stitch_Hui(datapath,disp,mosaic,pxlsize,islice,pattern,sys);  
Mus_stitch_Hui('mus',datapath,datapath,disp,mosaic,pxlsize./10,islice,pattern,sys);           % stitch mus
Mub_stitch_Hui('mub', datapath,datapath,disp,mosaic,pxlsize./10,islice,pattern,sys);
%     Ret_stitch('bfg', folder,disp,mosaic,pxlsize./4,islice,pattern,sys);
