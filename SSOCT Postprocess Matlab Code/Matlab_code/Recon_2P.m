%% specify data parameters
P2path  = '/projectnb2/npbssmic/ns/Ann_Mckee_samples_10T/NC_6974_2_2P/'; %                                    ADJUST FOR EACH SAMPLE!!!
nslice=28; % total number of slices                                                                         ADJUST FOR EACH SAMPLE!!!
%% specify mosaic parameters
% xx yy is positive for dataset acquired after sep 06
%% for default 10% overlap
xx=1280;    % xx is the X displacement of two adjacent tile align in the X direction
% xx=1440;
xy=0;     % xy is the Y displacement of two adjacent tile align in the X direction, default to 0
yy=1280;    % yy is the Y displacement of two adjacent tile align in the Y direction
% yy=1440;
yx=0;      % xx is the X displacement of two adjacent tile align in the Y direction, default to 0
numX=10;    % #tiles in X direction !!!!!!!!!                                                                ADJUST FOR EACH SAMPLE!!!
numY=7;    % #tiles in Y direction !!!!!!!!!                                                                ADJUST FOR EACH SAMPLE!!!
Xoverlap=0.1;   % overlap in X direction
Yoverlap=0.1;   % overlap in Y direction
%% for 30% overlap only
% xx=1150;    % xx is the X displacement of two adjacent tile align in the X direction
% % xx=1440;
% xy=0;     % xy is the Y displacement of two adjacent tile align in the X direction, default to 0
% yy=1180;    % yy is the Y displacement of two adjacent tile align in the Y direction
% % yy=1440;
% yx=0;      % xx is the X displacement of two adjacent tile align in the Y direction, default to 0
% numX=10;    % #tiles in X direction !!!!!!!!!                                                              ADJUST FOR EACH SAMPLE!!!
% numY=10;    % #tiles in Y direction !!!!!!!!!                                                              ADJUST FOR EACH SAMPLE!!!
% Xoverlap=0.1;   % overlap in X direction
% Yoverlap=0.1;   % overlap in Y direction
%%
disp=[xx xy yy yx];
mosaic=[numX numY Xoverlap Yoverlap];
pattern = 'bidirectional';  % mosaic pattern, could be bidirectional or unidirectional
%% pick three depth planes for generating stitching coordinates, three
% planes should evenly distribute along volume depth, with no saturated tiles
stitch_plane1=1;                                                                                           % ADJUST FOR EACH SAMPLE!!!
stitch_plane2=3;                                                                                          % ADJUST FOR EACH SAMPLE!!!
stitch_plane3=5;                                                                                          % ADJUST FOR EACH SAMPLE!!!

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

create_dir(nslice, P2path); 
cd(P2path)
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
    tiffname=strcat(P2path,'aip/vol',num2str(slice_index),'/','Channel1.tif');
    SaveTiff(channel1,tile_index,tiffname);

    channel2=single(channel2);
    tiffname=strcat(P2path,'aip/vol',num2str(slice_index),'/','Channel2.tif');
    SaveTiff(channel2,tile_index,tiffname);
    
end   

%% write macro script for BaSiC shading correction
for islice=((id-1)*slice_job+1):id*slice_job
    macropath=strcat(P2path,'aip/vol',num2str(islice),'/BaSiC.ijm');
    cor_filename=strcat(P2path,'aip/vol',num2str(islice),'/','Channel1_cor.tif');
    fid_Macro = fopen(macropath, 'w');
    filename=strcat(P2path,'aip/vol',num2str(islice),'/','Channel1.tif');
    fprintf(fid_Macro,'open("%s");\n',filename);
    fprintf(fid_Macro,'run("BaSiC ","processing_stack=Channel1.tif flat-field=None dark-field=None shading_estimation=[Estimate shading profiles] shading_model=[Estimate both flat-field and dark-field] setting_regularisationparametes=Automatic temporal_drift=Ignore correction_options=[Compute shading and correct images] lambda_flat=0.50 lambda_dark=0.50");\n');
    fprintf(fid_Macro,'selectWindow("Corrected:Channel1.tif");\n');
    fprintf(fid_Macro,'saveAs("Tiff","%s");\n',cor_filename);
    fprintf(fid_Macro,'close();\n');
    fprintf(fid_Macro,'close();\n');
    fprintf(fid_Macro,'close();\n');
    fprintf(fid_Macro,'close();\n');


    filename=strcat(P2path,'aip/vol',num2str(islice),'/','Channel2.tif');
    cor_filename=strcat(P2path,'aip/vol',num2str(islice),'/','Channel2_cor.tif');
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
        system(['xvfb-run -a ' '/projectnb/npbssmic/ns/Fiji/Fiji.app/ImageJ-linux64 --run ',macropath]);
    end
end

%% save shading corrected tiles
for islice=((id-1)*slice_job+1):id*slice_job
    cd(strcat(P2path,'aip/vol',num2str(islice)));
    filename0=strcat(P2path,'aip/vol',num2str(islice),'/','Channel1_cor.tif');
    filename0=dir(filename0);
    for iFile=1:ntile
        channel1 = double(imread(filename0(1).name, iFile));
        avgname=strcat(P2path,'aip/vol',num2str(islice),'/',num2str(iFile),'-channel1.mat');
        save(avgname,'channel1');  

        channel1=single(channel1);
        tiffname=strcat(P2path,'aip/vol',num2str(islice),'/',num2str(iFile),'-channel1.tif');
        SaveTiff(channel1,1,tiffname);
    end
    
    filename0=strcat(P2path,'aip/vol',num2str(islice),'/','Channel2_cor.tif');
    filename0=dir(filename0);
    for iFile=1:ntile
        channel2 = double(imread(filename0(1).name, iFile));%./shade1;
        avgname=strcat(P2path,'aip/vol',num2str(islice),'/',num2str(iFile),'-channel2.mat');
        save(avgname,'channel2');  

        channel2=single(channel2);
        tiffname=strcat(P2path,'aip/vol',num2str(islice),'/',num2str(iFile),'-channel2.tif');
        SaveTiff(channel2,1,tiffname);
    end
end  
%% log task and the lastly finished task stitch volumes
fid=fopen(strcat(P2path,'aip/log',num2str(id),'.txt'),'w');
fclose(fid);
cd(strcat(P2path,'aip/'))
logfiles=dir(strcat(P2path,'aip/log*.txt')); 
if length(logfiles)==njobs
    delete log*.txt;
    % Stitching
    fprintf('stitching\n');
    Gen_2P_coord(P2path,disp,mosaic,pxlsize,1,pattern, stitch_plane1, stitch_plane2, stitch_plane3);
    for islice = 1:nslice %nslice
        Stitch_2P(P2path,disp,mosaic,pxlsize,islice,pattern);         
        fprintf(strcat('Slice No. ',num2str(islice),' is stitched.', datestr(now,'DD:HH:MM'),'\n'));
    end
end

