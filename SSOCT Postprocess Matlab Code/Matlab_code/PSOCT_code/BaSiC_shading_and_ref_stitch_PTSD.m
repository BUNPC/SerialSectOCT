function[]=BaSiC_shading_and_ref_stitch_PTSD(id, datapath, depth, thickness)
% add path of functions
addpath('/projectnb/npbssmic/s/Matlab_code/fitting_code');
addpath('/projectnb/npbssmic/s/Matlab_code/PostProcessing');
addpath('/projectnb/npbssmic/s/Matlab_code/PSOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code/ThorOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code');
resize_factor=0.5;
datapath2 = strcat(datapath,'dist_corrected/');
tmp_path = strcat(datapath2,'tmp',num2str(id),'/');
mkdir(tmp_path);
vol_path=strcat(datapath2,'volume/');
mkdir(vol_path);
cd(datapath2);
%% cross pol correction
% read tiles
islice=id;
filename0=dir(strcat(datapath2,'cross-',num2str(islice),'-*.dat'));
ntiles=length(filename0);
name1=strsplit(filename0(1).name,'.');  
name_dat=strsplit(name1{1},'-');   
nk = str2num(name_dat{4}); nxRpt = 1; nx=str2num(name_dat{5}); nyRpt = 1; ny = str2num(name_dat{6});
dim=[nk nxRpt nx nyRpt ny];
ref_tiles=zeros(ntiles,thickness*resize_factor,1000*resize_factor,1000*resize_factor,'single');
tic
for i=1:ntiles
    i
    filename0=dir(strcat('cross-',num2str(islice),'-',num2str(i),'-*.dat'));
    ifilePath=[datapath2,filename0(1).name];
    cross = single(ReadDat_int16(ifilePath, dim))./65535*4;
    cross=cross(depth:depth+thickness-1,:,:);
    cross=imresize3(cross,resize_factor);
    
    filename0=dir(strcat('co-',num2str(islice),'-',num2str(i),'-*.dat'));
    ifilePath=[datapath2,filename0(1).name];
    co = single(ReadDat_int16(ifilePath, dim))./65535*4;
    co=co(depth:depth+thickness-1,:,:);
    co=imresize3(co,resize_factor);
    
    tmp=sqrt(co.^2+cross.^2);
    ref_tiles(i,:,:,:)=tmp;
end
toc
% BaSiC shading correction for each depth
for depth = 1:(thickness*resize_factor)
    display(strcat('processing depth: ',num2str(depth)));
    slice=squeeze(ref_tiles(1,depth,:,:));
    tiffname=strcat(tmp_path,'ref.tif');
    t = Tiff(tiffname,'w');
    tagstruct.ImageLength     = size(slice,1);
    tagstruct.ImageWidth      = size(slice,2);
    tagstruct.SampleFormat    = Tiff.SampleFormat.IEEEFP;
    tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
    tagstruct.BitsPerSample   = 32;
    tagstruct.SamplesPerPixel = 1;
    tagstruct.Compression     = Tiff.Compression.None;
    tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
    tagstruct.Software        = 'MATLAB';
    t.setTag(tagstruct);
    t.write(slice);
    t.close();
    tic
    for tile=2:ntiles
        slice=squeeze(ref_tiles(tile,depth,:,:));
        tiffname=strcat(tmp_path,'ref.tif');
        t = Tiff(tiffname,'a');
        tagstruct.ImageLength     = size(slice,1);
        tagstruct.ImageWidth      = size(slice,2);
        tagstruct.SampleFormat    = Tiff.SampleFormat.IEEEFP;
        tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
        tagstruct.BitsPerSample   = 32;
        tagstruct.SamplesPerPixel = 1;
        tagstruct.Compression     = Tiff.Compression.None;
        tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
        tagstruct.Software        = 'MATLAB';
        t.setTag(tagstruct);
        t.write(slice);
        t.close();
    end
    toc
    macropath=strcat(tmp_path,'BaSiC.ijm');
    cor_filename=strcat(tmp_path,'ref_cor.tif');
    fid_Macro = fopen(macropath, 'w');
    filename=strcat(tmp_path,'ref.tif');
    fprintf(fid_Macro,'open("%s");\n',filename);
    fprintf(fid_Macro,'run("BaSiC ","processing_stack=ref.tif flat-field=None dark-field=None shading_estimation=[Estimate shading profiles] shading_model=[Estimate both flat-field and dark-field] setting_regularisationparametes=Automatic temporal_drift=Ignore correction_options=[Compute shading and correct images] lambda_flat=0.50 lambda_dark=0.50");\n');
    fprintf(fid_Macro,'selectWindow("Corrected:ref.tif");\n');
    fprintf(fid_Macro,'saveAs("Tiff","%s");\n',cor_filename);
    fprintf(fid_Macro,'close();\n');
    fprintf(fid_Macro,'close();\n');
    fprintf(fid_Macro,'close();\n');
    fprintf(fid_Macro,'close();\n');
    fprintf(fid_Macro,'run("Quit");\n');
    fclose(fid_Macro);
    tic
    system(['xvfb-run -a ' '/projectnb/npbssmic/ns/Fiji/Fiji.app/ImageJ-linux64 --run ',macropath]);
    toc
    % read corrected depth
    tic
    for tile=1:ntiles
        slice= single(imread(cor_filename, tile));
        ref_tiles(tile,depth,:,:)=squeeze(slice);
    end
    toc
end

%% vol stitch
Xsize=1000;
Ysize=1000;
Xoverlap=0.15;
Yoverlap=0.15;
resize_factor=0.5;
% add path of functions
addpath('/projectnb/npbssmic/s/Matlab_code/PSOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code/ThorOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code/NIfTI_20140122');
% use following 3 lines if using OCT coordinates
filepath = strcat(datapath,'aip/vol1/');
f=strcat(filepath,'TileConfiguration.registered.txt');
coord = read_Fiji_coord(f,'aip');

% use following 4 lines if using 2P coordinates
% filepath = strcat(P2path,'aip/RGB/');
% f=strcat(filepath,'TileConfiguration.registered.txt');
% coord = read_Fiji_coord(f,'Composite');
% coord(2:3,:)=coord(2:3,:)./3*2;
%     coord(2,:)=coord(2,:).*1.62/3;
%     coord(3,:)=coord(3,:).*1.82/3;

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

% blending & mosaicing
cd(vol_path);

for nslice=id
    Mosaic = zeros(round(max(Xcen*resize_factor))+round(Xsize/2*resize_factor) ,round(max(Ycen*resize_factor))+round(Ysize/2*resize_factor),round(thickness*resize_factor));
    Masque = zeros(size(Mosaic));

    for i=1:length(index)
        in = index(i);

        % row and column start with +2 only for PSOCT0103
        row = round(Xcen(in)*resize_factor)-round(Xsize/2*resize_factor)+1:round(Xcen(in)*resize_factor)+round(Xsize/2*resize_factor);
        column = round(Ycen(in)*resize_factor)-round(Ysize/2*resize_factor)+1:round(Ycen(in)*resize_factor)+round(Ysize/2*resize_factor);  
        vol=squeeze(ref_tiles(in,:,:,:));
        for j=1:size(vol,1)
            Masque(row,column,j)=Masque(row,column,j)+ramp;
            Mosaic(row,column,j)=Mosaic(row,column,j)+squeeze(vol(j,:,:)).*ramp;        
        end 
    end

    Ref=Mosaic./Masque;
    Ref(isnan(Ref(:)))=0;
    Ref=single(Ref);

    save(strcat(datapath2,'volume/ref',num2str(nslice),'.mat'),'Ref','-v7.3');

%    clear options;
%    options.big = true; % Use BigTIFF format
%    options.overwrite = true;
%    saveastiff(Ref, strcat('Ref_BASIC',num2str(id),'.btf'), options);

    info=strcat('Volumetric reconstruction of slice No.', num2str(nslice), ' is done.\n');
    fprintf(info);

end