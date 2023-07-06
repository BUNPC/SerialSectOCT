function Gen_stitch_macro(P2path, datapath, filepath, stitch)
    %% get FIJI stitching coordinates
    % use following 3 lines if stitching using OCT coordinates
    if stitch==1
        coordpath = strcat(datapath,'aip/RGB/');
        f=strcat(coordpath,'TileConfiguration.registered.txt');
        if isfile(f)
            coord = read_Fiji_coord(f,'Composite');
        else
            pause(600)
        end
    
    % use following 3 lines if stitching using individual slice OCT
    % coordinates -- we don't use this anymore since stacking will be
    % difficult if we stitch each slice individually
    
%     f=strcat(datapath,'aip/vol',num2str(islice),'/TileConfiguration.registered.txt');
%     coord = read_Fiji_coord(f,'aip');
    else
    % use following 3 lines if stitch using 2P coordinates
        coordpath = strcat(P2path,'aip/RGB/');
        f=strcat(coordpath,'TileConfiguration.registered.txt');
        coord = read_Fiji_coord(f,'Composite');
        coord(2:3,:)=coord(2:3,:).*2/3;
    end
    
    %filepath=macro_path;%strcat(datapath,'orientation/vol',num2str(islice),'/');
    cd(filepath);
    fileID = fopen([filepath 'TileConfiguration.txt'],'w');
    fprintf(fileID,'# Define the number of dimensions we are working on\n');
    fprintf(fileID,'dim = 2\n\n');
    fprintf(fileID,'# Define the image coordinates\n');
    for ii = 1: length(coord)
        fprintf(fileID,[num2str(ii) '_ori.tif; ; (%d, %d)\n'],coord(2:end,ii));
    end
    