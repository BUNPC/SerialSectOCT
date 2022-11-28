StitchingType = 'Multi-Plane';
AcquisitionType = 'ROI Imaging';
directory = '/projectnb2/npbssmic/ns/qBRM_AD/ROI2/';
Fiji_stitching(directory, StitchingType, AcquisitionType);
directory = '/projectnb2/npbssmic/ns/qBRM_AD/ROI4/';
Fiji_stitching(directory, StitchingType, AcquisitionType);

function Fiji_stitching(directory, StitchingType, AcquisitionType)
    addpath('/projectnb/npbssmic/s/Matlab_code/qBRM_code_Anna')
    cd(directory)
    coord_file = dir('*_coordinates.mat');
    load(coord_file.name, 'z_mesh');
    grid_size = size(z_mesh);

    overlap = 25;
    gridx = grid_size(2);
    gridy = grid_size(1);

    macropath=[directory,'Macro.ijm'];
    fid_Macro = fopen(macropath, 'w');
    command_str = sprintf('type=[Grid: snake by rows] order=[Right & Down                ] grid_size_x=%d grid_size_y=%d tile_overlap=%d first_file_index_i=1 directory=%s file_names=img_{iii}.tif output_textfile_name=TileConfiguration.txt fusion_method=[Linear Blending] regression_threshold=0.30 max/avg_displacement_threshold=2.50 absolute_displacement_threshold=3.50 compute_overlap computation_parameters=[Save computation time (but use more RAM)] image_output=[Write to disk] output_directory=%s', gridx, gridy, overlap, directory, directory);
    l=['run("Grid/Collection stitching", "', command_str,'");\n'];
    fprintf(fid_Macro,l);
    fclose(fid_Macro);
    system(['/projectnb/npbssmic/ns/Fiji/Fiji.app/ImageJ-linux64 --headless -macro ',macropath]);



    if strcmp(StitchingType, 'Multi-Plane') && strcmp(AcquisitionType, 'ROI Imaging')
        mkdir('IMG_SEQ'); %create image sequence folder to save multiplane stitches
        done = 0;
        counter = 1;
        while (~done)
            try
                loc = strcat(directory, '/', sprintf('img_t1_z%02d_c1', counter));
                image_read = Tiff(loc);
                image_read = read(image_read);
                img_stack(:,:,counter) = image_read;
                location = strcat(directory, '/IMG_SEQ/',sprintf('img_%03d.tif', counter));
                imwrite(image_read, location, 'tiff')
                filename = strcat(directory, '/IMG_SEQ/', 'MP_stitched_ROI.tif');
                imwrite(uint8(img_stack(:,:,counter)), filename, 'tif', 'WriteMode', 'append');
                counter = counter +1;

            catch ME
                done= 1;
            end
        end
        % run matlab focus stacking algorithm on all of z-plane images
        location = strcat(directory, '/IMG_SEQ/');
        image = focus_stacking(location);
        imwrite(uint8(image),'stitched_image_matlab.tif');

    end

    if strcmp(AcquisitionType, 'Widefield (4X)')
        direct_loc = [directory '\Stitched_image'];
        movefile  img_t1_z1_c1 Stitched_image %rename file
        image_read = Tiff(direct_loc);
        image_read = read(image_read);
        imwrite(image_read, 'Stitched_image.tif', 'tiff')
    end

    file_loc = strcat(directory, 'stitched.tif');  
    cmd = sprintf('Tiff, path = [%s]',file_loc);
end

function  image = focus_stacking(directory)
    cd(directory)
    a = dir('*.tif');
    n = numel(a)-1;
    for i = 1:n
        img{i} = imread(sprintf('img_%03d.tif',i));
    end
    [image] = fstack(img);
end


        
          