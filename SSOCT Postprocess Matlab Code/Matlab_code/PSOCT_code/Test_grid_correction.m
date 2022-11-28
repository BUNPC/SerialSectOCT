
%folder_distort=<path for grid matrix.bin>                 
fileID = fopen(strcat(folder_distort,'grid matrix.bin'), 'r'); 
grid_matrix = fread(fileID,'double');
fclose(fileID);
grid_matrix=reshape(grid_matrix, 4,1700,1700);

%datapath=<path for tiles>
cd(datapath)
filename0=dir(strcat('file*.tif')); 

for iFile =1:54
    imageData1 = double(imread(filename0(iFile).name, 1));
    imageData2 = double(imread(filename0(iFile).name, 2));

    clear channel1
    clear channel2
    channel1(1,:,:) = imageData1(66:1765,290:1989); % Cut spare FOV and get rid of extreme distortion at the edge of FOV
    channel2(1,:,:) = imageData2(66:1765,290:1989);
    channel1 = squeeze(Grid_correction(channel1, grid_matrix, 1600, 101, 1600, 101, 1));      
    channel2 = squeeze(Grid_correction(channel2, grid_matrix, 1600, 101, 1600, 101, 1)); 
    channel1=imrotate(channel1,90);
    channel2=imrotate(channel2,90);
end