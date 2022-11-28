function[]=ref_vol_stitch_non_ds(id,datapath, depth, thickness)
Xsize=1000;
Ysize=1000;
Xoverlap=0.15;
Yoverlap=0.15;

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

stepx = floor(Xoverlap*Xsize);
x = [0:stepx-1 repmat(stepx,1,round((1-2*Xoverlap)*Xsize)) stepx-1:-1:0]./stepx;
stepy = floor(Yoverlap*Ysize);
y = [0:stepy-1 repmat(stepy,1,round((1-2*Yoverlap)*Ysize)) stepy-1:-1:0]./stepy;
[rampy,rampx]=meshgrid(y,x);
ramp=rampx.*rampy;      % blending mask

%% blending & mosaicing

% thickness=50;

datapath = strcat(datapath,'dist_corrected/');
cd(datapath);


for nslice=id
    Mosaic = single(zeros(round(max(Xcen))+round(Xsize/2) ,round(max(Ycen))+round(Ysize/2),round(thickness)));
    Masque = single(zeros(size(Mosaic)));
    filename0=dir(strcat(datapath,'ref-',num2str(nslice),'-',num2str(1),'-*.dat'));
    name1=strsplit(filename0(1).name,'.');  
    name_dat=strsplit(name1{1},'-');   
    nk = str2num(name_dat{4}); nxRpt = 1; nx=str2num(name_dat{5}); nyRpt = 1; ny = str2num(name_dat{6});
    % only for PSOCT0103
    % nk = 108; nxRpt = 1; nx = 1060; nyRpt = 1; ny = 1060;
    dim=[nk nxRpt nx nyRpt ny];

    for i=1:length(index)
        in = index(i);
        filename0=dir(strcat('ref-',num2str(nslice),'-',num2str(in),'-*.dat'));
        % only for PSOCT0103
        % filename0=dir(strcat(num2str(nslice),'-',num2str(in),'-*.dat'));
        ifilePath=[datapath,filename0(1).name];
        info=strcat('Finished loading tile No.', num2str(in),'\n');
        fprintf(info);

        vol = single(ReadDat_int16(ifilePath, dim)./65535*2);       
        % only for PSOCT0103
        % slice = ReadDat_single(ifilePath, dim); 
%         slice(31:74,:,:) = speckle_reduction(double(slice(31:74,:,:)));
%         slice = depth_corr(slice,0.0035);
        vol = vol(depth:depth+thickness-1,:,:);

        % row and column start with +2 only for PSOCT0103
        row = round(Xcen(in))-round(Xsize/2)+1:round(Xcen(in))+round(Xsize/2);
        column = round(Ycen(in))-round(Ysize/2)+1:round(Ycen(in))+round(Ysize/2);  


        for j=1:size(vol,1)
            Masque(row,column,j)=Masque(row,column,j)+ramp;
            Mosaic(row,column,j)=Mosaic(row,column,j)+squeeze(vol(j,:,:)).*ramp;      
        end 
    end

    Ref=int16(Mosaic./Masque/4*65535);
    Ref(isnan(Ref(:)))=0;
    Ref=single(Ref);

    save(strcat(datapath,'volume/ref',num2str(nslice),'.mat'),'Ref','-v7.3');
    % only for PSOCT0103
    % save(strcat(datapath,'volume/ref',num2str(nslice),'.mat'),'Ref','-v7.3');

% save as TIFF
%     s=uint16(65535*(mat2gray(Mosaic))); 
%     tiffname=strcat('/projectnb/npbssmic/ns/200301_PSOCT/second/corrected/nii/vol',num2str(nslice),'.tif');
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
clear options;
options.big = true; % Use BigTIFF format
saveastiff(Ref, strcat(datapath,'dist_corrected/volume/ref',num2str(nslice),'.btf'), options);
    info=strcat('Volumetric reconstruction of slice No.', num2str(nslice), ' is done.\n');
    fprintf(info);

end