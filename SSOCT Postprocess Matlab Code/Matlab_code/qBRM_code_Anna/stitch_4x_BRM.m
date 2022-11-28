clear all; close all; clc;
addpath('/projectnb/npbssmic/s/Matlab_code/qBRM_code_Anna')

StitchingType = 'Single-Plane';
AcquisitionType = 'ROI Imaging';

directory = '/projectnb/npbssmic/ns/PSOCT-qBRM_fiber_struct/fiber_sample02_BRM/sample_5.1_4x/exp5ms/corrected/';
fstack_and_stitch(directory, StitchingType);

directory = '/projectnb/npbssmic/ns/PSOCT-qBRM_fiber_struct/fiber_sample02_BRM/sample_5.1_4x/exp15ms/corrected/';
fstack_and_stitch(directory, StitchingType);

function fstack_and_stitch(directory, StitchingType)
    cd(directory);
    %run matlab focus stacking algorithm on all of z-plane images
    if strcmp(StitchingType, 'Multi-Plane')
        image = focus_stacking(directory);
        directory = [directory, '/IMG_STACKED/'];
    end
    %stitch images using FIJI
    Fiji_stitching(directory);
end

function Fiji_stitching(directory)
    %coord_file = dir('*_coordinates.mat');
    %load(coord_file.name, 'z_mesh');
    %grid_size = size(z_mesh);

    overlap = 10;
    gridx = 9;%grid_size(2);
    gridy = 6;%grid_size(1);

    macropath=[directory,'Macro.ijm'];
    fid_Macro = fopen(macropath, 'w');
    l = ['run("Memory & Threads...", "maximum=64000 parallel=8");\n'];
    fprintf(fid_Macro,l);
    command_str = sprintf('type=[Grid: snake by rows] order=[Left & Up                ] grid_size_x=%d grid_size_y=%d tile_overlap=%d first_file_index_i=1 directory=%s file_names=img_{iii}.tif output_textfile_name=TileConfiguration.txt fusion_method=[Linear Blending] regression_threshold=0.30 max/avg_displacement_threshold=2.50 absolute_displacement_threshold=3.50 compute_overlap computation_parameters=[Save computation time (but use more RAM)] image_output=[Write to disk] output_directory=%s', gridx, gridy, overlap, directory, directory);
    l=['run("Grid/Collection stitching", "', command_str,'");\n'];
    fprintf(fid_Macro,l);
    fclose(fid_Macro);
    system(['/projectnb/npbssmic/ns/Fiji/Fiji.app/ImageJ-linux64 --headless -macro ',macropath]);

end

function  image = focus_stacking(directory)
    cd(directory)
    mkdir('IMG_STACKED'); %create image sequence folder to save multiplane stitches
    Files=dir('*.tif');
    for k=1:length(Files) %for each z-stack file in the folder
       FileName=Files(k).name;
       FilePath = [directory, FileName];
       img_info = imfinfo(FilePath);
       for slice = 1 : size(img_info, 1) %convert z-stack image into struct
           img{slice} = imread(FilePath, slice);
       end
       [image] = fstack(img); % make focus stacking
       saveFileName = [directory, '/IMG_STACKED/', FileName];
       imwrite(uint8(image),saveFileName);
    end
end


        
          