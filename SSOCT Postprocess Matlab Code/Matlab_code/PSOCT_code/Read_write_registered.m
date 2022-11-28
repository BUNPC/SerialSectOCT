addpath('/projectnb/npbssmic/s/Matlab_code/fitting_code');
addpath('/projectnb/npbssmic/s/Matlab_code/PostProcessing');
addpath('/projectnb/npbssmic/s/Matlab_code/PSOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code/ThorOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code');

datapath  = '/projectnb2/npbssmic/ns/210709_4x4x2_BA44_45_milestone_2P_4_30_slice/';
cd(datapath)
islice=1;
filepath = strcat(datapath,'aip/vol',num2str(islice),'/');
f=strcat(filepath,'TileConfiguration.txt');
coord = read_Fiji_coord(f,'channel1');

fileID = fopen([filepath 'TileConfiguration_RGB.txt'],'w');
fprintf(fileID,'# Define the number of dimensions we are working on\n');
fprintf(fileID,'dim = 2\n\n');
fprintf(fileID,'# Define the image coordinates\n');
tile=0;
OCT_list=[];

for j=1:256
    OCT_list(j,:)=[coord(2,j) coord(3,j)];
        fprintf(fileID,['Composite-',num2str(j-1,'%04.f'),'.tif; ; (%d, %d)\n'],round(coord(2,j)),round(coord(3,j)));
%         tile=tile+1;
 
end
fclose(fileID);
% figure;scatter(OCT_list(:,1),OCT_list(:,2))
%%
% datapath  = '/projectnb2/npbssmic/ns/210709_4x4x2_BA44_45_milestone_2P_1_3_slice/';
% cd(datapath)
% islice=1;
% filepath = strcat(datapath,'aip/vol',num2str(islice),'/');
% f=strcat(filepath,'TileConfiguration.registered.txt');
% coord = read_Fiji_coord(f,'channel1');
% 
% fileID = fopen([filepath 'TileConfiguration1.txt'],'w');
% fprintf(fileID,'# Define the number of dimensions we are working on\n');
% fprintf(fileID,'dim = 2\n\n');
% fprintf(fileID,'# Define the image coordinates\n');
% tile=0;
% P2_list=[];
% 
% for j=1:256
%     P2_list(j,:)=[coord(2,j) coord(3,j)];
% %         fprintf(fileID,[num2str(j) '_ret.tif; ; (%d, %d)\n'],round(coord(2,j)),round(coord(3,j)));
% %         tile=tile+1;
%  
% end
% fclose(fileID);
% figure;scatter(P2_list(:,1),P2_list(:,2))