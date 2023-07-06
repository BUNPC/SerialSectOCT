function[]=BaSiC_shading_and_ori_stitch(id,P2path, datapath, ntiles, depth, thickness)
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
%% cross pol correction
% read tiles
islice=id;
filename0=dir(strcat(datapath2,'ori-',num2str(islice),'-*.dat'));
name1=strsplit(filename0(1).name,'.');  
name_dat=strsplit(name1{1},'-');   
nk = str2num(name_dat{4}); nxRpt = 1; nx=str2num(name_dat{5}); nyRpt = 1; ny = str2num(name_dat{6});
dim=[nk nxRpt nx nyRpt ny];
ori_tiles=zeros(ntiles,round(thickness*resize_factor),1000*resize_factor,1000*resize_factor,'single');
tic
for i=1:ntiles
    filename0=dir(strcat('ori-',num2str(islice),'-',num2str(i),'-*.dat'));
    if length(filename0)==1
        
        ifilePath=[datapath2,filename0(1).name];
        ori = (single(ReadDat_int16(ifilePath, dim))./65535-0.5).*180;
        ori=ori(depth:depth+thickness-1,:,:);
        ori=imresize3(ori,resize_factor);

    else
        ori=zeros(int16(thickness*resize_factor),int16(nx*resize_factor),int16(ny*resize_factor));
    end
    ori_tiles(i,:,:,:)=ori;
end
toc
% BaSiC shading correction for each depth
% for depth = 1:size(ori,1)
%     display(strcat('processing depth: ',num2str(depth)));
%     for tile=1:ntiles
%         slice=squeeze(ori_tiles(tile,depth,:,:)); 
%         tiffname=strcat(tmp_path,'ori.tif');
%         if tile==1
%             t = Tiff(tiffname,'w');
%         else
%             t = Tiff(tiffname,'a');
%         end
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
%     toc
%     macropath=strcat(tmp_path,'BaSiC.ijm');
%     cor_filename=strcat(tmp_path,'ori_cor.tif');
%     fid_Macro = fopen(macropath, 'w');
%     filename=strcat(tmp_path,'ori.tif');
%     fprintf(fid_Macro,'open("%s");\n',filename);
%     fprintf(fid_Macro,'run("BaSiC ","processing_stack=ori.tif flat-field=None dark-field=None shading_estimation=[Estimate shading profiles] shading_model=[Estimate both flat-field and dark-field] setting_regularisationparametes=Automatic temporal_drift=Ignore correction_options=[Compute shading and correct images] lambda_flat=0.50 lambda_dark=0.50");\n');
%     fprintf(fid_Macro,'selectWindow("Corrected:ori.tif");\n');
%     fprintf(fid_Macro,'saveAs("Tiff","%s");\n',cor_filename);
%     fprintf(fid_Macro,'close();\n');
%     fprintf(fid_Macro,'close();\n');
%     fprintf(fid_Macro,'close();\n');
%     fprintf(fid_Macro,'close();\n');
%     fprintf(fid_Macro,'run("Quit");\n');
%     fclose(fid_Macro);
%     try
%         tic
%         system(['xvfb-run -a ' '/projectnb/npbssmic/ns/Fiji/Fiji.app/ImageJ-linux64 --run ',macropath]);
%         toc
%         % read corrected depth
%         for tile=1:ntiles
%             slice= single(imread(cor_filename, tile));
%             ori_tiles(tile,depth,:,:)=squeeze(slice);
%         end
%     catch
%         display("BaSiC shading correction failed")
%     end
% end

%% vol stitch
Xsize=1000;
Ysize=1000;
Xoverlap=0.15;
Yoverlap=0.15;
% resize_factor=0.5;
% add path of functions
addpath('/projectnb/npbssmic/s/Matlab_code/PSOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code/ThorOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code/NIfTI_20140122');
% use following 3 lines if using OCT coordinates
% filepath = strcat(datapath,'aip/vol1/');
% f=strcat(filepath,'TileConfiguration.registered.txt');
% coord = read_Fiji_coord(f,'aip');

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
% ds_factor=1,0.5
% stepx = floor(Xoverlap*Xsize*resize_factor);
% x = [0:stepx repmat(stepx,1,round((1-2*Xoverlap)*Xsize*resize_factor)) stepx-1:-1:1]./stepx;
% stepy = floor(Yoverlap*Ysize*resize_factor);
% y = [0:stepy repmat(stepy,1,round((1-2*Yoverlap)*Ysize*resize_factor)) stepy-1:-1:1]./stepy;

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
        vol=squeeze(ori_tiles(in,:,:,:));
        for j=1:size(vol,1)
            Masque(row,column,j)=Masque(row,column,j)+ramp;
            Mosaic(row,column,j)=Mosaic(row,column,j)+squeeze(vol(j,:,:)).*ramp;        
        end 
    end

    Ori=Mosaic./Masque;
    Ori(isnan(Ori(:)))=0;
    Ori=single(Ori);

    save(strcat(datapath2,'volume/ori',num2str(nslice),'.mat'),'Ori','-v7.3');

%    clear options;
%    options.big = true; % Use BigTIFF format
%    options.overwrite = true;
%    saveastiff(single(Ori), strcat('Ori_BASIC',num2str(id),'.btf'), options);
%    
%    clear options;
%    options.big = false; % Use BigTIFF format
%    options.overwrite = true;
%    saveastiff(single(imresize3(Ori,0.4)), strcat('Ori_BASIC',num2str(id),'.tif'), options);
   
    info=strcat('Volumetric reconstruction of slice No.', num2str(nslice), ' is done.\n');
    fprintf(info);

end