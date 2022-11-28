function[]=ret_diff_vol_stitch(id,datapath)
% mosaic parameters
% mkdir(strcat(datapath,'dist_corrected/volume_tmp'));
Xsize=1000;
Ysize=1000;
Xoverlap=0.15;
Yoverlap=0.15;

% add path of functions
addpath('/projectnb/npbssmic/s/Matlab_code/PSOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code/ThorOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code/NIfTI_20140122');

%% get FIJI stitching info & adjust coordinates system

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

% id=str2num(id);
filename = strcat(datapath,'aip/vol1/');
f=strcat(filename,'TileConfiguration.registered.txt');
coord = read_Fiji_coord(f,'aip');

Xcen=zeros(size(coord,2),1);
Ycen=zeros(size(coord,2),1);
index=coord(1,:);

for ii=1:size(coord,2)
    Xcen(coord(1,ii))=round(coord(3,ii));
    Ycen(coord(1,ii))=round(coord(2,ii));
end


%% select tiles for sub-region volumetric stitching

Xcen=Xcen-min(Xcen);
Ycen=Ycen-min(Ycen);

Xcen=Xcen+round(Xsize/2);
Ycen=Ycen+round(Ysize/2);

% tile range -199~+200
stepx = floor(Xoverlap*Xsize/4);
x = [0:stepx-1 repmat(stepx,1,round((1-2*Xoverlap)*Xsize/4)+1) stepx-1:-1:0]./stepx;
stepy = floor(Yoverlap*Ysize/4);
y = [0:stepy-1 repmat(stepy,1,round((1-2*Yoverlap)*Ysize/4)+1) stepy-1:-1:0]./stepy;
[rampy,rampx]=meshgrid(y,x);
ramp=rampx.*rampy;      % blending mask


%% blending & mosaicing

thickness=100;%62;


filename = strcat(datapath,'dist_corrected/ret_depth/');
% filename = datapath;
cd(filename);


for nslice=id
    
    Mosaic = zeros(round(max(Xcen/4))+round(Xsize/8) ,round(max(Ycen/4))+round(Ysize/8),round(thickness/4));
    Masque = zeros(size(Mosaic));
    Masque2 = zeros(size(Mosaic));
    filename0=dir(strcat(filename,'ret_diff-',num2str(nslice),'-',num2str(1),'-*.dat'));
    name1=strsplit(filename0(1).name,'.');  
    name_dat=strsplit(name1{1},'-');   
    nk = str2num(name_dat{4}); nxRpt = 1; nx=str2num(name_dat{5}); nyRpt = 1; ny = str2num(name_dat{6});
    dim=[nk nxRpt nx nyRpt ny];

    for i=1:length(index)

        in = index(i)

        filename0=dir(strcat('ret_diff-',num2str(nslice),'-',num2str(in),'-*.dat'));
        ifilePath=[filename,filename0(1).name];
        slice = single(ReadDat_single(ifilePath, dim));
        
        info=strcat('Finished loading tile No.', num2str(in),'\n');
        fprintf(info);

        
      
        % only for PSOCT0103
        % slice = ReadDat_single(ifilePath, dim); 
        % slice(31:74,:,:) = speckle_reduction(double(slice(31:74,:,:)));
%         vol = convn(vol,ones(3,3,3)./27,'same');
%         vol = depth_corr(vol,0.0035);
        slice = slice(1:1+thickness-1,:,:);%25 for PTSD1_1 %16 for PTSD1_2 %41 for PTSD1_3

        temp=zeros(thickness,size(slice,2)/4,size(slice,3)/4);

        for z=1:thickness
            temp(z,:,:)=imresize(squeeze(slice(z,:,:)),0.25);
        end

        %figure;imagesc(squeeze(temp(1,:,:)));colormap gray;

        vol = zeros(round(thickness/4),size(temp,2),size(temp,3));

        for z=1:size(vol,1)
            vol(z,:,:)=mean(temp((z-1)*4+1:min(z*4,thickness),:,:),1);
        end
    
        % row and column start with +2 only for PSOCT0103
        row = round(Xcen(in)/4)-round(Xsize/8)+1:round(Xcen(in)/4)+round(Xsize/8);
        column = round(Ycen(in)/4)-round(Ysize/8)+1:round(Ycen(in)/4)+round(Ysize/8);  


        for j=1:size(vol,1)
            Masque2(row,column,j)=ramp;
            Masque(row,column,j)=Masque(row,column,j)+Masque2(row,column,j);
            Mosaic(row,column,j)=Mosaic(row,column,j)+squeeze(vol(j,:,:)).*Masque2(row,column,j);        
        end 
    end

    Ret_diff=Mosaic./Masque;
    Ret_diff(isnan(Ret_diff(:)))=0;
    Ret_diff=single(Ret_diff);

    save(strcat(datapath,'dist_corrected/volume/ret_diff',num2str(nslice),'.mat'),'Ret_diff','-v7.3');
    % only for PSOCT0103
    % save(strcat(datapath,'volume/ref',num2str(nslice),'.mat'),'Ref','-v7.3');

% save as TIFF

%     s=uint16(65535*(mat2gray(Mosaic))); 
%     
%     tiffname=strcat('/projectnb/npbssmic/ns/200301_PSOCT/second/corrected/nii/vol',num2str(nslice),'.tif');
% 
%     for i=1:size(s,3)
%         t = Tiff(tiffname,'a');
%         image=squeeze(s(:,:,i));
%         tagstruct.ImageLength     = size(image,1);
%         tagstruct.ImageWidth      = size(image,2);
%         tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
%         tagstruct.BitsPerSample   = 16;
%         tagstruct.SamplesPerPixel = 1;
%         tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
%         tagstruct.Compression = Tiff.Compression.None;
%         tagstruct.Software        = 'MATLAB';
%         t.setTag(tagstruct);
%         t.write(image);
%         t.close();
%     end

    info=strcat('Volumetric reconstruction of slice No.', num2str(nslice), ' is done.\n');
    fprintf(info);

end