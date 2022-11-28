function[]=ref_vol_stitch_after_BASIC(id,datapath, depth, thickness)
Xsize=1000;
Ysize=1000;
Xoverlap=0.15;
Yoverlap=0.15;
resize_factor=0.5;
% add path of functions
addpath('/projectnb/npbssmic/s/Matlab_code/PSOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code/ThorOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code/NIfTI_20140122');

filepath = strcat(datapath,'aip/vol1/');
f=strcat(filepath,'TileConfiguration.registered.txt');
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

stepx = floor(Xoverlap*Xsize*resize_factor);
x = [0:stepx-1 repmat(stepx,1,round((1-2*Xoverlap)*Xsize*resize_factor)) stepx-1:-1:0]./stepx;
stepy = floor(Yoverlap*Ysize*resize_factor);
y = [0:stepy-1 repmat(stepy,1,round((1-2*Yoverlap)*Ysize*resize_factor)) stepy-1:-1:0]./stepy;
[rampy,rampx]=meshgrid(y,x);
ramp=rampx.*rampy;      % blending mask

%% blending & mosaicing

% thickness=200;%62;

datapath = strcat(datapath,'dist_corrected/volume/');
cd(datapath);

for nslice=id
    Mosaic = zeros(round(max(Xcen*resize_factor))+round(Xsize/2*resize_factor) ,round(max(Ycen*resize_factor))+round(Ysize/2*resize_factor),round(thickness*resize_factor));
    Masque = zeros(size(Mosaic));
    filename0=dir(strcat(datapath,'co-',num2str(nslice),'-',num2str(1),'-*.dat'));
    name1=strsplit(filename0(1).name,'.');  
    name_dat=strsplit(name1{1},'-');   
    nk = str2num(name_dat{4}); nxRpt = 1; nx=str2num(name_dat{5}); nyRpt = 1; ny = str2num(name_dat{6});
    dim=[nk nxRpt nx nyRpt ny];

    for i=1:length(index)
        in = index(i);
        filename0=dir(strcat('co-',num2str(nslice),'-',num2str(in),'-*.dat'));
        ifilePath=[datapath,filename0(1).name];
        slice = (ReadDat_int16(ifilePath, dim)).^2;
        filename0=dir(strcat('cross-',num2str(nslice),'-',num2str(in),'-*.dat'));
        ifilePath=[datapath,filename0(1).name];
        slice = slice+(ReadDat_int16(ifilePath, dim)).^2;
        vol=sqrt(slice);
        
        info=strcat('Finished loading tile No.', num2str(in),'\n');
        fprintf(info);
        
        % row and column start with +2 only for PSOCT0103
        row = round(Xcen(in)*resize_factor)-round(Xsize/2*resize_factor)+1:round(Xcen(in)*resize_factor)+round(Xsize/2*resize_factor);
        column = round(Ycen(in)*resize_factor)-round(Ysize/2*resize_factor)+1:round(Ycen(in)*resize_factor)+round(Ysize/2*resize_factor);  
        for j=1:size(vol,1)
            Masque(row,column,j)=Masque(row,column,j)+ramp;
            Mosaic(row,column,j)=Mosaic(row,column,j)+squeeze(vol(j,:,:)).*ramp;        
        end 
    end

    Ref=Mosaic./Masque;
    Ref(isnan(Ref(:)))=0;
    Ref=single(Ref);

%     save(strcat(datapath,'volume/ref',num2str(nslice),'.mat'),'Ref','-v7.3');
% save as TIFF
%     s=uint16(65535*(mat2gray(Mosaic))); 
%     tiffname=strcat(datapath,'Ref_BASIC',num2str(nslice),'.tif');
%     for i=1:size(Ref,3)
%         t = Tiff(tiffname,'a');
%         image=single(squeeze(Ref(:,:,i)));
%         tagstruct.ImageLength     = size(image,1);
%         tagstruct.ImageWidth      = size(image,2);
%         tagstruct.SampleFormat    = Tiff.SampleFormat.IEEEFP;
%         tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
%         tagstruct.BitsPerSample   = 32;
%         tagstruct.SamplesPerPixel = 1;
%         tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
%         tagstruct.Compression = Tiff.Compression.None;
%         tagstruct.Software        = 'MATLAB';
%         t.setTag(tagstruct);
%         t.write(image);
%         t.close();
%     end
    clear options;
    options.big = true; % Use BigTIFF format
    saveastiff(Ref, 'ref_BASIC1.btf', options);

    info=strcat('Volumetric reconstruction of slice No.', num2str(nslice), ' is done.\n');
    fprintf(info);

end