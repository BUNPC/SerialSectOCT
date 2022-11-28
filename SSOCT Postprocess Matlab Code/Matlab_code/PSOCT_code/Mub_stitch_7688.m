function Mub_stitch_7688(target, P2path, datapath,disp,mosaic,pxlsize,islice,pattern,sys)
%% define grid pattern
% add subfunctions for the script
addpath('/projectnb/npbssmic/s/Matlab_code');

result=target;
id=islice;
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

numTile=numX*numY;
%% write coordinates to file

filepath=strcat(datapath,'fitting/vol',num2str(islice),'/');
cd(filepath);

%% get FIJI stitching info
% use following 3 lines if stitch using OCT coordinates
f=strcat(datapath,'aip/vol',num2str(1),'/TileConfiguration.registered.txt');
coord = read_Fiji_coord(f,'aip');
coord(2:3,:)=coord(2:3,:)./10;

% use following 3 lines if stitch using 2P coordinates

% f=strcat(P2path,'aip/RGB/TileConfiguration.registered.txt');
% coord = read_Fiji_coord(f,'Composite');
% % coord(2:3,:)=coord(2:3,:)./3*2/4;
% coord(2,:)=coord(2,:).*1.62/3/4;
% coord(3,:)=coord(3,:).*1.82/3/4;

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

% tile range -199~+200
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

%% flagg mus tiles
% load(strcat(datapath,'aip/vol',num2str(islice),'/tile_flag.mat'));
tile_flag=ones(1,numX*numY);
filename0=dir('MUB.tif');
filename = strcat(filepath,'MUB_flagged.tif');
flagged=0;
for j=1:numX*numY
    if tile_flag(j)>0
        mub = single(imread(filename0(1).name, j));
        
        if flagged==0
            t = Tiff(filename,'w');
            flagged=1;
        else
            t = Tiff(filename,'a');
        end
        tagstruct.ImageLength     = size(mub,1);
        tagstruct.ImageWidth      = size(mub,2);
        tagstruct.SampleFormat    = Tiff.SampleFormat.IEEEFP;
        tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
        tagstruct.BitsPerSample   = 32;
        tagstruct.SamplesPerPixel = 1;
        tagstruct.Compression     = Tiff.Compression.None;
        tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
        tagstruct.Software        = 'MATLAB';
        t.setTag(tagstruct);
        t.write(mub);
        t.close();

    end   
end
% 
% %% BaSiC shading correction
    macropath=strcat(datapath,'fitting/vol',num2str(islice),'/BaSiC.ijm');
    cor_filename=strcat(datapath,'fitting/vol',num2str(islice),'/','MUB_cor.tif');
    fid_Macro = fopen(macropath, 'w');
    filename=strcat(datapath,'fitting/vol',num2str(islice),'/','MUB_flagged.tif');
    fprintf(fid_Macro,'open("%s");\n',filename);
    fprintf(fid_Macro,'run("BaSiC ","processing_stack=MUB_flagged.tif flat-field=None dark-field=None shading_estimation=[Estimate shading profiles] shading_model=[Estimate both flat-field and dark-field] setting_regularisationparametes=Automatic temporal_drift=Ignore correction_options=[Compute shading and correct images] lambda_flat=0.50 lambda_dark=0.50");\n');
    fprintf(fid_Macro,'selectWindow("Corrected:MUB_flagged.tif");\n');
    fprintf(fid_Macro,'saveAs("Tiff","%s");\n',cor_filename);
    fprintf(fid_Macro,'close();\n');
    fprintf(fid_Macro,'close();\n');
    fprintf(fid_Macro,'close();\n');
    fprintf(fid_Macro,'close();\n');
    fprintf(fid_Macro,'run("Quit");\n');
    fclose(fid_Macro);
    system(['xvfb-run -a ' '/projectnb/npbssmic/ns/Fiji/Fiji.app/ImageJ-linux64 --run ',macropath]);
% %     system(['/projectnb/npbssmic/ns/Fiji/Fiji.app/ImageJ-linux64 -macro ',macropath]);
    
    %write uncorrected MUB.tif tiles
    filename0=strcat(datapath,'fitting/vol',num2str(islice),'/','MUB.tif');
    filename0=dir(filename0);
    for iFile=1:numX*numY%length(tile_flag)
        this_tile=iFile;
        mub = double(imread(filename0(1).name, iFile));
        avgname=strcat(datapath,'fitting/vol',num2str(islice),'/',num2str(this_tile),'.mat');
        save(avgname,'mub');  

        mub=single(mub);
        tiffname=strcat(datapath,'fitting/vol',num2str(islice),'/',num2str(this_tile),'_mub.tif');
        t = Tiff(tiffname,'w');
        tagstruct.ImageLength     = size(mub,1);
        tagstruct.ImageWidth      = size(mub,2);
        tagstruct.SampleFormat    = Tiff.SampleFormat.IEEEFP;
        tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
        tagstruct.BitsPerSample   = 32;
        tagstruct.SamplesPerPixel = 1;
        tagstruct.Compression     = Tiff.Compression.None;
        tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
        tagstruct.Software        = 'MATLAB';
        t.setTag(tagstruct);
        t.write(mub);
        t.close();

    end
    % write corrected MUB_cor.tif tiles
    filename0=strcat(datapath,'fitting/vol',num2str(islice),'/','MUB_cor.tif');
    filename0=dir(filename0);
    for iFile=1:sum(tile_flag)
        for tm=1:numX*numY
            if sum(tile_flag(1:tm))==iFile
                this_tile=tm;
                break
            end
        end
        mub = double(imread(filename0(1).name, iFile));
        avgname=strcat(datapath,'fitting/vol',num2str(islice),'/',num2str(this_tile),'.mat');
        save(avgname,'mub');  

        mub=single(mub);
        tiffname=strcat(datapath,'fitting/vol',num2str(islice),'/',num2str(this_tile),'_mub.tif');
        t = Tiff(tiffname,'w');
        tagstruct.ImageLength     = size(mub,1);
        tagstruct.ImageWidth      = size(mub,2);
        tagstruct.SampleFormat    = Tiff.SampleFormat.IEEEFP;
        tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
        tagstruct.BitsPerSample   = 32;
        tagstruct.SamplesPerPixel = 1;
        tagstruct.Compression     = Tiff.Compression.None;
        tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
        tagstruct.Software        = 'MATLAB';
        t.setTag(tagstruct);
        t.write(mub);
        t.close();

    end

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
            Mosaic(row,column)=Mosaic(row,column)+mub.*Masque2(row,column);
        elseif strcmp(sys,'Thorlabs')
            Mosaic(row,column)=Mosaic(row,column)+mub'.*Masque2(row,column);
        end
        
end

% process the blended image
MosaicFinal=Mosaic./Masque;
MosaicFinal(isnan(MosaicFinal))=0;
% MosaicFinal(MosaicFinal>20)=0;
if strcmp(sys,'Thorlabs')
    MosaicFinal=MosaicFinal';
end
save(strcat(datapath,'fitting/',result,num2str(islice),'.mat'),'MosaicFinal');
MosaicFinal = single(MosaicFinal);   
%     nii=make_nii(MosaicFinal,[],[],64);
%     cd('C:\Users\jryang\Downloads\');
%     save_nii(nii,'aip_day3.nii');
% cd(filepath);
tiffname=strcat(datapath,'fitting/',result,num2str(islice),'.tif');
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