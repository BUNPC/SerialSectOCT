function[ori2D]=Gen_ori_2D(ori,sur,depth)
sur(sur>size(ori,1)/2)=0;
vol=ori(sur+11:sur+depth+10,:,:);
groups=0:5:180;
vol=discretize(vol,groups);
ori2D=squeeze(mode(vol,1));
ori2D=groups(ori2D);


        