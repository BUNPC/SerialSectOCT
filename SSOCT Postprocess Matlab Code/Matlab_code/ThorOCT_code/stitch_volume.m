% clear all;

% mosaic parameters

Xsize=400;
Ysize=400;
Xoverlap=0.5;
Yoverlap=0.5;

% add path of functions
addpath('/projectnb/npbssmic/s/Matlab_code/');
addpath('/projectnb/npbssmic/s/Matlab_code/NIfTI_20140122');

%% get FIJI stitching info & adjust coordinates system

filename = strcat('/projectnb/npbssmic/ns/190426_Thorlabs/aip/vol16/');
f=strcat(filename,'TileConfiguration.registered.txt');
coord = read_Fiji_coord(f,'aip');

% vol_index=[];
% for i=1:7
%     slice_index=(i-1)*3+1;
%     filename = strcat('/projectnb/npbssmic/ns/190619_Thorlabs/aip/vol',num2str(slice_index),'/');
%     f=strcat(filename,'TileConfiguration.registered.txt');
%     Fiji_coord{i} = read_Fiji_coord(f,'aip');
%     vol_index=[vol_index Fiji_coord{i}(1,:)];
% end
% 
% % use median corrdinates for all slices
% vol_index=unique(vol_index);
% coord=zeros(3,length(vol_index));
% coord(1,:)=vol_index;
% for i=1:length(vol_index)
%     temp=[];
%     for j=1:7
%         if ismember(vol_index(i),Fiji_coord{j}(1,:))
%             [~, loc]=ismember(vol_index(i),Fiji_coord{j}(1,:));
%             temp=[temp Fiji_coord{j}(2:3,loc)];
%         end
%     end
%     coord(2:3,i)=median(temp,2);
% end
% coord=squeeze(median(coord,1));

%% define coordinates for each tile

Xcen=zeros(size(coord,2),1);
Ycen=zeros(size(coord,2),1);
index=coord(1,:);

for ii=1:size(coord,2)
    Xcen(coord(1,ii))=round(coord(2,ii)/4);
    Ycen(coord(1,ii))=round(coord(3,ii)/4);
end


%% select tiles for sub-region volumetric stitching

Xcen=Xcen-min(Xcen);
Ycen=Ycen-min(Ycen);

Xcen=Xcen+Xsize/8;
Ycen=Ycen+Ysize/8;

% tile range -199~+200
stepx = Xoverlap*Xsize/4;
x = [0:stepx-1 repmat(stepx,1,(1-2*Xoverlap)*Xsize/4) stepx-1:-1:0]./stepx;
stepy = Yoverlap*Ysize/4;
y = [0:stepy-1 repmat(stepy,1,(1-2*Yoverlap)*Ysize/4) stepy-1:-1:0]./stepy;
[rampy,rampx]=meshgrid(x,y);
ramp=rampx.*rampy;      % blending mask


%% blending & mosaicing
    
Mosaic = zeros(max(Xcen)+Xsize/8 ,max(Ycen)+Ysize/8,15);
Masque = zeros(size(Mosaic));
Masque2 = zeros(size(Mosaic));

filename = strcat('/projectnb/npbssmic/ns/190426_Thorlabs/');
cd(filename);    

for nslice=16:42
     
for i=1:length(index)
     
    in = index(i);
    
    filename0=dir(strcat(num2str(nslice),'-',num2str(in),'.mat'));

    % ifilePath=[filename,filename0(1).name];
    
    load(filename0(1).name);
    
    %slice = depth_corr(slice,0.0026);
    
    slice = slice(71:130,:,:) + 20;
    
    temp=zeros(size(slice,1),size(slice,2)/4,size(slice,3)/4);
    
    for z=1:size(slice,1)
        temp(z,:,:)=imresize(squeeze(slice(z,:,:)),0.25);
    end
    
    %figure;imagesc(squeeze(temp(1,:,:)));colormap gray;
    
    vol = zeros(15,size(temp,2),size(temp,3));
    
    for z=1:size(vol,1)
        vol(z,:,:)=mean(temp((z-1)*4+1:z*4,:,:),1);
    end
    
    %figure;imagesc(squeeze(vol(1,:,:)));colormap gray;
    
    row = Xcen(in)-Xsize/8+1:Xcen(in)+Xsize/8;
    column = Ycen(in)-Ysize/8+1:Ycen(in)+Ysize/8;  
    
    
    for j=1:size(vol,1)
        Masque2(row,column,j)=ramp;
        Masque(row,column,j)=Masque(row,column,j)+Masque2(row,column,j);
        Mosaic(row,column,j)=Mosaic(row,column,j)+squeeze(vol(j,:,:))'.*Masque2(row,column,j);        
    end
end

% Mosaic=Mosaic-min(Mosaic(:));
Mosaic=Mosaic./Masque;
Mosaic(isnan(Mosaic(:)))=0;

save(strcat('/projectnb/npbssmic/ns/190426_Thorlabs/volume/uncorrected/Mosaic',num2str(nslice),'_depth_uncorrected.mat'),'Mosaic');
disp(['Slice No.',num2str(nslice), ' stitched ', datestr(now,'DD:HH:MM')]);
end
%nii=make_nii(Mosaic,[],[],64);
%save_nii(nii,'/projectnb/npbssmic/ns/190619_Thorlabs/nii/OCT_vol13.nii');