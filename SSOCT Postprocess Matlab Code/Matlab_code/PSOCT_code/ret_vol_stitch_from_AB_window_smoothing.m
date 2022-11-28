function[]=ret_vol_stitch_from_AB_window_smoothing(id,datapath)
% mosaic parameters
id=3*id-2;
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
filename = strcat(datapath,'aip/vol106/');
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
stepx = floor(Xoverlap*Xsize);
x = [0:stepx-1 repmat(stepx,1,round((1-2*Xoverlap)*Xsize)) stepx-1:-1:0]./stepx;
stepy = floor(Yoverlap*Ysize);
y = [0:stepy-1 repmat(stepy,1,round((1-2*Yoverlap)*Ysize)) stepy-1:-1:0]./stepy;
[rampy,rampx]=meshgrid(y,x);
ramp=rampx.*rampy;      % blending mask


%% blending & mosaicing

thickness=44;


filename = strcat(datapath,'dist_corrected/');
% filename = datapath;
cd(filename);

plane=0;
Mosaic_co = zeros(round(max(Xcen))+round(Xsize/2) ,round(max(Ycen))+round(Ysize/2),round(thickness)*3);
Masque = zeros(size(Mosaic_co));
%     Masque2 = zeros(size(Mosaic_co));
Mosaic_cross = zeros(round(max(Xcen))+round(Xsize/2) ,round(max(Ycen))+round(Ysize/2),round(thickness)*3);

for nslice=id:id+2
    plane=plane+1;
    
    filename0=dir(strcat(filename,'cross-',num2str(nslice),'-',num2str(1),'-*.dat'));
    % only for PSOCT0103
    % filename0=dir(strcat(filename,num2str(nslice),'-',num2str(1),'-*.dat'));
    name1=strsplit(filename0(1).name,'.');  
    name_dat=strsplit(name1{1},'-');   
    nk = str2num(name_dat{4}); nxRpt = 1; nx=str2num(name_dat{5}); nyRpt = 1; ny = str2num(name_dat{6});
    % only for PSOCT0103
    % nk = 108; nxRpt = 1; nx = 1060; nyRpt = 1; ny = 1060;
    dim=[nk nxRpt nx nyRpt ny];

    for i=1:length(index)

        in = index(i);

        filename0=dir(strcat('cross-',num2str(nslice),'-',num2str(in),'-*.dat'));
        ifilePath=[filename,filename0(1).name];
        cross = (ReadDat_int16(ifilePath, dim));
        cross=cross(66:66+thickness-1,:,:);
        cross=convn(cross,ones(1,5,5)./25,'same');
        
        filename0=dir(strcat('co-',num2str(nslice),'-',num2str(in),'-*.dat'));
        ifilePath=[filename,filename0(1).name];
        co=ReadDat_int16(ifilePath, dim);
        co=co(66:66+thickness-1,:,:);
        co=convn(co,ones(1,5,5)./25,'same');

        message=strcat('Tile No. ',string(in),' is read.', datestr(now,'DD:HH:MM'),'\n');
        fprintf(message);
        % row and column start with +2 only for PSOCT0103
        row = round(Xcen(in))-round(Xsize/2)+1:round(Xcen(in))+round(Xsize/2);
        column = round(Ycen(in))-round(Ysize/2)+1:round(Ycen(in))+round(Ysize/2);  


        for j=1:size(cross,1)
%             Masque2(row,column,j+plane*44-44)=ramp;
            Masque(row,column,j+plane*44-44)=Masque(row,column,j+plane*44-44)+ramp;%Masque2(row,column,j+plane*44-44);
            Mosaic_co(row,column,j+plane*44-44)=Mosaic_co(row,column,j+plane*44-44)+squeeze(co(j,:,:)).*ramp;%Masque2(row,column,j+plane*44-44);    
            
            Mosaic_cross(row,column,j+plane*44-44)=Mosaic_cross(row,column,j+plane*44-44)+squeeze(cross(j,:,:)).*ramp;%Masque2(row,column,j+plane*44-44);   
        end 
    end
end
    co=Mosaic_co./Masque;
    co(isnan(co(:)))=0;
    co=single(co);
    cross=Mosaic_cross./Masque;
    cross(isnan(cross(:)))=0;
    cross=single(cross);

    save(strcat(datapath,'dist_corrected/volume/co_win5x5',num2str(nslice),'.mat'),'co','-v7.3');
    save(strcat(datapath,'dist_corrected/volume/cross_win5x5',num2str(nslice),'.mat'),'cross','-v7.3');
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