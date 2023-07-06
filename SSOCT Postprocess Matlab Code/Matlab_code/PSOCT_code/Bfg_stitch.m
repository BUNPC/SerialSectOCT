function Bfg_stitch(target, P2path, datapath,disp,mosaic,pxlsize,islice,pattern,sys,ds,stitch)
%% stitch the fitting result using the coordinates from AIP stitch
%% define grid pattern

% add subfunctions for the script
addpath('/projectnb/npbssmic/s/Matlab_code');
% displacement parameters
% xx=92;
% xy=-4;
% yy=97;
result=target;
id=islice;
% mosaic parameters
% numX=5;
% numY=4;
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
% 

%% write coordinates to file

filepath=strcat(datapath,'fitting/vol',num2str(islice),'/');
cd(filepath);

%% get FIJI stitching info
% use following 3 lines if stitch using OCT coordinates
if stitch==1
    coordpath = strcat(datapath,'aip/RGB/');
    f=strcat(coordpath,'TileConfiguration.registered.txt');
    coord = read_Fiji_coord(f,'Composite');
    coord(2:3,:)=coord(2:3,:)./ds;

% use following 3 lines if stitch using OCT coordinates -- obsolete
%     f=strcat(datapath,'aip/vol',num2str(9),'/TileConfiguration.registered.txt');
%     coord = read_Fiji_coord(f,'aip');
else
% use following 3 lines if stitch using 2P coordinates
    coordpath = strcat(P2path,'aip/RGB/');
    f=strcat(coordpath,'TileConfiguration.registered.txt');
    coord = read_Fiji_coord(f,'Composite');
    coord(2:3,:)=coord(2:3,:).*2/3/ds;
end

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
    if strcmp(sys,'PSOCT')
        [rampy,rampx]=meshgrid(y, x);
    elseif strcmp(sys,'Thorlabs')
        [rampy,rampx]=meshgrid(x, y);
    end   
ramp=rampx.*rampy;      % blending mask

%% remove tiles with pure agarose
try
    load(strcat(datapath,'aip/vol',num2str(islice),'/tile_flag.mat'));
catch
    display(['tile_flag file not found for slice: ',num2str(islice)]);
    tile_flag=ones(1,numX*numY); %% when tile_flag doesn't work
end

filename0=dir('BFG.tif');
filename = strcat(filepath,'BFG_flagged.tif');
flagged=0;
for j=1:numX*numY
    if tile_flag(j)>0
        bfg = single(imread(filename0(1).name, j));
        
        if flagged==0
            t = Tiff(filename,'w');
            flagged=1;
        else
            t = Tiff(filename,'a');
        end
        tagstruct.ImageLength     = size(bfg,1);
        tagstruct.ImageWidth      = size(bfg,2);
        tagstruct.SampleFormat    = Tiff.SampleFormat.IEEEFP;
        tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
        tagstruct.BitsPerSample   = 32;
        tagstruct.SamplesPerPixel = 1;
        tagstruct.Compression     = Tiff.Compression.None;
        tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
        tagstruct.Software        = 'MATLAB';
        t.setTag(tagstruct);
        t.write(bfg);
        t.close();
    end   
end

%% BaSiC shading correction
macropath=strcat(datapath,'fitting/vol',num2str(islice),'/BaSiC.ijm');
cor_filename=strcat(datapath,'fitting/vol',num2str(islice),'/','BFG_cor.tif');
fid_Macro = fopen(macropath, 'w');
filename=strcat(datapath,'fitting/vol',num2str(islice),'/','BFG_flagged.tif');
fprintf(fid_Macro,'open("%s");\n',filename);
fprintf(fid_Macro,'run("BaSiC ","processing_stack=BFG_flagged.tif flat-field=None dark-field=None shading_estimation=[Estimate shading profiles] shading_model=[Estimate both flat-field and dark-field] setting_regularisationparametes=Automatic temporal_drift=Ignore correction_options=[Compute shading and correct images] lambda_flat=0.50 lambda_dark=0.50");\n');
fprintf(fid_Macro,'selectWindow("Corrected:BFG_flagged.tif");\n');
fprintf(fid_Macro,'saveAs("Tiff","%s");\n',cor_filename);
fprintf(fid_Macro,'close();\n');
fprintf(fid_Macro,'close();\n');
fprintf(fid_Macro,'close();\n');
fprintf(fid_Macro,'close();\n');
fprintf(fid_Macro,'run("Quit");\n');
fclose(fid_Macro);
try
   system(['xvfb-run -a ' '/projectnb/npbssmic/ns/Fiji/Fiji.app/ImageJ-linux64 --run ',macropath]);
catch
    system(['xvfb-run -a ' '/projectnb/npbssmic/ns/Fiji/Fiji.app/ImageJ-linux64 --run ',macropath]);
    display(['BaSiC shading correction failed in bfg slice number: ',num2str(islice)]);
end
    
%write uncorrected BFG.tif tiles
filename0=dir(strcat(datapath,'fitting/vol',num2str(islice),'/','BFG.tif'));
for iFile=1:numTile
    this_tile=iFile;
    bfg = double(imread(filename0(1).name, iFile));
    %%%%%%%%%%%%%%%%%%%
    % add on background correction
%         us=single(imread(strcat(datapath,'fitting_4x/vol',num2str(islice),'/',num2str(iFile),'_mus.tif')));
%         us=imresize(us,10/ds);
    if(strcmp(datapath,'/projectnb2/npbssmic/ns/Ann_Mckee_samples_20T/NC_8095/'))
        bfg=bfg+(1-bfg_bg)./(10+us).*0.005;
    end

%         bfg_bg=load('/projectnb/npbssmic/ns/distortion_correction/bfg_bg_NC6047_br.mat');%NC6047
%         bfg=bfg+bfg_bg.bg.*0.00006./(1+us./3); %NC6974,NC6839
%         bfg=bfg+bfg_bg.bg.*0.000015.*(1+us./3); %NC8653
%         bfg=bfg+bfg_bg.bg.*0.0001./(1+us./3); %NC6047
%         bfg_bg=load('/projectnb/npbssmic/ns/distortion_correction/bfg_bg_NC6047_ul.mat');%NC6047
%         bfg=bfg+bfg_bg.bg.*0.000017.*(1+us./3); %NC6047
%         bfg_bg=load('/projectnb/npbssmic/ns/distortion_correction/bfg_bg_AD10382.mat');
%         tmp=bfg_bg.bg;
%         tmp=imresize(tmp,10/ds);
%         bfg=bfg+tmp.*0.000075./(1+us./10); %AD10382
%         bfg_bg=load('/projectnb/npbssmic/ns/distortion_correction/bfg_bg_AD20832.mat');
%         bfg=bfg+bfg_bg.bg.*0.00004; %AD20832
%         bfg_bg=load('/projectnb/npbssmic/ns/distortion_correction/bfg_bg_AD21354.mat');
%         bfg=bfg+bfg_bg.bg.*0.0002./(1+us./5); %AD21354,AD21424
%         bfg_bg=load('/projectnb/npbssmic/ns/distortion_correction/bfg_bg_CTE6489.mat');
%         bfg=bfg+bfg_bg.bg.*0.00008./(1+us./5); %CTE6489,CTE7019,CTE6912
%         bfg=bfg+bfg_bg.bg.*0.00015./(1+us./5); %CTE7126
%         bfg_bg=load('/projectnb/npbssmic/ns/distortion_correction/bfg_bg_AD7597.mat');
%         bg=bfg_bg.bg; bg=imresize(bg,10/ds);
%         bfg=bfg+bg.*0.0003./(1+us./5); %CTE7126

    avgname=strcat(datapath,'fitting/vol',num2str(islice),'/',num2str(this_tile),'.mat');
    save(avgname,'bfg');  

    bfg=single(bfg);
    tiffname=strcat(datapath,'fitting/vol',num2str(islice),'/',num2str(this_tile),'_bfg.tif');
    SaveTiff(bfg,1,tiffname);
end

% write shading corrected tiles
try
    filename0=strcat(datapath,'fitting/vol',num2str(islice),'/','BFG_cor.tif');
    filename0=dir(filename0);
    for iFile=1:sum(tile_flag)
        for tm=1:numX*numY
            if sum(tile_flag(1:tm))==iFile
                this_tile=tm;
                break
            end
        end

        bfg = double(imread(filename0(1).name, iFile));
        avgname=strcat(datapath,'fitting/vol',num2str(islice),'/',num2str(this_tile),'.mat');
        save(avgname,'bfg');  

        bfg=single(bfg);
        tiffname=strcat(datapath,'fitting/vol',num2str(islice),'/',num2str(this_tile),'_bfg.tif');
        SaveTiff(bfg,1,tiffname);
   end
catch
   display(['writing shading corrected tiles for bfg failed on slice number: ',num2str(islice)]);
end
%% blending & mosaicing

Mosaic = zeros(round(max(Xcen)+Xsize) ,round(max(Ycen)+Ysize));
Masque = zeros(size(Mosaic));   

for i=1:length(index)
    in = index(i);
    % load file and linear blend
    filename0=dir(strcat(num2str(in),'.mat')); 
    if isfile(filename0.name)
        load(filename0.name);
        if tile_flag(in)==0
            bfg=zeros(size(bfg));
        end
        row = round(Xcen(in)-Xsize/2+1:Xcen(in)+Xsize/2);    
        column = round(Ycen(in)-Ysize/2+1:Ycen(in)+Ysize/2);
        Masque2 = zeros(size(Mosaic));
        Masque2(row,column)=ramp;
        Masque(row,column)=Masque(row,column)+Masque2(row,column);
        if strcmp(sys,'PSOCT')
            Mosaic(row,column)=Mosaic(row,column)+bfg.*Masque2(row,column); 
        end
    end
end

MosaicFinal=Mosaic./Masque;
MosaicFinal(isnan(MosaicFinal))=0;
if strcmp(sys,'Thorlabs')
    MosaicFinal=MosaicFinal';
end
MosaicFinal = single(MosaicFinal);  
save(strcat(datapath,'fitting/',result,num2str(islice),'_ds',num2str(ds),'x.mat'),'MosaicFinal');   
%     nii=make_nii(MosaicFinal,[],[],64);
%     cd('C:\Users\jryang\Downloads\');
%     save_nii(nii,'aip_day3.nii');
tiffname=strcat(datapath,'fitting/',result,num2str(islice),'_ds',num2str(ds),'x.tif');
SaveTiff(MosaicFinal,1,tiffname);