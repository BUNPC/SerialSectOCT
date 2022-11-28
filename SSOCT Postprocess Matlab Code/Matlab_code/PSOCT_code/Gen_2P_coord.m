function Gen_2P_coord(datapath,disp,mosaic,pxlsize,islice,pattern, plane1, plane2, plane3)
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
   %displacement parameters
    xx=disp(1);
    xy=disp(2);
    yy=disp(3);
    yx=disp(4);
    % mosaic parameters
    numX=mosaic(1);
    numY=mosaic(2);
    numTile=numX*numY;
    grid=zeros(2,numTile);

    if strcmp(pattern,'unidirectional')
        for i=1:numTile
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
    %% generate distorted grid pattern& write coordinates to file
    mkdir(strcat(datapath,'aip/RGB/'));
    filepath=strcat(datapath,'aip/RGB/');
    cd(filepath);
    fileID = fopen([filepath 'TileConfiguration.txt'],'w');
    fprintf(fileID,'# Define the number of dimensions we are working on\n');
    fprintf(fileID,'dim = 2\n\n');
    fprintf(fileID,'# Define the image coordinates\n');

    for j=1:numTile
%         filename0=dir(strcat(num2str(j),'-channel1.mat'));
%         load(filename0.name);
%         if mean(channel1(:))>0
            fprintf(fileID,['Composite-',num2str(j,'%04.f'),'.tif; ; (%d, %d)\n'],round(grid(:,j)));
%         end
    end
    fclose(fileID);

    %% generate Macro file
    macropath=strcat(datapath,'aip/RGB/Macro.ijm');
    filepath_rev=strcat(datapath,'aip/RGB/');
    fid_Macro = fopen(macropath, 'w');
    
    path1=strcat(datapath,'aip/vol',num2str(plane1),'/Channel1_cor.tif');
    fprintf(fid_Macro,'open("%s");\n',path1);
    fprintf(fid_Macro,'setMinAndMax("0.00","35000");\n');
    path2=strcat(datapath,'aip/vol',num2str(plane2),'/Channel1_cor.tif');
    fprintf(fid_Macro,'open("%s");\n',path2);
    fprintf(fid_Macro,'setMinAndMax("0.00","35000");\n');
    path3=strcat(datapath,'aip/vol',num2str(plane3),'/Channel1_cor.tif');
    fprintf(fid_Macro,'open("%s");\n',path3);
    fprintf(fid_Macro,'setMinAndMax("0.00","35000");\n');
    fprintf(fid_Macro,'run("Merge Channels...", "c1=Channel1_cor.tif c2=Channel1_cor-1.tif c3=Channel1_cor-2.tif create");\n');
%     fprintf(fid_Macro,'run("Multiply...", "value=100000");\n');
    fprintf(fid_Macro,'run("RGB Color","slices keep");\n');
    fprintf(fid_Macro,'selectWindow("Composite");\n');
    fprintf(fid_Macro,'close();\n');
    composite_path=strcat(datapath,'aip/RGB');
    fprintf(fid_Macro,'run("Image Sequence... ", "format=TIFF name=Composite- start=1 save=%s");\n',composite_path);
    fprintf(fid_Macro,'close();\n');
    l=['run("Grid/Collection stitching", "type=[Positions from file] order=[Defined by TileConfiguration] directory=',filepath_rev,' layout_file=TileConfiguration.txt fusion_method=[Linear Blending] regression_threshold=0.01 max/avg_displacement_threshold=1 absolute_displacement_threshold=1 compute_overlap computation_parameters=[Save memory (but be slower)] image_output=[Write to disk] output_directory=',filepath_rev,'");\n'];
    fprintf(fid_Macro,l);
    fprintf(fid_Macro,'run("Quit");\n');
    fclose(fid_Macro);
    system(['xvfb-run -a ' '/projectnb/npbssmic/ns/Fiji/Fiji.app/ImageJ-linux64 --run ',macropath]);
    