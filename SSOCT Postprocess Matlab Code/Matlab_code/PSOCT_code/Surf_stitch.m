function Surf_stitch(target, P2path, datapath,disp,mosaic,pxlsize,islice,pattern,sys,stitch)
%% stitch the fitting result using the coordinates from AIP stitch
% add subfunctions for the script
addpath('/projectnb/npbssmic/s/Matlab_code');
id=islice;

filepath=strcat(datapath,'surf/vol',num2str(islice),'/');
cd(filepath);
xx=disp(1);
xy=disp(2);
yy=disp(3);
yx=disp(4);
% mosaic parameters
numX=mosaic(1);
numY=mosaic(2);
Xoverlap=mosaic(3);
Yoverlap=mosaic(4);
Xsize=pxlsize(1);                                                                              %changed by stephan
Ysize=pxlsize(2);
%% get FIJI stitching info
% use following 3 lines if stitch using OCT coordinates
if stitch==1
    coordpath = strcat(datapath,'aip/RGB/');
    f=strcat(coordpath,'TileConfiguration.registered.txt');
    coord = read_Fiji_coord(f,'Composite');
    coord(2:3,:)=coord(2:3,:)./10;

% use following 3 lines if stitch using OCT coordinates -- obsolete
%     f=strcat(datapath,'aip/vol',num2str(9),'/TileConfiguration.registered.txt');
%     coord = read_Fiji_coord(f,'aip');
else
% use following 3 lines if stitch using 2P coordinates
    coordpath = strcat(P2path,'aip/RGB/');
    f=strcat(coordpath,'TileConfiguration.registered.txt');
    coord = read_Fiji_coord(f,'Composite');
    coord(2:3,:)=coord(2:3,:).*2/3/10;
end
%          coord(2:3,:)=coord(2:3,:).*2/3; %for samples after 09/17/21
%     coord(2,:)=coord(2,:).*1.62/3; %for sample 8921 only
%     coord(3,:)=coord(3,:).*1.82/3; %for sample 8921  only

%% define coordinates for each tile

Xcen=zeros(size(coord,2),1);
Ycen=zeros(size(coord,2),1);
index=coord(1,:);
if strcmp(sys,'PSOCT')
    for ii=1:size(coord,2)
        Xcen(coord(1,ii))=round(coord(3,ii));
        Ycen(coord(1,ii))=round(coord(2,ii));
    end
elseif strcmp(sys,'Thorlabs')
    for ii=1:size(coord,2)
        Xcen(coord(1,ii))=round(coord(2,ii));
        Ycen(coord(1,ii))=round(coord(3,ii));
    end
end
Xcen=Xcen-min(Xcen);
Ycen=Ycen-min(Ycen);

Xcen=Xcen+Xsize/2;
Ycen=Ycen+Ysize/2;

stepx = Xoverlap*Xsize;
x = [0:stepx-1 repmat(stepx,1,round((1-2*Xoverlap)*Xsize)) round(stepx-1):-1:0]./stepx;
stepy = Yoverlap*Ysize;
y = [0:stepy-1 repmat(stepy,1,round((1-2*Yoverlap)*Ysize)) round(stepy-1):-1:0]./stepy;
if strcmp(sys,'PSOCT')
    [rampy,rampx]=meshgrid(y, x);
elseif strcmp(sys,'Thorlabs')
    [rampy,rampx]=meshgrid(x, y);
end   
ramp=rampx.*rampy;      % blending mask

%% blending & mosaicing
Mosaic = zeros(round(max(Xcen)+Xsize) ,round(max(Ycen)+Ysize));
Masque = zeros(size(Mosaic));
for i=1:length(index)
        in = index(i);
        filename0=dir(strcat(num2str(in),'.mat'));
        load(filename0.name);
        
        row = round(Xcen(in)-Xsize/2+1:Xcen(in)+Xsize/2);         
        column = round(Ycen(in)-Ysize/2+1:Ycen(in)+Ysize/2);
        Masque2 = zeros(size(Mosaic));
        Masque2(row,column)=ramp;
        Masque(row,column)=Masque(row,column)+Masque2(row,column);
        if strcmp(sys,'PSOCT')
            Mosaic(row,column)=Mosaic(row,column)+sur.*Masque2(row,column);
        elseif strcmp(sys,'Thorlabs')
            Mosaic(row,column)=Mosaic(row,column)+sur'.*Masque2(row,column);
        end
end

MosaicFinal=Mosaic./Masque;
MosaicFinal(isnan(MosaicFinal))=0;
if strcmp(sys,'Thorlabs')
    MosaicFinal=MosaicFinal';
end
    
MosaicFinal = single(MosaicFinal);   
%     nii=make_nii(MosaicFinal,[],[],64);
%     cd('C:\Users\jryang\Downloads\');
%     save_nii(nii,'aip_day3.nii');
% cd(filepath);
tiffname=strcat(datapath,'surf/',target,num2str(id),'.tif');
t = Tiff(tiffname,'w');
image=MosaicFinal;
tagstruct.ImageLength     = size(image,1);
tagstruct.ImageWidth      = size(image,2);
tagstruct.SampleFormat    = Tiff.SampleFormat.IEEEFP;
tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
tagstruct.BitsPerSample   = 32;
tagstruct.SamplesPerPixel = 1;
tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
tagstruct.Compression = Tiff.Compression.None;
tagstruct.Software        = 'MATLAB';
t.setTag(tagstruct);
t.write(image);
t.close();