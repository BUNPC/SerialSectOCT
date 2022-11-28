% specify mosaic parameters
%% xx yy is positive for dataset acquired after sep 06
xx=1280;    % xx is the X displacement of two adjacent tile align in the X direction
% xx=1440;
xy=0;     % xy is the Y displacement of two adjacent tile align in the X direction, default to 0
yy=1280;    % yy is the Y displacement of two adjacent tile align in the Y direction
% yy=1440;
yx=0;      % xx is the X displacement of two adjacent tile align in the Y direction, default to 0
numX=10;    % #tiles in X direction !!!!!!!!!
numY=10;    % #tiles in Y direction !!!!!!!!!
Xoverlap=0.1;   % overlap in X direction
Yoverlap=0.1;   % overlap in Y direction
disp=[xx xy yy yx];
mosaic=[numX numY Xoverlap Yoverlap];
pattern = 'bidirectional';  % mosaic pattern, could be bidirectional or unidirectional
% pick three depth planes for generating stitching coordinates, three
% planes should evenly distribute along volume depth, with no saturated tiles
stitch_plane1=4;
stitch_plane2=10;
stitch_plane3=16;

% specify dataset directory
datapath  = '/projectnb2/npbssmic/ns/Ann_Mckee_samples_20T/NC_7597_2P/'; %  !!!!!!!!! 
nslice=24; % total number of slices !!!!!!!!!
njobs=nslice; %number jobs in SCC parallel processing
ntile=numX*numY; % total number of tiles per slice
pxlsize=[1500 1500];
% add subfunctions for the script. Change directory if not running on BU SCC
addpath('/projectnb/npbssmic/s/Matlab_code/fitting_code');
addpath('/projectnb/npbssmic/s/Matlab_code/PostProcessing');
addpath('/projectnb/npbssmic/s/Matlab_code/PSOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code/ThorOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code');
% load distortion correction matrixes, Optional
folder_distort='/projectnb2/npbssmic/ns/distortion_correction/2P_grid_after_2021sep/';                     
fileID = fopen(strcat(folder_distort,'grid matrix.bin'), 'r'); 
grid_matrix = fread(fileID,'double');
fclose(fileID);
grid_matrix=reshape(grid_matrix, 4,1700,1700);

%% SCC parrallel processing configuration
id=str2num(id);
slice_job=nslice/njobs;
istart=(id-1)*ntile*slice_job+1;
istop=id*ntile*slice_job;

create_dir(nslice, datapath); 
cd(datapath)
filename0=dir(strcat('file*.tif')); 

for iFile=istart:istop
    name=strsplit(filename0(iFile).name,'.');  
    name_dat=strsplit(name{1},'_');
    coord=str2num(name_dat{2});
    slice_index=floor((coord-1)/ntile)+1;
    tile_index=mod(coord-1,ntile)+1;
    % load each tile
    imageData1 = double(imread(filename0(iFile).name, 1));
    imageData2 = double(imread(filename0(iFile).name, 2));

    % distortion correction
     clear channel1
     clear channel2
     channel1(1,:,:) = imageData1(66:1765,290:1989); % Cut spare FOV and get rid of extreme distortion at the edge of FOV
     channel2(1,:,:) = imageData2(66:1765,290:1989);
     channel1 = squeeze(Grid_correction(channel1, grid_matrix, 1600, 101, 1600, 101, 1));      
     channel2 = squeeze(Grid_correction(channel2, grid_matrix, 1600, 101, 1600, 101, 1)); 
     channel1=imrotate(channel1,90);
     channel2=imrotate(channel2,90);
     
    % save tiles 
    channel1=single(channel1);
    tiffname=strcat(datapath,'aip/vol',num2str(slice_index),'/','Channel1.tif');
    if(tile_index==1)
        t = Tiff(tiffname,'w');
    else
        t = Tiff(tiffname,'a');
    end
    tagstruct.ImageLength     = size(channel1,1);
    tagstruct.ImageWidth      = size(channel1,2);
    tagstruct.SampleFormat    = Tiff.SampleFormat.IEEEFP;
    tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
    tagstruct.BitsPerSample   = 32;
    tagstruct.SamplesPerPixel = 1;
    tagstruct.Compression     = Tiff.Compression.None;
    tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
    tagstruct.Software        = 'MATLAB';
    t.setTag(tagstruct);
    t.write(channel1);
    t.close();

    channel2=single(channel2);
    tiffname=strcat(datapath,'aip/vol',num2str(slice_index),'/','Channel2.tif');
    if(tile_index==1)
        t = Tiff(tiffname,'w');
    else
        t = Tiff(tiffname,'a');
    end
    tagstruct.ImageLength     = size(channel2,1);
    tagstruct.ImageWidth      = size(channel2,2);
    tagstruct.SampleFormat    = Tiff.SampleFormat.IEEEFP;
    tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
    tagstruct.BitsPerSample   = 32;
    tagstruct.SamplesPerPixel = 1;
    tagstruct.Compression     = Tiff.Compression.None;
    tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
    tagstruct.Software        = 'MATLAB';
    t.setTag(tagstruct);
    t.write(channel2);
    t.close();
end   

%% write macro script for BaSiC shading correction
for islice=((id-1)*slice_job+1):id*slice_job
    macropath=strcat(datapath,'aip/vol',num2str(islice),'/BaSiC.ijm');
    cor_filename=strcat(datapath,'aip/vol',num2str(islice),'/','Channel1_cor.tif');
    fid_Macro = fopen(macropath, 'w');
    filename=strcat(datapath,'aip/vol',num2str(islice),'/','Channel1.tif');
    fprintf(fid_Macro,'open("%s");\n',filename);
    fprintf(fid_Macro,'run("BaSiC ","processing_stack=Channel1.tif flat-field=None dark-field=None shading_estimation=[Estimate shading profiles] shading_model=[Estimate both flat-field and dark-field] setting_regularisationparametes=Automatic temporal_drift=Ignore correction_options=[Compute shading and correct images] lambda_flat=0.50 lambda_dark=0.50");\n');
    fprintf(fid_Macro,'selectWindow("Corrected:Channel1.tif");\n');
    fprintf(fid_Macro,'saveAs("Tiff","%s");\n',cor_filename);
    fprintf(fid_Macro,'close();\n');
    fprintf(fid_Macro,'close();\n');
    fprintf(fid_Macro,'close();\n');
    fprintf(fid_Macro,'close();\n');


    filename=strcat(datapath,'aip/vol',num2str(islice),'/','Channel2.tif');
    cor_filename=strcat(datapath,'aip/vol',num2str(islice),'/','Channel2_cor.tif');
    fprintf(fid_Macro,'open("%s");\n',filename);
    fprintf(fid_Macro,'run("BaSiC ","processing_stack=Channel2.tif flat-field=None dark-field=None shading_estimation=[Estimate shading profiles] shading_model=[Estimate both flat-field and dark-field] setting_regularisationparametes=Automatic temporal_drift=Ignore correction_options=[Compute shading and correct images] lambda_flat=0.50 lambda_dark=0.50");\n');
    fprintf(fid_Macro,'selectWindow("Corrected:Channel2.tif");\n');
    fprintf(fid_Macro,'saveAs("Tiff","%s");\n',cor_filename);
    fprintf(fid_Macro,'close();\n');
    fprintf(fid_Macro,'close();\n');
    fprintf(fid_Macro,'close();\n');
    fprintf(fid_Macro,'close();\n');
    fprintf(fid_Macro,'run("Quit");\n');
    fclose(fid_Macro);
    try
        system(['xvfb-run -a ' '/projectnb/npbssmic/ns/Fiji/Fiji.app/ImageJ-linux64 --run ',macropath]);
    catch
        display("shading correction failed");
    end
end

%% save shading corrected tiles
for islice=((id-1)*slice_job+1):id*slice_job
    cd(strcat(datapath,'aip/vol',num2str(islice)));
    filename0=strcat(datapath,'aip/vol',num2str(islice),'/','Channel1_cor.tif');
    filename0=dir(filename0);
    for iFile=1:ntile
        channel1 = double(imread(filename0(1).name, iFile));
        avgname=strcat(datapath,'aip/vol',num2str(islice),'/',num2str(iFile),'-channel1.mat');
        save(avgname,'channel1');  

        channel1=single(channel1);
        tiffname=strcat(datapath,'aip/vol',num2str(islice),'/',num2str(iFile),'-channel1.tif');
        t = Tiff(tiffname,'w');
        tagstruct.ImageLength     = size(channel1,1);
        tagstruct.ImageWidth      = size(channel1,2);
        tagstruct.SampleFormat    = Tiff.SampleFormat.IEEEFP;
        tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
        tagstruct.BitsPerSample   = 32;
        tagstruct.SamplesPerPixel = 1;
        tagstruct.Compression     = Tiff.Compression.None;
        tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
        tagstruct.Software        = 'MATLAB';
        t.setTag(tagstruct);
        t.write(channel1);
        t.close();
    end
    
    filename0=strcat(datapath,'aip/vol',num2str(islice),'/','Channel2_cor.tif');
    filename0=dir(filename0);
    for iFile=1:ntile
        channel2 = double(imread(filename0(1).name, iFile));%./shade1;
        avgname=strcat(datapath,'aip/vol',num2str(islice),'/',num2str(iFile),'-channel2.mat');
        save(avgname,'channel2');  

        channel2=single(channel2);
        tiffname=strcat(datapath,'aip/vol',num2str(islice),'/',num2str(iFile),'-channel2.tif');
        t = Tiff(tiffname,'w');
        tagstruct.ImageLength     = size(channel2,1);
        tagstruct.ImageWidth      = size(channel2,2);
        tagstruct.SampleFormat    = Tiff.SampleFormat.IEEEFP;
        tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
        tagstruct.BitsPerSample   = 32;
        tagstruct.SamplesPerPixel = 1;
        tagstruct.Compression     = Tiff.Compression.None;
        tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
        tagstruct.Software        = 'MATLAB';
        t.setTag(tagstruct);
        t.write(channel2);
        t.close();
    end
end  
%% log task and the lastly finished task stitch volumes
fid=fopen(strcat(datapath,'aip/log',num2str(id),'.txt'),'w');
fclose(fid);
cd(strcat(datapath,'aip/'))
logfiles=dir(strcat(datapath,'aip/log*.txt')); 
if length(logfiles)==njobs
    delete log*.txt;
    % Stitching
    fprintf('stitching\n');
    Gen_2P_coord(datapath,disp,mosaic,pxlsize,1,pattern, stitch_plane1, stitch_plane2, stitch_plane3);
    for islice = 1:nslice
        Stitch_2P(datapath,disp,mosaic,pxlsize,islice,pattern);         
        fprintf(strcat('Slice No. ',num2str(islice),' is stitched.', datestr(now,'DD:HH:MM'),'\n'));
    end
end

