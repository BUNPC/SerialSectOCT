% mosaic parameters
% mkdir(strcat(datapath,'dist_corrected/volume_tmp'));
id=1;
datapath='/projectnb2/npbssmic/ns/210310_4x4x2cm_milestone/';
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
f=strcat(filename,'TileConfiguration.freeview.txt');
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

thickness=50;


filename = strcat(datapath,'dist_corrected/');
% filename = datapath;
cd(filename);


for nslice=1:10
    
    Mosaic = single(zeros(round(max(Xcen))+round(Xsize/2) ,round(max(Ycen))+round(Ysize/2),round(thickness)));
    Masque = single(zeros(size(Mosaic)));
%     Masque2 = int16(zeros(size(Mosaic)));
    filename0=dir(strcat(filename,'co-',num2str(nslice),'-',num2str(1),'-*.dat'));
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

        filename0=dir(strcat('co-',num2str(nslice),'-',num2str(in),'-*.dat'));
        ifilePath=[filename,filename0(1).name];
        vol = (ReadDat_int16(ifilePath, dim)./65535*2).^2;
        filename0=dir(strcat('cross-',num2str(nslice),'-',num2str(in),'-*.dat'));
        ifilePath=[filename,filename0(1).name];
        vol = vol+(ReadDat_int16(ifilePath, dim)./65535*2).^2;
        vol=single(sqrt(vol));

        
%         vol = single(ReadDat_int16(ifilePath, dim)./65535*2);       
        % only for PSOCT0103
        % slice = ReadDat_single(ifilePath, dim); 
%         slice(31:74,:,:) = speckle_reduction(double(slice(31:74,:,:)));
        slice = depth_corr(vol,0.0035);
        vol = vol(51:100,:,:);
        

%         slice = slice(1:(thickness),51:1050,51:1050);


%         vol=slice;
    
        % row and column start with +2 only for PSOCT0103
        row = round(Xcen(in))-round(Xsize/2)+1:round(Xcen(in))+round(Xsize/2);
        column = round(Ycen(in))-round(Ysize/2)+1:round(Ycen(in))+round(Ysize/2);  


        for j=1:size(vol,1)
%             Masque2(row,column,j)=ramp;
            Masque(row,column,j)=Masque(row,column,j)+ramp;%Masque2(row,column,j);
            Mosaic(row,column,j)=Mosaic(row,column,j)+squeeze(vol(j,:,:)).*ramp;%Masque2(row,column,j);        
        end 
    end

    Ref=int16(Mosaic./Masque/4*65535);
    Ref(isnan(Ref(:)))=0;
%     Ref=single(Ref);

%     save(strcat(datapath,'dist_corrected/volume/cross',num2str(nslice),'.mat'),'Ref','-v7.3');
    % only for PSOCT0103
    save(strcat(datapath,'dist_corrected/volume/ref_freeview',num2str(nslice),'.mat'),'Ref','-v7.3');

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
% clear options;
% options.big = true; % Use BigTIFF format
% saveastiff(Ref, strcat(datapath,'dist_corrected/volume/ref',num2str(nslice),'.btf'), options);
    info=strcat('Volumetric reconstruction of slice No.', num2str(nslice), ' is done.\n');
    fprintf(info);

end