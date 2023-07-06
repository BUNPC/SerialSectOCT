datapath='/projectnb/npbssmic/ns/PSOCT-qBRM_sample/sample2/qBRM_orientation/';
cd(datapath)
% load('/projectnb2/npbssmic/s/Matlab_code/PSOCT_code/cmap.mat');
load('/projectnb2/npbssmic/s/Matlab_code/PSOCT_code/cmap_v3.mat');
ret_aip=single(imread(strcat(datapath,'phi_10x/Ret1.tif')));
% load(strcat(datapath,'aip/aip',num2str(islice),'.mat'));
ori2D=single(imread(strcat(datapath,'phi_10x/Fused1.tif')));
ori2D=ori2D./pi*180;
ori2D(ori2D<0)=ori2D(ori2D<0)+180;
% phi_for_cwheel=phi_for_cwheel./pi*180;
phi_for_cwheel=zeros(length(cmap),1);
for ii = 1:length(cmap)
    phi_for_cwheel(ii) = ii/length(cmap)*180.01;
end
% abs_m=zeros(size(ret_aip));
% abs_m((ret_aip)>ts_ret)=1;
% abs_m(AIP>ts_aip)=1;
ret_aip=ret_aip./max(ret_aip(:));
ret_aip=ret_aip(1:size(ori2D,1),1:size(ori2D,2));
% ret_aip=ret_aip./90;
% ori2D=ori2D.*abs_m;
% ori2D=180-ori2D;
phi = zeros(size(ori2D,1),size(ori2D,2),3);
% Assign colors to phi map for sub-image
% Determine color of each pixel based on the orientation angle extracted
cmap_mat=zeros(size(ori2D,1),size(ori2D,2),3);
for i = 1:(length(phi_for_cwheel)-1) % Only need to compare with first half of phi vector since phi domain is [0, pi]
    i
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
save('ori_w1.mat','phi','-v7.3');
% imwrite(phi, strcat(datapath,'phi_10x/ori_w1.tif'));