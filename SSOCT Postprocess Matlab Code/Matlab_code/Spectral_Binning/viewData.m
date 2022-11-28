folder='/projectnb2/npbssmic/ns/210121_fiber_spectrum';
addpath('/projectnb/npbssmic/s/Matlab_code/PostProcessing/');
cd(folder);
B_mag_files=dir('*data.dat');
num_files=length(B_mag_files);
x=2500;
z=100;
y=2500;
for i=1:num_files
    fileID = fopen(B_mag_files(i).name); 
    raw_data = fread(fileID,[z,x*y],'float'); %read real space data 
    %raw_data = uint16(fread(fileID,[z,x*y],'uint16'));  
    fclose(fileID);
    file_split=strsplit(B_mag_files(i).name,'.');
    file_split2=strsplit(string(file_split(1)),'-');
    c_line= reshape(raw_data,z,x,y);
    %view3D(c_line);
    AIP=squeeze(mean(c_line(:,:,:),1));
    %figure;imagesc(AIP);
end

for i=4
    img1 = reshape(c_line(i*10,:,:),[x,y]);
    img2 = img1(:, 625:1875);
    figure; imagesc(img2(1000:1400, 500:700));
    figure; imagesc(img2(1200:1600, 900:1100));
    colormap gray
end