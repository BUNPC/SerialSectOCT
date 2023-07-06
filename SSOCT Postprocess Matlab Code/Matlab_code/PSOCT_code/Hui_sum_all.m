function[]=Hui_sum_all(folder,ntiles,islice, z, XYsize)
addpath('/projectnb/npbssmic/s/Matlab_code/fitting_code');
addpath('/projectnb/npbssmic/s/Matlab_code/PostProcessing');
addpath('/projectnb/npbssmic/s/Matlab_code/PSOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code/ThorOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code');

cd(folder);
files=dir(strcat(num2str(islice),'-*AB.dat'));
sum_co=zeros(z,XYsize,XYsize);
sum_cross=zeros(z,XYsize,XYsize);
for i=1:ntiles
    i
    amp = ReadDat_int16(strcat(folder,files(i).name), [z 1 XYsize+100 1 XYsize*3 ]);
    sum_co=sum_co+amp(:,101:end,XYsize+1:2*XYsize)./65535*4;
%     sum_cross=sum_cross+amp(:,51:1150,1:1100)./65535*4;
end
% sum_co=convn(sum_co,ones(3,3)./9,'same');
surface=surprofile2(sum_co,'PSOCT',1);
surface=round(surface-min(surface(:)));

% [X Y]=meshgrid(0.001:XYsize/10);
% % [Xv Yv]=meshgrid(0.1:(XYsize/10-0.5)/(XYsize):XYsize/10-0.5);
% [Xv Yv]=meshgrid(0.001:0.1:XYsize/10);
% Vq=interp2(X,Y,surface,Xv,Yv);
% surface=round(Vq);
save('surface.mat','surface');
%%
% sum_co=FOV_curvature_correction(sum_co, surface, size(sum_co,1), size(sum_co,2), size(sum_co,3));
% sum_cross=FOV_curvature_correction(sum_cross, surface, size(sum_cross,1), size(sum_cross,2), size(sum_cross,3));
% save('sum_co.mat','sum_co');
% save('sum_cross.mat','sum_cross');
% %% shading
% shading_co=mean(sum_co(1:200,:,:),1);
% shading_co=shading_co./max(shading_co(:));
% save('shading_co.mat','shading_co');
% shading_cross=mean(sum_cross(1:200,:,:),1);
% shading_cross=shading_cross./max(shading_cross(:));
% save('shading_cross.mat','shading_cross');