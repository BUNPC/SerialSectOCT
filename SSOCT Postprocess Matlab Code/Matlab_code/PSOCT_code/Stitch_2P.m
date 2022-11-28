function Stitch_2P(datapath,disp,mosaic,pxlsize,islice,pattern)
%%% ---------------------- %%%
% function version of mosaicing & blending
% input: displacement parameters: four elements array [xx xy yy yx]
%        mosaic parameters: four elemetns array [number of x tile, number of y tile,
%                                                 overlap in x, overlap in y]
%        pixel size parameters: two elements array [x pixel size, y pixel size]
%        slice index: index of slice you wish to perform stitching & blending
%
% Author: Jiarui Yang, Shuaibin Chang
% 10/28/19
%% define parameters
    Xoverlap=mosaic(3);
    Yoverlap=mosaic(4);
    
    Xsize=pxlsize(1);                                                                              %changed by stephan
    Ysize=pxlsize(2);
    

    %% generate distorted grid pattern& write coordinates to file
    filepath=strcat(datapath,'aip/vol',num2str(islice),'/');
    cd(filepath);
    fileID = fopen([filepath 'TileConfiguration.txt'],'w');
    fprintf(fileID,'# Define the number of dimensions we are working on\n');
    fprintf(fileID,'dim = 2\n\n');
    fprintf(fileID,'# Define the image coordinates\n');
    %% get FIJI stitching info
    filename = strcat(datapath,'aip/RGB/');
    f=strcat(filename,'TileConfiguration.registered.txt');
    coord = read_Fiji_coord(f,'Composite');
    
    for j=1:size(coord,2)
            fprintf(fileID,[num2str(coord(1,j)),'-channel1','.tif; ; (%d, %d)\n'],round(coord(2:3,j)));
    end
    fclose(fileID);

    macropath=[filepath,'Macro.ijm'];
    filepath_rev=strcat(datapath,'aip/vol',num2str(islice));
    fid_Macro = fopen(macropath, 'w');
    l=['run("Grid/Collection stitching", "type=[Positions from file] order=[Defined by TileConfiguration] directory=',filepath_rev,' layout_file=TileConfiguration.txt fusion_method=[Linear Blending] regression_threshold=0.02 max/avg_displacement_threshold=1 absolute_displacement_threshold=1 compute_overlap computation_parameters=[Save memory (but be slower)] image_output=[Write to disk] output_directory=',filepath_rev,'");\n'];
    fprintf(fid_Macro,l);

    fclose(fid_Macro);

    %% execute Macro file
    tic
    system(['/projectnb/npbssmic/ns/Fiji/Fiji.app/ImageJ-linux64 --headless -macro ',macropath]);
    toc
    %% get FIJI stitching info
    filename = strcat(datapath,'aip/vol',num2str(islice),'/');
    f=strcat(filename,'TileConfiguration.registered.txt');
    coord = read_Fiji_coord(f,'channel1');

    % define coordinates for each tile
    Xcen=zeros(size(coord,2),1);
    Ycen=zeros(size(coord,2),1);
    index=coord(1,:);

    for ii=1:size(coord,2)
        Xcen(coord(1,ii))=round(coord(3,ii));
        Ycen(coord(1,ii))=round(coord(2,ii));
    end
   
    Xcen=Xcen-min(Xcen);
    Ycen=Ycen-min(Ycen);

    Xcen=Xcen+round(Xsize/2);
    Ycen=Ycen+round(Ysize/2);

    stepx = Xoverlap*Xsize;
    x = [0:stepx-1 repmat(stepx,1,round((1-2*Xoverlap)*Xsize)) round(stepx-1):-1:0]./stepx;
    stepy = Yoverlap*Ysize;
    y = [0:stepy-1 repmat(stepy,1,round((1-2*Yoverlap)*Ysize)) round(stepy-1):-1:0]./stepy;

    [rampy,rampx]=meshgrid(y, x); 
    ramp=rampy.*rampx;      % blending mask

    % blending & mosaicing
  
    Mosaic = zeros(max(Xcen)+Xsize ,max(Ycen)+Ysize);
    Masque = zeros(size(Mosaic));

    cd(filepath);    

    for i=1:length(index)
        in = index(i);
        % load file and linear blend
        filename0=dir(strcat(num2str(in),'-channel1.mat'));
        load(filename0.name);

        row = round(Xcen(in)-Xsize/2+1:Xcen(in)+Xsize/2);                                                 %changed by stephan
        column = round(Ycen(in)-Ysize/2+1:Ycen(in)+Ysize/2);
        
        Masque2 = zeros(size(Mosaic));
        Masque2(row,column)=ramp;
        Masque(row,column)=Masque(row,column)+Masque2(row,column);
        Mosaic(row,column)=Mosaic(row,column)+channel1.*Masque2(row,column);

    end

    % process the blended image
    MosaicFinal=Mosaic./Masque;
    MosaicFinal=MosaicFinal-min(min(MosaicFinal));
    MosaicFinal(isnan(MosaicFinal))=0;

    %% save as nifti or tiff    
%          nii=make_nii(MosaicFinal,[],[],64);
%          cd('C:\Users\jryang\Downloads\');
%          save_nii(nii,'aip_vol7.nii');
%     MosaicFinal = uint16(65535*(mat2gray(MosaicFinal)));    
    tiffname=strcat(datapath,'aip/channel1-',num2str(islice),'.tif');
    t = Tiff(tiffname,'w');
    image=single(MosaicFinal);
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
    
    % high-pass filtering
%     tmp=convn(image, ones(400,400)./160000,'same');
%     image=single(image./tmp);
%     tiffname=strcat(datapath,'aip/channel1-norm-',num2str(islice),'.tif');
%     t = Tiff(tiffname,'w');
%     tagstruct.ImageLength     = size(image,1);
%     tagstruct.ImageWidth      = size(image,2);
%     tagstruct.SampleFormat    = Tiff.SampleFormat.IEEEFP;
%     tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
%     tagstruct.BitsPerSample   = 32;
%     tagstruct.SamplesPerPixel = 1;
%     tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
%     tagstruct.Compression = Tiff.Compression.None;
%     tagstruct.Software        = 'MATLAB';
%     t.setTag(tagstruct);
%     t.write(image);
%     t.close();

        %% save as nifti or tiff    
%          nii=make_nii(MosaicFinal,[],[],64);
%          cd('C:\Users\jryang\Downloads\');
%          save_nii(nii,'aip_vol7.nii');
%     MosaicFinal = uint16(65535*(mat2gray(MosaicFinal)));    
%     tiffname=strcat('channel1-',num2str(islice),'-shaded.tif');
%     t = Tiff(tiffname,'w');
%     image=single(shaded);
%     tagstruct.ImageLength     = size(image,1);
%     tagstruct.ImageWidth      = size(image,2);
%     tagstruct.SampleFormat    = Tiff.SampleFormat.IEEEFP;
%     tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
%     tagstruct.BitsPerSample   = 32;
%     tagstruct.SamplesPerPixel = 1;
%     tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
%     tagstruct.Compression = Tiff.Compression.None;
%     tagstruct.Software        = 'MATLAB';
%     t.setTag(tagstruct);
%     t.write(image);
%     t.close();

%% stitch channel2
Mosaic = zeros(max(Xcen)+Xsize ,max(Ycen)+Ysize);
Masque = zeros(size(Mosaic)); 

for i=1:length(index)
    in = index(i);
    % load file and linear blend
    filename0=dir(strcat(num2str(in),'-channel2.mat'));
    load(filename0.name);

    row = round(Xcen(in)-Xsize/2+1:Xcen(in)+Xsize/2);                                                 %changed by stephan
    column = round(Ycen(in)-Ysize/2+1:Ycen(in)+Ysize/2);

    Masque2 = zeros(size(Mosaic));
    Masque2(row,column)=ramp;
    Masque(row,column)=Masque(row,column)+Masque2(row,column);
    Mosaic(row,column)=Mosaic(row,column)+channel2.*Masque2(row,column);
end
% process the blended image

MosaicFinal=Mosaic./Masque;
MosaicFinal=MosaicFinal-min(min(MosaicFinal));
MosaicFinal(isnan(MosaicFinal))=0;
%% save as nifti or tiff    
%          nii=make_nii(MosaicFinal,[],[],64);
%          cd('C:\Users\jryang\Downloads\');
%          save_nii(nii,'aip_vol7.nii');
%     MosaicFinal = uint16(65535*(mat2gray(MosaicFinal)));    
tiffname=strcat(datapath,'aip/channel2-',num2str(islice),'.tif');
t = Tiff(tiffname,'w');
image=single(MosaicFinal);
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
    % high-pass filtering
% tmp=convn(image, ones(400,400)./160000,'same');
% image=single(image./tmp);
% tiffname=strcat(datapath,'aip/channel2-norm-',num2str(islice),'.tif');
% t = Tiff(tiffname,'w');
% tagstruct.ImageLength     = size(image,1);
% tagstruct.ImageWidth      = size(image,2);
% tagstruct.SampleFormat    = Tiff.SampleFormat.IEEEFP;
% tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
% tagstruct.BitsPerSample   = 32;
% tagstruct.SamplesPerPixel = 1;
% tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
% tagstruct.Compression = Tiff.Compression.None;
% tagstruct.Software        = 'MATLAB';
% t.setTag(tagstruct);
% t.write(image);
% t.close();
