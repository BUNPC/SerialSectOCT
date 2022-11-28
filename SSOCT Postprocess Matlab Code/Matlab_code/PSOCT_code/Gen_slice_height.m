function[height]=Gen_slice_height(thresh, s_seg, datapath)
% cd(strcat(datapath,'/surf/'))
filename=strcat(datapath,'/surf/sur',num2str(s_seg),'.tif'); 
sur = double(imread(filename, 1));
filename=strcat(datapath,'/aip/aip',num2str(s_seg),'.mat'); 
load(filename)
aip=imresize(aip,0.1);
aip=aip(1:size(sur,1),1:size(sur,2));
mask=zeros(size(aip));mask(aip>thresh)=1;
sur=sur.*mask;
height=mean(sur(sur>0));
end