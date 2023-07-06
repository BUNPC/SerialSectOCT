% function BRM_ori_stitch(datapath,mosaic,pxlsize)
datapath='/projectnb/npbssmic/ns/PSOCT-qBRM_sample/sample2/qBRM_orientation/phi_10x/';
%% stitch the retardance using the coordinates from AIP stitch
% add subfunctions for the script
addpath('/projectnb/npbssmic/s/Matlab_code/fitting_code');
addpath('/projectnb/npbssmic/s/Matlab_code/PostProcessing');
addpath('/projectnb/npbssmic/s/Matlab_code/PSOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code/ThorOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code');
cd(datapath);
% mosaic parameters
Xoverlap=0.1;
Yoverlap=0.1;
Xsize=2960;                                                                              %changed by stephan
Ysize=2960;
%% get FIJI stitching info
% use following 3 lines if stitch using OCT coordinates
f=strcat(datapath,'TileConfiguration1.registered.txt');
coord = read_Fiji_coord(f,'BRM');


% fileID = fopen([datapath 'TileConfiguration1.txt'],'w');
% fprintf(fileID,'# Define the number of dimensions we are working on\n');
% fprintf(fileID,'dim = 2\n\n');
% fprintf(fileID,'# Define the image coordinates\n');
% 
% for j=1:199
% %         filename0=dir(strcat(num2str(j),'-channel1.mat'));
% %         load(filename0.name);
% %         if mean(channel1(:))>0
%         fprintf(fileID,['phi_',num2str(coord(1,j),'%03.f'),'.tif; ; (%d, %d)\n'],coord(2:3,j));
% %         end
% end
% fclose(fileID);
%% define coordinates for each tile

Xcen=zeros(size(coord,2),1);
Ycen=zeros(size(coord,2),1);
index=coord(1,:);

for ii=1:size(coord,2)
    Xcen(coord(1,ii))=round(coord(3,ii));
    Ycen(coord(1,ii))=round(coord(2,ii));
end

Xcen=Xcen-min(Xcen);
Ycen=Ycen-min(Ycen);

Xcen=Xcen+Xsize/2;
Ycen=Ycen+Ysize/2;

%% calculate ramp for individual tile, based on stitching coord
stepx = Xoverlap*Xsize;
x = [0:stepx-1 repmat(stepx,1,round((1-2*Xoverlap)*Xsize)) round(stepx-1):-1:0]./stepx;
if length(x)<Xsize
    for ii = length(x)+1:Xsize
        x(ii)=1;
    end
end
stepy = Yoverlap*Ysize;
y = [0:stepy-1 repmat(stepy,1,round((1-2*Yoverlap)*Ysize)) round(stepy-1):-1:0]./stepy;
if length(y)<Ysize
    for ii = length(y)+1:Ysize
        y(ii)=1;
    end
end

[rampy,rampx]=meshgrid(y, x);


%% blending & mosaicing
Mosaic = single(zeros(4,round(max(Xcen)+Xsize) ,round(max(Ycen)+Ysize)));
Masque = single(zeros(size(Mosaic)));

tic
for i=1:length(index)
        in = index(i);
        ori2D=single(imread(strcat(datapath,'phi_',num2str(in,'%03d'),'.tif'),1));
        ori2D=ori2D./pi*180;
        ramp=rampx.*rampy;      % blending mask
        %%
        row = round(Xcen(in)-Xsize/2+1:Xcen(in)+Xsize/2);                              
        column = round(Ycen(in)-Ysize/2+1:Ycen(in)+Ysize/2);

        for pos=1:4
            mask=int8(zeros([Xsize,Ysize]));
            mask(Masque(pos,row,column)==0)=1;
            tmp=ramp;tmp(mask==0)=0;
            Masque(pos,row,column)=squeeze(Masque(pos,row,column))+single(tmp);
            ramp(mask==1)=0;
            tmp=ori2D;tmp(mask==0)=0;
            mmask=zeros(size(tmp));
            mmask(Mosaic(pos,row,column)<=0)=1;
            Mosaic(pos,row,column)=squeeze(Mosaic(pos,row,column))+tmp.*mmask;
            ori2D(mask==1)=0;
        end
end
toc
tic
Mosaic=Cycle_ori(Mosaic,Masque);
toc
Masque=squeeze(sum(Masque,1))+0.01;
Mosaic=Mosaic./Masque;
Mosaic(Mosaic<0)=Mosaic(Mosaic<0)+180;
Mosaic(Mosaic>180)=Mosaic(Mosaic>180)-180;

clear Masque
Mosaic(isnan(Mosaic))=0;
Mosaic=single(Mosaic);

clear options;
options.big = false; % Use BigTIFF format
options.overwrite = true;
options.append = false;
saveastiff(Mosaic, 'orientation.tif',options);
% saveastiff(Mosaic(:,1:15000), 'orientation1.btf',options);
% saveastiff(Mosaic(:,15001:30000), 'orientation2.btf',options);
% saveastiff(Mosaic(:,30001:45000), 'orientation3.btf',options);
% saveastiff(Mosaic(:,45001:60000), 'orientation4.btf',options);
