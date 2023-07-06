function[]=BaSiC_shading_and_ret_stitch(id,P2path,datapath, ntiles,depth, thickness)
% add path of functions
addpath('/projectnb/npbssmic/s/Matlab_code/fitting_code');
addpath('/projectnb/npbssmic/s/Matlab_code/PostProcessing');
addpath('/projectnb/npbssmic/s/Matlab_code/PSOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code/ThorOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code');
%thickness=40;
resize_factor=0.2;
cor_path = strcat(datapath,'dist_corrected/');
% tmp_path = strcat(datapath,'dist_corrected/','tmp/');
% mkdir(tmp_path);
vol_path=strcat(datapath,'dist_corrected/','volume/');
% mkdir(vol_path);
cd(cor_path);
%% cross pol correction
% read tiles
islice=id;
filename0=dir(strcat(cor_path,'cross-',num2str(islice),'*.dat'));
% ntiles=length(filename0);
name1=strsplit(filename0(1).name,'.');  
name_dat=strsplit(name1{1},'-');   
nk = str2num(name_dat{4}); nxRpt = 1; nx=str2num(name_dat{5}); nyRpt = 1; ny = str2num(name_dat{6});
dim=[nk nxRpt nx nyRpt ny];
cross_tiles=zeros(ntiles,thickness*resize_factor,1000*resize_factor,1000*resize_factor,'single');
for i=1:ntiles
    filename0=dir(strcat('cross-',num2str(islice),'-',num2str(i),'-*.dat'));
    if length(filename0)==1
        ifilePath=[cor_path,filename0(1).name];
        tmp = single(ReadDat_int16(ifilePath, dim))./65535*4;
        tmp=tmp(depth:depth+thickness-1,:,:);
        tmp=imresize3(tmp,resize_factor);
        cross_tiles(i,:,:,:)=tmp;
    else
%         co=zeros(int16(thickness*resize_factor),int16(nx*resize_factor),int16(ny*resize_factor));
        cross_tiles(i,:,:,:)=zeros(int16(thickness*resize_factor),int16(nx*resize_factor),int16(ny*resize_factor));
    end
end
% % BaSiC shading correction for each depth
% sum_all=squeeze(mean(cross_tiles,1));
% sum_all=squeeze(mean(mean(sum_all,2),3));
% sum_all=sum_all./max(sum_all);
% for depth = 1:(thickness*resize_factor)
%     display(strcat('processing depth: ',num2str(depth)));
%     slice=squeeze(cross_tiles(1,depth,:,:));
%     tiffname=strcat(tmp_path,'CROSS.tif');
%     t = Tiff(tiffname,'w');
%     tagstruct.ImageLength     = size(slice,1);
%     tagstruct.ImageWidth      = size(slice,2);
%     tagstruct.SampleFormat    = Tiff.SampleFormat.IEEEFP;
%     tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
%     tagstruct.BitsPerSample   = 32;
%     tagstruct.SamplesPerPixel = 1;
%     tagstruct.Compression     = Tiff.Compression.None;
%     tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
%     tagstruct.Software        = 'MATLAB';
%     t.setTag(tagstruct);
%     t.write(slice);
%     t.close();
%     for tile=2:ntiles
%         slice=squeeze(cross_tiles(tile,depth,:,:));
%         tiffname=strcat(tmp_path,'CROSS.tif');
%         t = Tiff(tiffname,'a');
%         tagstruct.ImageLength     = size(slice,1);
%         tagstruct.ImageWidth      = size(slice,2);
%         tagstruct.SampleFormat    = Tiff.SampleFormat.IEEEFP;
%         tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
%         tagstruct.BitsPerSample   = 32;
%         tagstruct.SamplesPerPixel = 1;
%         tagstruct.Compression     = Tiff.Compression.None;
%         tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
%         tagstruct.Software        = 'MATLAB';
%         t.setTag(tagstruct);
%         t.write(slice);
%         t.close();
%     end
%     macropath=strcat(tmp_path,'BaSiC.ijm');
%     cor_filename=strcat(tmp_path,'CROSS_cor.tif');
%     fid_Macro = fopen(macropath, 'w');
%     filename=strcat(tmp_path,'CROSS.tif');
%     fprintf(fid_Macro,'open("%s");\n',filename);
%     fprintf(fid_Macro,'run("BaSiC ","processing_stack=CROSS.tif flat-field=None dark-field=None shading_estimation=[Estimate shading profiles] shading_model=[Estimate both flat-field and dark-field] setting_regularisationparametes=Automatic temporal_drift=Ignore correction_options=[Compute shading and correct images] lambda_flat=0.50 lambda_dark=0.50");\n');
%     fprintf(fid_Macro,'selectWindow("Corrected:CROSS.tif");\n');
%     fprintf(fid_Macro,'saveAs("Tiff","%s");\n',cor_filename);
%     fprintf(fid_Macro,'close();\n');
%     fprintf(fid_Macro,'close();\n');
%     fprintf(fid_Macro,'close();\n');
%     fprintf(fid_Macro,'close();\n');
%     fprintf(fid_Macro,'run("Quit");\n');
%     fclose(fid_Macro);
%     tic
%     system(['xvfb-run -a ' '/projectnb/npbssmic/ns/Fiji/Fiji.app/ImageJ-linux64 --run ',macropath]);
%     toc
%     % read corrected depth
%     for tile=1:ntiles
%         slice= single(imread(cor_filename, tile));%./sum_all(depth);
%         cross_tiles(tile,depth,:,:)=squeeze(slice);
%     end
% end
%% co pol correction
% read tiles
islice=id;
filename0=dir(strcat(cor_path,'co-',num2str(islice),'*.dat'));
% ntiles=length(filename0);
name1=strsplit(filename0(1).name,'.');  
name_dat=strsplit(name1{1},'-');   
nk = str2num(name_dat{4}); nxRpt = 1; nx=str2num(name_dat{5}); nyRpt = 1; ny = str2num(name_dat{6});
dim=[nk nxRpt nx nyRpt ny];
co_tiles=zeros(ntiles,thickness*resize_factor,1000*resize_factor,1000*resize_factor,'single');
for i=1:ntiles
    filename0=dir(strcat('co-',num2str(islice),'-',num2str(i),'-*.dat'));
    if length(filename0)==1
        ifilePath=[cor_path,filename0(1).name];
        tmp = single(ReadDat_int16(ifilePath, dim))./65535*4;
        tmp=tmp(depth:depth+thickness-1,:,:);
        tmp=imresize3(tmp,resize_factor);
        co_tiles(i,:,:,:)=tmp;
    else
%         co=zeros(int16(thickness*resize_factor),int16(nx*resize_factor),int16(ny*resize_factor));
        co_tiles(i,:,:,:)=zeros(int16(thickness*resize_factor),int16(nx*resize_factor),int16(ny*resize_factor));
    end
end
% % BaSiC shading correction for each depth
% sum_all=squeeze(mean(co_tiles,1));
% sum_all=squeeze(mean(mean(sum_all,2),3));
% sum_all=sum_all./max(sum_all);
% for depth = 1:(thickness*resize_factor)
%     display(strcat('processing depth: ',num2str(depth)));
%     slice=squeeze(co_tiles(1,depth,:,:));
%     tiffname=strcat(tmp_path,'CO.tif');
%     t = Tiff(tiffname,'w');
%     tagstruct.ImageLength     = size(slice,1);
%     tagstruct.ImageWidth      = size(slice,2);
%     tagstruct.SampleFormat    = Tiff.SampleFormat.IEEEFP;
%     tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
%     tagstruct.BitsPerSample   = 32;
%     tagstruct.SamplesPerPixel = 1;
%     tagstruct.Compression     = Tiff.Compression.None;
%     tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
%     tagstruct.Software        = 'MATLAB';
%     t.setTag(tagstruct);
%     t.write(slice);
%     t.close();
%     for tile=2:ntiles
%         slice=squeeze(co_tiles(tile,depth,:,:));
%         tiffname=strcat(tmp_path,'CO.tif');
%         t = Tiff(tiffname,'a');
%         tagstruct.ImageLength     = size(slice,1);
%         tagstruct.ImageWidth      = size(slice,2);
%         tagstruct.SampleFormat    = Tiff.SampleFormat.IEEEFP;
%         tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
%         tagstruct.BitsPerSample   = 32;
%         tagstruct.SamplesPerPixel = 1;
%         tagstruct.Compression     = Tiff.Compression.None;
%         tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
%         tagstruct.Software        = 'MATLAB';
%         t.setTag(tagstruct);
%         t.write(slice);
%         t.close();
%     end
%     macropath=strcat(tmp_path,'BaSiC.ijm');
%     cor_filename=strcat(tmp_path,'CO_cor.tif');
%     fid_Macro = fopen(macropath, 'w');
%     filename=strcat(tmp_path,'CO.tif');
%     fprintf(fid_Macro,'open("%s");\n',filename);
%     fprintf(fid_Macro,'run("BaSiC ","processing_stack=CO.tif flat-field=None dark-field=None shading_estimation=[Estimate shading profiles] shading_model=[Estimate both flat-field and dark-field] setting_regularisationparametes=Automatic temporal_drift=Ignore correction_options=[Compute shading and correct images] lambda_flat=0.50 lambda_dark=0.50");\n');
%     fprintf(fid_Macro,'selectWindow("Corrected:CO.tif");\n');
%     fprintf(fid_Macro,'saveAs("Tiff","%s");\n',cor_filename);
%     fprintf(fid_Macro,'close();\n');
%     fprintf(fid_Macro,'close();\n');
%     fprintf(fid_Macro,'close();\n');
%     fprintf(fid_Macro,'close();\n');
%     fprintf(fid_Macro,'run("Quit");\n');
%     fclose(fid_Macro);
%     tic
%     system(['xvfb-run -a ' '/projectnb/npbssmic/ns/Fiji/Fiji.app/ImageJ-linux64 --run ',macropath]);
%     toc
%     % read corrected depth
%     for tile=1:ntiles
%         slice= single(imread(cor_filename, tile));%./sum_all(depth);
%         co_tiles(tile,depth,:,:)=squeeze(slice);
%     end
% end
%% vol stitch
ret=atan(cross_tiles./co_tiles)./pi*180;
clear cross_tiles
clear co_tiles
Xsize=1000;
Ysize=1000;
Xoverlap=0.15;
Yoverlap=0.15;
% resize_factor=0.1;
% add path of functions
addpath('/projectnb/npbssmic/s/Matlab_code/PSOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code/ThorOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code/NIfTI_20140122');

% use following 4 lines if using 2P coordinates
filepath = strcat(P2path,'aip/RGB/');
f=strcat(filepath,'TileConfiguration.registered.txt');
coord = read_Fiji_coord(f,'Composite');
coord(2:3,:)=coord(2:3,:)./3*2;
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
        vol=squeeze(ret(in,:,:,:));
        for j=1:size(vol,1)
            Masque(row,column,j)=Masque(row,column,j)+ramp;
            Mosaic(row,column,j)=Mosaic(row,column,j)+squeeze(vol(j,:,:)).*ramp;        
        end 
    end

    Ret=Mosaic./Masque;
    Ret(isnan(Ret(:)))=0;
    Ret=single(Ret);

%     save(strcat(datapath,'volume/ref',num2str(nslice),'.mat'),'Ref','-v7.3');
% save as TIFF
    tiffname=strcat('ret_BASIC',num2str(nslice),'.tif');
    
    t = Tiff(tiffname,'a');
    image=single(squeeze(mean(Ret,3)));
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

    clear options;
    options.big = true; % Use BigTIFF format
    saveastiff(Ret, 'Ret_BASIC7.btf', options);

    info=strcat('Volumetric reconstruction of slice No.', num2str(nslice), ' is done.\n');
    fprintf(info);

end