function[]=BaSiC_shading_and_ref_stitch(id,P2path, datapath, ntiles, depth, thickness,stitch, aip_threshold)
% add path of functions
addpath('/projectnb/npbssmic/s/Matlab_code/fitting_code');
addpath('/projectnb/npbssmic/s/Matlab_code/PostProcessing');
addpath('/projectnb/npbssmic/s/Matlab_code/PSOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code/ThorOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code');
resize_factor=0.25;
datapath2 = strcat(datapath,'dist_corrected/');
tmp_path = strcat(datapath2,'tmp',num2str(id),'/');
mkdir(tmp_path);
vol_path=strcat(datapath2,'volume/');
mkdir(vol_path);
cd(datapath2);
%% Read each tiles and downsample
islice=id;
filename0=dir(strcat(datapath2,'cross-',num2str(islice),'-*.dat'));
name1=strsplit(filename0(1).name,'.');  
name_dat=strsplit(name1{1},'-');   
nk = str2num(name_dat{4}); nxRpt = 1; nx=str2num(name_dat{5}); nyRpt = 1; ny = str2num(name_dat{6});
dim=[nk nxRpt nx nyRpt ny];
ref_tiles=zeros(ntiles,round(thickness*resize_factor),1000*resize_factor,1000*resize_factor,'single');
tic
for i=1:ntiles
    
    filename0=dir(strcat('cross-',num2str(islice),'-',num2str(i),'-*.dat'));
    
    if length(filename0)==1
        ifilePath=[datapath2,filename0(1).name];
        cross = single(ReadDat_int16(ifilePath, dim))./65535*4;
        cross=cross(depth:end,:,:);
        cross=imresize3(cross,resize_factor);
        % added depth normalization
        cross=depth_corr(cross,0.0035/resize_factor);
        cross=cross(1:round(thickness*resize_factor),:,:);
        
        filename0=dir(strcat('co-',num2str(islice),'-',num2str(i),'-*.dat'));
        ifilePath=[datapath2,filename0(1).name];
        co = single(ReadDat_int16(ifilePath, dim))./65535*4;
%         co=co(depth:depth+thickness-1,:,:);
        co=co(depth:end,:,:);
        co=imresize3(co,resize_factor);
        % added depth normalization
        co=depth_corr(co,0.0035/resize_factor);
        co=co(1:round(thickness*resize_factor),:,:);
        
        ref_tiles(i,:,:,:)=sqrt(co.^2+cross.^2);    
    else
        ref_tiles(i,:,:,:)=zeros(int16(thickness*resize_factor),int16(nx*resize_factor),int16(ny*resize_factor));
    end
end
toc
%% BaSiC shading correction for each depth
for depth = 1:size(co,1)
    display(strcat('processing depth: ',num2str(depth)));
    for tile=1:ntiles
        slice=squeeze(ref_tiles(tile,depth,:,:)); 
        tiffname=strcat(tmp_path,'ref.tif');
        SaveTiff(slice,tile,tiffname);
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
    try
        tic
        system(['xvfb-run -a ' '/projectnb/npbssmic/ns/Fiji/Fiji.app/ImageJ-linux64 --run ',macropath]);
        toc
        % read corrected depth
        for tile=1:ntiles
            ref_tiles(tile,depth,:,:)=squeeze(single(imread(cor_filename, tile)));
        end
    catch
        system(['xvfb-run -a ' '/projectnb/npbssmic/ns/Fiji/Fiji.app/ImageJ-linux64 --run ',macropath]);
        disp("BaSiC shading correction failed")
    end
end

%% start vol stitch
Xsize=1000;
Ysize=1000;
Xoverlap=0.15;
Yoverlap=0.15;
% resize_factor=0.5;
% add path of functions
addpath('/projectnb/npbssmic/s/Matlab_code/PSOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code/ThorOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code/NIfTI_20140122');
%% get FIJI stitching coordinates
% use following 3 lines if stitch using OCT coordinates
if stitch==1
    coordpath = strcat(datapath,'aip/RGB/');
    f=strcat(coordpath,'TileConfiguration.registered.txt');
    coord = read_Fiji_coord(f,'Composite');
%     coord(2:3,:)=coord(2:3,:);

% use following 3 lines if stitch using OCT coordinates -- obsolete
%     f=strcat(datapath,'aip/vol',num2str(9),'/TileConfiguration.registered.txt');
%     coord = read_Fiji_coord(f,'aip');
else
% use following 3 lines if stitch using 2P coordinates
    coordpath = strcat(P2path,'aip/RGB/');
    f=strcat(coordpath,'TileConfiguration.registered.txt');
    coord = read_Fiji_coord(f,'Composite');
    coord(2:3,:)=coord(2:3,:).*2/3;
end
%          coord(2:3,:)=coord(2:3,:).*2/3; %for samples after 09/17/21
%     coord(2,:)=coord(2,:).*1.62/3; %for sample 8921 only
%     coord(3,:)=coord(3,:).*1.82/3; %for sample 8921  only

Xcen=zeros(size(coord,2),1);
Ycen=zeros(size(coord,2),1);
index=coord(1,:);
for ii=1:size(coord,2)
    Xcen(coord(1,ii))=round(coord(3,ii));
    Ycen(coord(1,ii))=round(coord(2,ii));
end

%% Generating blending mask
Xcen=Xcen-min(Xcen);
Ycen=Ycen-min(Ycen);

Xcen=Xcen+round(Xsize/2);
Ycen=Ycen+round(Ysize/2);

stepx = floor(Xoverlap*Xsize*resize_factor);
x = [0:stepx repmat(stepx,1,round((1-2*Xoverlap)*Xsize*resize_factor)) stepx-1:-1:0]./stepx;
stepy = floor(Yoverlap*Ysize*resize_factor);
y = [0:stepy repmat(stepy,1,round((1-2*Yoverlap)*Ysize*resize_factor)) stepy-1:-1:0]./stepy;
[rampy,rampx]=meshgrid(y,x);
ramp=rampx.*rampy;      % blending mask

cd(vol_path);

for nslice=id
    Mosaic = zeros(round(max(Xcen*resize_factor))+round(Xsize/2*resize_factor) ,round(max(Ycen*resize_factor))+round(Ysize/2*resize_factor),round(thickness*resize_factor));
    Masque = zeros(size(Mosaic));
    %% Fill in each tile to position
    for i=1:length(index)
        in = index(i);
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
    %% remove agarose
% %     if rem(id,2)==0
% %         id_aip=id-1;
% %     else
% %         id_aip=id;
% %     end
%     id_aip=id;
%     while ~isfile(strcat(datapath,'aip/aip',num2str(id_aip),'.mat'))
%         pause(600);
%     end
%     load(strcat(datapath,'aip/aip',num2str(id_aip),'.mat'));
%     AIP=imresize(AIP,resize_factor);
%     mask=zeros(size(AIP));
%     mask(AIP>aip_threshold)=1;
%     
%     if size(mask,1)>size(Ref,1)
%         xx=size(Ref,1);
%     else
%         xx=size(mask,1);
%     end
%     if size(mask,2)>size(Ref,2)
%         yy=size(Ref,2);
%     else
%         yy=size(mask,2);
%     end
%     for ii = 1:size(Ref,3)
%         Ref(1:xx,1:yy,ii)=Ref(1:xx,1:yy,ii).*mask(1:xx,1:yy);
%     end
    %% save data
    save(strcat(datapath2,'volume/ref_4ds',num2str(nslice),'.mat'),'Ref','-v7.3');

   clear options;
   options.big = true; % Use BigTIFF format
   options.overwrite = true;
   saveastiff(single(Ref), strcat('Ref_BASIC_4ds',num2str(id),'.btf'), options);
   
   clear options;
   options.big = false; % Use BigTIFF format
   options.overwrite = true;
   saveastiff(single(imresize3(Ref,0.4)), strcat('Ref_BASIC_10ds',num2str(id),'.tif'), options);
   
    info=strcat('Volumetric reconstruction of slice No.', num2str(nslice), ' is done.\n');
    fprintf(info);

end