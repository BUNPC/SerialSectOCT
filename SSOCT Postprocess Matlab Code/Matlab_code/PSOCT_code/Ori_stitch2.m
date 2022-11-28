function Ori_stitch2(target, P2path, datapath,disp,mosaic,pxlsize,islice,pattern,sys)
%% stitch the retardance using the coordinates from AIP stitch
% add subfunctions for the script
addpath('/projectnb/npbssmic/s/Matlab_code');
id=islice;
filepath=strcat(datapath,'orientation/vol',num2str(islice),'/');
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
% use following 3 lines if stitch using OCT coordinates
% f=strcat(datapath,'aip/vol',num2str(1),'/TileConfiguration.txt');
% coord = read_Fiji_coord(f,'aip');
% coord(2:3,:)=coord(2:3,:);

% use following 3 lines if stitch using 2P coordinates
f=strcat(P2path,'aip/RGB/TileConfiguration.registered.txt');
coord = read_Fiji_coord(f,'Composite');
coord(2:3,:)=coord(2:3,:).*2/3;
% coord(2,:)=coord(2,:).*1.62/3;
% coord(3,:)=coord(3,:).*1.82/3;
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

%% calculate ramp for individual tile, based on stitching coord
stepx = Xoverlap*Xsize;
x = [stepx.*ones(1,stepx) repmat(stepx,1,round((1-2*Xoverlap)*Xsize)) zeros(1,stepx)]./stepx;
stepy = Yoverlap*Ysize;
y = [stepy.*ones(1,stepy) repmat(stepy,1,round((1-2*Yoverlap)*Ysize)) zeros(1,stepy)]./stepy;
if strcmp(sys,'PSOCT')
    [rampy,rampx]=meshgrid(y, x);
elseif strcmp(sys,'Thorlabs')
    [rampy,rampx]=meshgrid(x, y);
end 


%% flagg retardance tiles
load(strcat(datapath,'aip/vol',num2str(id),'/tile_flag.mat'));
filename0=dir('ORI.tif');
filename = strcat(filepath,'ORI_flagged.tif');
flagged=0;
for j=1:numX*numY
    if tile_flag(j)>0
        ori2D = single(imread(filename0(1).name, j));
        
        if flagged==0
            t = Tiff(filename,'w');
            flagged=1;
        else
            t = Tiff(filename,'a');
        end
        tagstruct.ImageLength     = size(ori2D,1);
        tagstruct.ImageWidth      = size(ori2D,2);
        tagstruct.SampleFormat    = Tiff.SampleFormat.IEEEFP;
        tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
        tagstruct.BitsPerSample   = 32;
        tagstruct.SamplesPerPixel = 1;
        tagstruct.Compression     = Tiff.Compression.None;
        tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
        tagstruct.Software        = 'MATLAB';
        t.setTag(tagstruct);
        t.write(ori2D);
        t.close();

    end   
end
%% BaSiC shading correction
    macropath=strcat(datapath,'orientation/vol',num2str(islice),'/BaSiC.ijm');
    cor_filename=strcat(datapath,'orientation/vol',num2str(islice),'/','ORI_cor.tif');
    fid_Macro = fopen(macropath, 'w');
    filename=strcat(datapath,'orientation/vol',num2str(islice),'/','ORI_flagged.tif');
    fprintf(fid_Macro,'open("%s");\n',filename);
    fprintf(fid_Macro,'run("BaSiC ","processing_stack=ORI_flagged.tif flat-field=None dark-field=None shading_estimation=[Estimate shading profiles] shading_model=[Estimate both flat-field and dark-field] setting_regularisationparametes=Automatic temporal_drift=Ignore correction_options=[Compute shading and correct images] lambda_flat=0.50 lambda_dark=0.50");\n');
    fprintf(fid_Macro,'selectWindow("Corrected:ORI_flagged.tif");\n');
    fprintf(fid_Macro,'saveAs("Tiff","%s");\n',cor_filename);
    fprintf(fid_Macro,'close();\n');
    fprintf(fid_Macro,'close();\n');
    fprintf(fid_Macro,'close();\n');
    fprintf(fid_Macro,'close();\n');
    fprintf(fid_Macro,'run("Quit");\n');
    fclose(fid_Macro);
    try
%         system(['xvfb-run -a ' '/projectnb/npbssmic/ns/Fiji/Fiji.app/ImageJ-linux64 --run ',macropath]);
    %     system(['/projectnb/npbssmic/ns/Fiji/Fiji.app/ImageJ-linux64 -macro ',macropath]);
    catch
        display("BaSiC shading correction failed")
    end
    % write uncorrected RET.tif tiles
    filename0=strcat(datapath,'orientation/vol',num2str(islice),'/','ORI.tif');
    filename0=dir(filename0);
    for iFile=1:length(tile_flag)
        this_tile=iFile;
        ori2D = double(imread(filename0(1).name, iFile));
        avgname=strcat(datapath,'orientation/vol',num2str(islice),'/',num2str(this_tile),'.mat');
        save(avgname,'ori2D');  

        ori2D=single(ori2D);
        tiffname=strcat(datapath,'orientation/vol',num2str(islice),'/',num2str(this_tile),'_ori.tif');
        t = Tiff(tiffname,'w');
        tagstruct.ImageLength     = size(ori2D,1);
        tagstruct.ImageWidth      = size(ori2D,2);
        tagstruct.SampleFormat    = Tiff.SampleFormat.IEEEFP;
        tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
        tagstruct.BitsPerSample   = 32;
        tagstruct.SamplesPerPixel = 1;
        tagstruct.Compression     = Tiff.Compression.None;
        tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
        tagstruct.Software        = 'MATLAB';
        t.setTag(tagstruct);
        t.write(ori2D);
        t.close();
    end
    
%     try
%         %write corrected RET_cor.tif
%         filename0=strcat(datapath,'orientation/vol',num2str(islice),'/','ORI_cor.tif');
%         filename0=dir(filename0);
%         for iFile=1:sum(tile_flag)
%             for tm=1:numX*numY
%                 if sum(tile_flag(1:tm))==iFile
%                     this_tile=tm;
%                     break
%                 end
%             end
%             ori2D = double(imread(filename0(1).name, iFile));
%             avgname=strcat(datapath,'orientation/vol',num2str(islice),'/',num2str(this_tile),'.mat');
%             save(avgname,'ori2D');  
% 
%             ori2D=single(ori2D);
%             tiffname=strcat(datapath,'orientation/vol',num2str(islice),'/',num2str(this_tile),'_ori.tif');
%             t = Tiff(tiffname,'w');
%             tagstruct.ImageLength     = size(ori2D,1);
%             tagstruct.ImageWidth      = size(ori2D,2);
%             tagstruct.SampleFormat    = Tiff.SampleFormat.IEEEFP;
%             tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
%             tagstruct.BitsPerSample   = 32;
%             tagstruct.SamplesPerPixel = 1;
%             tagstruct.Compression     = Tiff.Compression.None;
%             tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
%             tagstruct.Software        = 'MATLAB';
%             t.setTag(tagstruct);
%             t.write(ori2D);
%             t.close();
%         end
%     catch
%     end
%% blending & mosaicing
Mosaic = zeros(round(max(Xcen)+Xsize) ,round(max(Ycen)+Ysize));
Masque = single(zeros(size(Mosaic)));

for i=1:length(index)
        in = index(i);
        filename0=dir(strcat(num2str(in),'.mat'));
%         ori2D=ones(size(ori2D));
        load(filename0.name);
        if tile_flag(in)==0
            ori2D=zeros(size(ori2D));
        end
        
        ramp=rampx.*rampy;      % blending mask
        %%
        row = round(Xcen(in)-Xsize/2+1:Xcen(in)+Xsize/2);                              
        column = round(Ycen(in)-Ysize/2+1:Ycen(in)+Ysize/2);

        Masque(row,column)=Masque(row,column)+ramp;
        if strcmp(sys,'PSOCT')
            Mosaic(row,column)=Mosaic(row,column)+ori2D.*ramp;
        elseif strcmp(sys,'Thorlabs')
            Mosaic(row,column)=Mosaic(row,column)+ori2D'.*ramp;
        end
end

% Mosaic=Cycle_ori(Mosaic,Masque);
% Masque=squeeze(sum(Masque,1));
Mosaic=Mosaic./Masque;
Mosaic(Mosaic<0)=Mosaic(Mosaic<0)+180;
Mosaic(Mosaic>180)=180;


Mosaic(isnan(Mosaic))=0;
if strcmp(sys,'Thorlabs')
    Mosaic=Mosaic';
end
% save(strcat(target,'.mat'),'MosaicFinal');
  
Mosaic = single(Mosaic);   
%     nii=make_nii(MosaicFinal,[],[],64);
%     cd('C:\Users\jryang\Downloads\');
%     save_nii(nii,'aip_day3.nii');
% cd(filepath);
tiffname=strcat(datapath,'orientation/',target,num2str(id),'.tif');
t = Tiff(tiffname,'w');
image=Mosaic;
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