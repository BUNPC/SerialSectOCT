function[]=Gen_ori_RGB(datapath,islice, ts_aip)
%% generate orientation map in RGB
load('/projectnb2/npbssmic/s/Matlab_code/PSOCT_code/cmap.mat');
% load('/projectnb2/npbssmic/s/Matlab_code/PSOCT_code/cmap_v3.mat');
load(strcat(datapath,'retardance/ret_aip',num2str(islice),'.mat'));
load(strcat(datapath,'aip/aip',num2str(islice),'.mat'));
load(strcat(datapath,'orientation/ori2D',num2str(islice),'.mat'));
phi_for_cwheel=phi_for_cwheel./pi*180;
% for ii = 1:length(cmap)
%     phi_for_cwheel(ii) = ii/length(cmap)*180.1;
% end
abs_m=zeros(size(ret_aip));
% abs_m((ret_aip)>ts_ret)=1;
abs_m(AIP>ts_aip)=1;
ret_aip=ret_aip.*abs_m;
ret_aip=ret_aip./90;
ori2D=ori2D.*abs_m;
ori2D=180-ori2D;
phi = zeros(size(ori2D,1),size(ori2D,2),3);

% Assign colors to phi map for sub-image
% Determine color of each pixel based on the orientation angle extracted
for i = 1:(length(phi_for_cwheel)/2+1) % Only need to compare with first half of phi vector since phi domain is [0, pi]
    mask = (ori2D >= phi_for_cwheel(i) & ori2D < phi_for_cwheel(i+1));
    for k = 1:3
        cmap_mat(:,:,k) = cmap(i,k)*ones(size(ori2D,1),size(ori2D,2));
    end
    phi = phi + cmap_mat.*mask;
end 
phi=phi.*255;
for c=1:3
    phi(:,:,c)=uint8(phi(:,:,c).*ret_aip);
end
phi=uint8(phi);
imwrite(phi, strcat(datapath,'orientation/ori_w', num2str(islice),'.tif'));