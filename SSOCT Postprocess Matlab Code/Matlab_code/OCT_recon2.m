%% ----------------------------------------- %%
% Note Jan 28 2020:
%
% Current version of code does FOV correction, grid correction & MIP/AIP
% generation, surface finding & profiling, mosacing & blending
%
% Suggested parallelization method: one slice per thread
% 
% volume stitching is currently in another code
%
% Note Oct 28 2019:
%
% Current version of code does FOV correction, grid correction & MIP/AIP
% generation, surface finding & profiling, mosacing & blending
% 
% volume stitching is currently in another code
%
% Note Nov 5 2019:
% 
% All parameters were moved to the beginning of the script
% volume stitching is currently in another code
%
% Note 09/02/2020
%
% Current version of code does FOV correction(optional), grid correction(optional) & MIP/AIP
% generation, surface finding & profiling, mosacing & blending
%
%
% Author: Jiarui Yang, Shuaibin Chang
%%%%%%%%%%%%%%%%%%%%%%%
%%
% add subfunctions for the script. Change directory if not running on BU SCC
addpath('/projectnb/npbssmic/s/Matlab_code/fitting_code');
addpath('/projectnb/npbssmic/s/Matlab_code/PostProcessing');
addpath('/projectnb/npbssmic/s/Matlab_code/PSOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code/ThorOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code');
addpath('/projectnb/npbssmic/s/Matlab_code/gpufit_Anna');
% specify dataset directory
datapath  = '/projectnb2/npbssmic/ns/Ann_Mckee_samples_20T/Ann_NC3/'; % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!
P2path = '/projectnb2/npbssmic/ns/Ann_Mckee_samples_20T/Ann_NC3_2P/';   % 2P file path !!!!!!!!!!!!!!
nslice=99; % define total number of slice !!!!!!!!!!!!!!!!!!!!!!!!!!!
njobs=1; % number of jobs per slice in SCC parallel processing, default to be 1
% specify OCT system name
sys = 'PSOCT';
% specify mosaic parameters, you can get it from Imagej stitching
%% xx yy is positive for dataset acquired after sep 06
xx=866;    % xx is the X displacement of two adjacent tile align in the X direction
xy=0;     % xy is the Y displacement of two adjacent tile align in the X direction, default to 0
yy=866;    % yy is the Y displacement of two adjacent tile align in the Y direction
yx=0;      % xx is the X displacement of two adjacent tile align in the Y direction, default to 0
numX=11;    % #tiles in X direction !!!!!!!!!!!!!!!!!!
numY=9;    % #tiles in Y direction  !!!!!!!!!!!!!!!!!
Xoverlap=0.15;   % overlap in X direction
Yoverlap=0.15;   % overlap in Y direction
disp=[xx xy yy yx];
mosaic=[numX numY Xoverlap Yoverlap];
pxlsize=[1000 1000];
pattern = 'bidirectional';  % mosaic pattern, could be bidirectional or unidirectional
% load distortion correction matrixes, Optional
if(strcmp(sys,'PSOCT'))
    folder_distort='/projectnb2/npbssmic/ns/distortion_correction/OCT_grid_after_2021sep/';                     
    fileID = fopen(strcat(folder_distort,'grid matrix.bin'), 'r'); 
    grid_matrix = fread(fileID,'double');
    fclose(fileID);
    grid_matrix=reshape(grid_matrix, 4,1100,1100);
end
% directory that stores distortion corrected 3D tiles. Optional
corrected_path=strcat(datapath,'dist_corrected/'); 
mkdir(strcat(datapath,'dist_corrected'));
mkdir(strcat(datapath,'dist_corrected/volume'));
cd([datapath,'dist_corrected']);
filename0=dir(strcat('co-1-*.dat')); % count #tiles per slice
fn_co = dir(strcat('co-1-*.dat'));
fn_cross = dir(strcat('cross-1-*.dat'));
ntile=length(filename0);

% the $SGE-TASK-ID environment variable read in is CHARACTER, need to transfer to number
id=1;%str2num(id);   % set to 1 for debugging !!!!!!!!!!!!!
section=ceil(ntile/njobs);
istart=1;%(id-1)*section+1;
istop=section;
% create folder for AIPs and MIPs
create_dir(nslice, datapath);  
if ~isfile(strcat(datapath,'surface.mat'))
    Hui_sum_all(datapath,ntile, 1,300);
end
load(strcat(datapath,'surface.mat'));
surface=round(surface-min(surface(:)));

for islice=id
    for iFile=istart:istop
        % Generate filename, volume dimension before loading file
        name=strsplit(filename0(iFile).name,'.');  
        name_dat=strsplit(name{1},'-');
        slice_index=islice;
        coord=num2str(iFile);
        % Xrpt and Yrpt are x and y scan repetition, default = 1
        Zsize = str2num(name_dat{3}); Xrpt = 1; Xsize=str2num(name_dat{4}); Yrpt = 1; Ysize = str2num(name_dat{5});
        dim1=[Zsize Xrpt Xsize Yrpt Ysize];     % tile size for reflectivity 
        if strcmp(sys,'Thorlabs')
            dim1=[400 1 400 1 400];
        end
        name1=strcat(num2str(islice),'-',num2str(iFile),'-',num2str(Zsize),'-',num2str(Xsize),'-',num2str(Ysize),'-AB.dat'); 
        % load data
        co = importdata([datapath,'dist_corrected/',fn_co(1).name]);
        cross = importdata([datapath,'dist_corrected/',fn_cross(1).name]);
         % Optical property fitting
         Optical_gpufit(co, cross,islice, coord, datapath);
         
         % Generating AIP, MIP, retardance AIP in mat
         start_pixel=70; % approx +40 px from straing point !!!!!!!!!!!!!!!!!!!!!!!
         mip=squeeze(max(ref(start_pixel:start_pixel+50,:,:),[],1)); % start depth needs to be configured for each sample
         aip=squeeze(mean(ref(start_pixel:start_pixel+50,:,:),1));
         ret_aip=squeeze(mean(ret(start_pixel:start_pixel+100,:,:),1));
         
        % Saving AIP.tif
        aip=single(aip);
        tiffname=strcat(datapath,'aip/vol',num2str(slice_index),'/','AIP.tif');
        if str2num(coord)==1
            t = Tiff(tiffname,'w');
        else
            t = Tiff(tiffname,'a');
        end
        tagstruct.ImageLength     = size(aip,1);
        tagstruct.ImageWidth      = size(aip,2);
        tagstruct.SampleFormat    = Tiff.SampleFormat.IEEEFP;
        tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
        tagstruct.BitsPerSample   = 32;
        tagstruct.SamplesPerPixel = 1;
        tagstruct.Compression     = Tiff.Compression.None;
        tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
        tagstruct.Software        = 'MATLAB';
        t.setTag(tagstruct);
        t.write(aip);
        t.close();
        
       
        if(strcmp(sys,'PSOCT'))
            % Saving retardance AIP.tif
            ret_aip=single(ret_aip);
            tiffname=strcat(datapath,'retardance/vol',num2str(slice_index),'/','RET.tif');
            if str2num(coord)==1
                t = Tiff(tiffname,'w');
            else
                t = Tiff(tiffname,'a');
            end
            tagstruct.ImageLength     = size(ret_aip,1);
            tagstruct.ImageWidth      = size(ret_aip,2);
            tagstruct.SampleFormat    = Tiff.SampleFormat.IEEEFP;
            tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
            tagstruct.BitsPerSample   = 32;
            tagstruct.SamplesPerPixel = 1;
            tagstruct.Compression     = Tiff.Compression.None;
            tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
            tagstruct.Software        = 'MATLAB';
            t.setTag(tagstruct);
            t.write(ret_aip);
            t.close();
        end

        % Saving MIP.tif
        mip=single(mip);
        tiffname=strcat(datapath,'mip/vol',num2str(slice_index),'/','MIP.tif');
        if str2num(coord)==1
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
        fprintf(strcat('Tile No. ',coord,' is reconstructed.', datestr(now,'DD:HH:MM'),'\n'));
    end   
    
%% Stitching
    AIP_stitch(P2path,datapath,disp,mosaic,pxlsize,islice,pattern,sys);                     % stitch AIP
    Mus_stitch('mus',P2path,datapath,disp,mosaic,pxlsize./4,islice,pattern,sys);           % stitch mus
    Mub_stitch('mub', P2path,datapath,disp,mosaic,pxlsize./4,islice,pattern,sys);           % stitch mub
%     Bfg_stitch('bfg', P2path,datapath,disp,mosaic,pxlsize./4,islice,pattern,sys);
%     MIP_stitch('mip', P2path,datapath,disp,mosaic,pxlsize,islice,pattern,sys);
    Surf_stitch('sur',P2path,datapath,disp,mosaic,pxlsize/10,islice,pattern,sys);              % stitch surface
    Ret_stitch('ret_aip', P2path,datapath,disp,mosaic,pxlsize,islice,pattern,sys);              % stitch retardance AIP
    BaSiC_shading_and_ref_stitch(id,P2path,datapath, 61, 44); % start depth, thickness(pixels): volume recon start depth needs to be configured for each sample
    fprintf(strcat('Slice No. ',num2str(islice),' is stitched.', datestr(now,'DD:HH:MM'),'\n'));

end
fid=fopen(strcat(datapath,'aip/log',num2str(id),'.txt'),'w');
fclose(fid);
cd(strcat(datapath,'aip/'))
logfiles=dir(strcat(datapath,'aip/log*.txt')); 
if length(logfiles)==nslice
    delete log*.txt
   Concat_ref_vol(nslice,datapath);
   ref_mus(datapath, nslice, nslice*11, 50); % volume intensity correction, comment the mus part if no fitting is generated
end