 clear all;


Xsize=40;
Ysize=40;
Xoverlap=0.5;
Yoverlap=0.5;

%% get FIJI stitching info

filename = strcat('/projectnb2/npbssmic/ns/190619_Thorlabs/aip/vol10/');
f=strcat(filename,'TileConfiguration.registered.txt');
coord = read_Fiji_coord(f,'aip');

%% coordinates correction
% use median corrdinates for all slices
% coord=squeeze(median(coord,1));

%% define coordinates for each tile

Xcen=zeros(size(coord,2),1);
Ycen=zeros(size(coord,2),1);
index=coord(1,:);
for ii=1:size(coord,2)
    Xcen(coord(1,ii))=round(coord(2,ii));
    Ycen(coord(1,ii))=round(coord(3,ii));
end
Xcen=Xcen-min(Xcen);
Ycen=Ycen-min(Ycen);

Xcen=Xcen+Xsize/2;
Ycen=Ycen+Ysize/2;

% tile range -199~+200
stepx = Xoverlap*Xsize;
x = [0:stepx-1 repmat(stepx,1,(1-2*Xoverlap)*Xsize) stepx-1:-1:0]./stepx;
stepy = Yoverlap*Ysize;
y = [0:stepy-1 repmat(stepy,1,(1-2*Yoverlap)*Ysize) stepy-1:-1:0]./stepy;
[rampy,rampx]=meshgrid(x,y);
ramp=rampx.*rampy;      % blending mask

%% blending & mosaicing
    
Mosaic = zeros(max(Xcen)+Xsize ,max(Ycen)+Ysize);
Masque = zeros(size(Mosaic));
cd(filename);    

for i=1:length(index)
        
        in = index(i);
        
        %% Set file location %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        filename0=dir(strcat('mus_16_',num2str(in),'.mat'));
        if ~isempty(filename0)
            load(filename0.name);
        else
            us=zeros(40,40);
        end
        
%         if mean(aip(:))<-2
%             Xcen(index)=Xcen(1);
%             Ycen(index)=Ycen(1);
%         end
        
        % generate AIP
%         aip=squeeze(20*mean(log10(slice(2:350,:,:)),1));
        %aip=aip-min(min(aip));
        
%         if abs(Xcen(index)-Xcen(30+j)-grid_xx*(j-1)-grid_yx*(i-1))>=100%||abs(Ycen(index)-Ycen(Ytile*(i-1)+1))>=300*j
%             Xcen(index)=max(floor(Xcen(1)-grid_xx*(j-1)-grid_yx*(i-1)),200);
%             Ycen(index)=floor(Ycen(1)-grid_xy*(j-1)-grid_yy*(i-1));
%         end
        
        row = Xcen(in)-Xsize/2+1:Xcen(in)+Xsize/2;
        column = Ycen(in)-Ysize/2+1:Ycen(in)+Ysize/2;
        Masque2 = zeros(size(Mosaic));
        Masque2(row,column)=ramp;
        Masque(row,column)=Masque(row,column)+Masque2(row,column);
        Mosaic(row,column)=Mosaic(row,column)+us'.*Masque2(row,column);
end

MosaicFinal=Mosaic./Masque;
MosaicFinal(isnan(MosaicFinal))=0;
%MosaicFinal = fliplr(MosaicFinal);
% MosaicFinal = flipud(MosaicFinal);
%MosaicFinal = MosaicFinal(1:700,1:900);
MosaicFinal=MosaicFinal';

%% masking out agarose pixels
% mask=TIFF2MAT('E:\Jiarui\Data\200708baseline\mask_ds.tif');
% mask(mask(:)~=0)=1;
% MosaicFinal=MosaicFinal.*double(mask);
% I=MosaicFinal;
%% plotting
figure;
imshow(MosaicFinal);%,'XData', (1:size(MosaicFinal,2))*0.025, 'YData', (1:size(MosaicFinal,1))*0.025);
axis on;
xlabel('x (mm)')
ylabel('y (mm)')
% title('Scattering coefficient (mm-1)')
colorbar;caxis([0 10]);

% MosaicFinal(MosaicFinal(:)>0.06)=0.06;
% MosaicFinal=MosaicFinal*1000;

%    MosaicFinal = uint16(65535*(mat2gray(MosaicFinal)));        % change this line if using mip
% %% save as nifti or tiff    
% %     nii=make_nii(MosaicFinal,[],[],64);
% %     cd('C:\Users\jryang\Downloads\');
% %     save_nii(nii,'aip_day3.nii');
%     cd('C:\Users\jryang\Desktop\Data\0925TDE\incubated\nocut\fitting\');
%     tiffname='mus_10x_full.tif';
%     imwrite(MosaicFinal,tiffname,'Compression','none');

%% generate mean and std images
% win_size=5;
% l1=size(I,1);
% l2=size(I,2);
% slide_mean=zeros(l1-win_size+1,l2-win_size+1);
% slide_std=zeros(l1-win_size+1,l2-win_size+1);
% 
% for i=1:l1-win_size+1
%     for j=1:l2-win_size+1
%         slide_mean(i,j)=mean2(I(i:i+win_size-1,j:j+win_size-1));
%         slide_std(i,j)=std2(I(i:i+win_size-1,j:j+win_size-1));
%     end
% end
% 
% slide_cv=slide_std./slide_mean;
% nanmedian(slide_cv(:))
% 
% figure;
% imshow(slide_cv,'XData', (1:size(slide_std,2))*0.025, 'YData', (1:size(slide_std,1))*0.025);
% axis on;xlabel('x (mm)');ylabel('y (mm)');
% colorbar;caxis([0,1]);
% 
% figure;
% imshow(slide_std,'XData', (1:size(slide_std,2))*0.025, 'YData', (1:size(slide_std,1))*0.025);
% axis on;xlabel('x (mm)');ylabel('y (mm)');
% colorbar;caxis([0,2]);

% save as single precision TIFF files
% img=single(slide_mean);
% tiffname=('slide_mean.tif');
% 
% t = Tiff(tiffname,'w');
% tagstruct.ImageLength     = size(img,1);
% tagstruct.ImageWidth      = size(img,2);
% tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
% tagstruct.BitsPerSample   =32;
% tagstruct.SamplesPerPixel = 1;
% tagstruct.SampleFormat    = Tiff.SampleFormat.IEEEFP;
% tagstruct.Compression     = Tiff.Compression.None;
% tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
% tagstruct.Software        = 'MATLAB';
% t.setTag(tagstruct);
% t.write(img);
% t.close();
% 
% img=single(slide_std);
% tiffname=('slide_std.tif');
% 
% t = Tiff(tiffname,'w');
% tagstruct.ImageLength     = size(img,1);
% tagstruct.ImageWidth      = size(img,2);
% tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
% tagstruct.BitsPerSample   =32;
% tagstruct.SamplesPerPixel = 1;
% tagstruct.SampleFormat    = Tiff.SampleFormat.IEEEFP;
% tagstruct.Compression     = Tiff.Compression.None;
% tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
% tagstruct.Software        = 'MATLAB';
% t.setTag(tagstruct);
% t.write(img);
% t.close();

%% compute the ratio and plot histogram
% R_mus_full=slide_std./slide_mean;
%figure;histogram(R,100);