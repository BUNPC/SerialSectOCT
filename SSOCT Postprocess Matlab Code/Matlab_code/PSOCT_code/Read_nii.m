function[V]=Read_nii(datapath, filename)
info = niftiinfo(strcat(datapath,filename));
V = niftiread(info);
% V=10.^(V./20);
% V=flip(V,3);
