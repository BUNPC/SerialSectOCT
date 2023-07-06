function AIP_stitch(P2path, datapath,disp,mosaic,pxlsize,islice,pattern,sys,stitch, aip_threshold, aip_threshold_post_BaSiC, highres)
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
%% define parameters for stitching slices individually -- we don't use individual stitching anymore, but still keep it just in case in the future we want to do it
   % we don't use the 
   %displacement parameters
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
    grid=zeros(2,numTile);

    if strcmp(pattern,'unidirectional')
        for i=starti:numTile
            if mod(i,numX)==0
                grid(1,i)=(numY-ceil(i/numX))*xx;
                grid(2,i)=(numY-ceil(i/numX))*xy;
            else
                grid(1,i)=(numY-ceil(i/numX))*xx+(numX-(mod(i,numX)+1))*yx;
                grid(2,i)=(numY-ceil(i/numX))*xy+(numX-(mod(i,numX)))*yy;
            end
        end
    elseif strcmp(pattern,'bidirectional')
%         for i=1:numTile
%             % odd lines
%             if mod(ceil(i/numX),2)==1
%                 if mod(i,numX)==0
%                     grid(1,i)=(numY-ceil(i/numX))*xx-yx;
%                     grid(2,i)=(numY-ceil(i/numX))*xy;
%                 else
%                     grid(1,i)=(numY-ceil(i/numX))*xx+(numX-(mod(i,numX)+1))*yx;
%                     grid(2,i)=(numY-ceil(i/numX))*xy+((numX-mod(i,numX)))*yy;
%                 end
%             else    % even lines 
%                 if mod(i,numX)==0
%                     grid(1,i)=(numY-ceil(i/numX))*xx+(numX-1)*yx;
%                     grid(2,i)=(numY-ceil(i/numX))*xy+(numX-1)*yy;
%                 else
%                     grid(1,i)=(numY-ceil(i/numX))*xx+((mod(i,numX)-1))*yx;
%                     grid(2,i)=(numY-ceil(i/numX))*xy+((mod(i,numX)-1))*yy;
%                 end
%             end

%%          2002/02/10 modified mosaicing pattern

         for i=1:numTile
            % odd lines
            if mod(ceil(i/numX),2)==1
                if mod(i,numX)==0
%                     grid(1,i)=(numX-1)*xx+floor(i/numX)*yx;
                    grid(1,i)=(numX-1)*xx+(floor(i/numX)-1)*yx; % for Hui's second data only
                    grid(2,i)=-(numX-1)*xy-(floor(i/numX)-1)*yy;
                else
                    grid(1,i)=(mod(i,numX)-1)*xx+floor(i/numX)*yx;
                    grid(2,i)=-(mod(i,numX)-1)*xy-floor(i/numX)*yy;
                end
            else    % even lines 
                if mod(i,numX)==0
%                     grid(1,i)=floor(i/numX)*yx;
                    grid(1,i)=(floor(i/numX)-1)*yx;  %for Hui's second data only
                    grid(2,i)=-(floor(i/numX)-1)*yy;
                else
                    grid(1,i)=(numX-mod(i,numX))*xx+floor(i/numX)*yx;
                    grid(2,i)=-(numX-mod(i,numX))*xy-floor(i/numX)*yy;
                end
            end
            
        end
    end
    grid(2,:)=grid(2,:)-min(grid(2,:));
    
    %% Select sample tiles, exclude agarose tiles
    filepath=strcat(datapath,'aip/vol',num2str(islice),'/');
    cd(filepath);
    fileID = fopen([filepath 'TileConfiguration.txt'],'w');
    fprintf(fileID,'# Define the number of dimensions we are working on\n');
    fprintf(fileID,'dim = 2\n\n');
    fprintf(fileID,'# Define the image coordinates\n');
    tile_flag=zeros(1,numTile);
    filename0=dir('AIP.tif');
    coordpath = strcat(filepath,'AIP_flagged.tif');
    flagged=0;
    for j=1:numTile
        aip = single(imread(filename0(1).name, j));
        aip(isnan(aip))=0;
        % threshold tunable for agarose blocks, you should do visual examination of aip.tif after finishing
        if mean2(aip)>aip_threshold || std2(aip)>aip_threshold/4     
            tile_flag(j)=1;
            fprintf(fileID,[num2str(j) '_aip.tif; ; (%d, %d)\n'],round(grid(:,j)));
            if flagged==0
                t = Tiff(coordpath,'w');
                flagged=1;
            else
                t = Tiff(coordpath,'a');
            end
            tagstruct.ImageLength     = size(aip,1);
            tagstruct.ImageWidth      = size(aip,2);
            tagstruct.SampleFormat    = Tiff.SampleFormat.IEEEFP;
            tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
            tagstruct.BitsPerSample   = 32;
            tagstruct.SamplesPerPixel = 1;
            tagstruct.Compression     = Tiff.Compression.None;
            tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
            tagstruct.Software        = 'MATLAB';
            t.setTag(tagstruct);
            t.write(aip);
            t.close();

        end   
    end
    fclose(fileID);
    save('tile_flag.mat','tile_flag');

%% BaSiC shading correction
    macropath=strcat(datapath,'aip/vol',num2str(islice),'/BaSiC.ijm');
    cor_filename=strcat(datapath,'aip/vol',num2str(islice),'/','AIP_cor.tif');
    fid_Macro = fopen(macropath, 'w');
    coordpath=strcat(datapath,'aip/vol',num2str(islice),'/','AIP_flagged.tif');
    fprintf(fid_Macro,'open("%s");\n',coordpath);
    fprintf(fid_Macro,'run("BaSiC ","processing_stack=AIP_flagged.tif flat-field=None dark-field=None shading_estimation=[Estimate shading profiles] shading_model=[Estimate both flat-field and dark-field] setting_regularisationparametes=Automatic temporal_drift=Ignore correction_options=[Compute shading and correct images] lambda_flat=0.50 lambda_dark=0.50");\n');
    fprintf(fid_Macro,'selectWindow("Corrected:AIP_flagged.tif");\n');
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
        display("BaSiC shading correction failed")
    end
    % write uncorrected AIP.tif tiles
    filename0=strcat(datapath,'aip/vol',num2str(islice),'/','AIP.tif');
    filename0=dir(filename0);
    for iFile=1:length(tile_flag)
        this_tile=iFile;
        aip = double(imread(filename0(1).name, iFile));
        avgname=strcat(datapath,'aip/vol',num2str(islice),'/',num2str(this_tile),'.mat');
        save(avgname,'aip');  

        aip=single(aip);
        tiffname=strcat(datapath,'aip/vol',num2str(islice),'/',num2str(this_tile),'_aip.tif');
        SaveTiff(aip,1,tiffname);
    end
    
    try
        % wirte shading corrected AIP_cor.tif tiles, the shading corrected
        % tissue tiles will repace uncorrected tissue tiles, but agarose
        % tiles will stay uncorrected
        filename0=strcat(datapath,'aip/vol',num2str(islice),'/','AIP_cor.tif');
        filename0=dir(filename0);
        for iFile=1:sum(tile_flag)
            for tm=1:numTile
                if sum(tile_flag(1:tm))==iFile
                    this_tile=tm;
                    break
                end
            end
            aip = double(imread(filename0(1).name, iFile));
            avgname=strcat(datapath,'aip/vol',num2str(islice),'/',num2str(this_tile),'.mat');
            save(avgname,'aip');  

            aip=single(aip);
            tiffname=strcat(datapath,'aip/vol',num2str(islice),'/',num2str(this_tile),'_aip.tif');
            SaveTiff(aip,1,tiffname);
        end
    catch
    end
    %% generate Macro file for stitching
    macropath=[filepath,'Macro.ijm'];
    filepath_rev=strcat(datapath,'aip/');
    fid_Macro = fopen(macropath, 'w');
    l=['run("Grid/Collection stitching", "type=[Positions from file] order=[Defined by TileConfiguration] directory=',filepath_rev,'vol',num2str(islice),' layout_file=TileConfiguration.txt fusion_method=[Linear Blending] regression_threshold=0.02 max/avg_displacement_threshold=1000 absolute_displacement_threshold=1000 compute_overlap computation_parameters=[Save memory (but be slower)] image_output=[Write to disk] output_directory=',filepath_rev,'vol',num2str(islice),'");\n'];
    fprintf(fid_Macro,l);
    fprintf(fid_Macro,'run("Quit");\n');
    fclose(fid_Macro);

    %% execute Macro file, comment out this section if using universal stitching coordinates from RGB stitching
%     tic
% % % %     system(['/projectnb/npbssmic/ns/Fiji/Fiji.app/ImageJ-linux64 --headless -macro ',macropath]);
%     toc

    %% get FIJI stitching coordinates
    % use following 3 lines if stitching using OCT coordinates
    if stitch==1
        coordpath = strcat(datapath,'aip/RGB/');
        f=strcat(coordpath,'TileConfiguration.registered.txt');
        if isfile(f)
            coord = read_Fiji_coord(f,'Composite');
        else
            pause(600)
        end
    
    % use following 3 lines if stitching using individual slice OCT
    % coordinates -- we don't use this anymore since stacking will be
    % difficult if we stitch each slice individually
    
%     f=strcat(datapath,'aip/vol',num2str(islice),'/TileConfiguration.registered.txt');
%     coord = read_Fiji_coord(f,'aip');
    else
    % use following 3 lines if stitch using 2P coordinates
        coordpath = strcat(P2path,'aip/RGB/');
        f=strcat(coordpath,'TileConfiguration.registered.txt');
        coord = read_Fiji_coord(f,'Composite');
        if highres==1
            coord(2:3,:)=coord(2:3,:).*1.03/3;
        else
            coord(2:3,:)=coord(2:3,:).*2/3;
        end
    end

    % define coordinates for each tile
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

    Xcen=Xcen+round(Xsize/2);
    Ycen=Ycen+round(Ysize/2);

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
    ramp=rampy.*rampx;    
    
    % blending mask
    Mosaic = zeros(max(Xcen)+Xsize ,max(Ycen)+Ysize);
    Masque = zeros(size(Mosaic));

    cd(filepath);    

    for i=1:length(index)
        in = index(i);
        % load file and linear blend
        filename0=dir(strcat(num2str(in),'.mat'));
        load(filename0.name);

        % remove agarose tiles
        if tile_flag(in)==0
            aip=zeros(size(aip));
        end
        row = round(Xcen(in)-Xsize/2+1:Xcen(in)+Xsize/2);                                                 %changed by stephan
        column = round(Ycen(in)-Ysize/2+1:Ycen(in)+Ysize/2);
        
        Masque(row,column)=Masque(row,column)+ramp;
        % blending
        if strcmp(sys,'PSOCT')
            Mosaic(row,column)=Mosaic(row,column)+aip.*ramp;
        elseif strcmp(sys,'Thorlabs')
            Mosaic(row,column)=Mosaic(row,column)+aip'.*ramp;
        end
    end
    % flatten the blending mask
    AIP=Mosaic./Masque;
%     AIP=AIP-min(min(AIP));
% remove NAN values
    AIP(isnan(AIP))=0;
    if strcmp(sys,'Thorlabs')
        AIP=AIP';
    end
    % remove agarose using aip_threshold
    mask=zeros(size(AIP));
    mask(AIP>aip_threshold_post_BaSiC)=1;
    AIP=single(AIP.*mask);
    
    save(strcat(datapath,'aip/aip',num2str(islice),'.mat'),'AIP','-v7.3');
    %% save as nifti or tiff    
%          nii=make_nii(MosaicFinal,[],[],64);
%          cd('C:\Users\jryang\Downloads\');
%          save_nii(nii,'aip_vol7.nii');  
    tiffname=strcat(datapath,'aip/','aip',num2str(islice),'.tif');
    SaveTiff(AIP,1,tiffname);
end