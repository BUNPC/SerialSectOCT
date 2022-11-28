function co_stitch(target, datapath,disp,mosaic,pxlsize,islice,pattern,sys)
%% stitch the fitting result using the coordinates from AIP stitch
%% define grid pattern

% add subfunctions for the script
addpath('/projectnb/npbssmic/s/Matlab_code');
% displacement parameters
% xx=92;
% xy=-4;
% yy=97;
% yx=-4;
result=target;
id=islice;
% mosaic parameters
% numX=5;
% numY=4;
Xoverlap=mosaic(3);
    Yoverlap=mosaic(4);
    
    Xsize=pxlsize(1);                                                                              %changed by stephan
    Ysize=pxlsize(2);
% 
% % tile parameters

% 
% numTile=numX*numY;
% grid=zeros(2,numTile);
% pattern='bidirectional';
% if strcmp(pattern,'unidirectional')
%     for i=1:numTile
%         if mod(i,numX)==0
%             grid(1,i)=(numY-ceil(i/numX))*xx;
%             grid(2,i)=(numY-ceil(i/numX))*xy;
%         else
%             grid(1,i)=(numY-ceil(i/numX))*xx+(numX-(mod(i,numX)+1))*yx;
%             grid(2,i)=(numY-ceil(i/numX))*xy+(numX-(mod(i,numX)))*yy;
%         end
%     end
% elseif strcmp(pattern,'bidirectional')
%          for i=1:numTile
%             % odd lines
%             if mod(ceil(i/numX),2)==1
%                 if mod(i,numX)==0
%                     grid(1,i)=(numX-1)*xx+floor(i/numX)*yx;
%                     grid(2,i)=-(numX-1)*xy-(floor(i/numX)-1)*yy;
%                 else
%                     grid(1,i)=(mod(i,numX)-1)*xx+floor(i/numX)*yx;
%                     grid(2,i)=-(mod(i,numX)-1)*xy-floor(i/numX)*yy;
%                 end
%             else    % even lines 
%                 if mod(i,numX)==0
%                     grid(1,i)=floor(i/numX)*yx;
%                     grid(2,i)=-(floor(i/numX)-1)*yy;
%                 else
%                     grid(1,i)=(numX-mod(i,numX))*xx+floor(i/numX)*yx;
%                     grid(2,i)=-(numX-mod(i,numX))*xy-floor(i/numX)*yy;
%                 end
%             end
%             
%         end
% end
%     grid(2,:)=grid(2,:)-min(grid(2,:));
% redefine the origin of the grid, choose a non-agarose tile
% grid(1,:)=grid(1,:)-grid(1,68);
% grid(2,:)=grid(2,:)-grid(2,68);
%% generate distorted grid pattern

%% write coordinates to file

filepath=strcat(datapath,'fitting/vol',num2str(islice),'/');
% filepath=strcat(datapath,'I41SupFrontal_20170424/');
cd(filepath);
% fileID = fopen([filepath 'TileConfiguration.txt'],'w');
% fprintf(fileID,'# Define the number of dimensions we are working on\n');
% fprintf(fileID,'dim = 2\n\n');
% fprintf(fileID,'# Define the image coordinates\n');
% for j=1:numTile
%     fprintf(fileID,[num2str(j) '_ub.tif; ; (%d, %d)\n'],round(grid(:,j))); 
% end
% fclose(fileID);
% 
% %% generate Macro file
% 
% pathname=filepath;
% macropath=[pathname,'Macro.ijm'];
% 
% pathname_rev=pathname;
% 
% fid_Macro = fopen(macropath, 'w');
% l=['run("Grid/Collection stitching", "type=[Positions from file] order=[Defined by TileConfiguration] directory=',pathname_rev,' layout_file=TileConfiguration.txt fusion_method=[Linear Blending] regression_threshold=0.02 max/avg_displacement_threshold=1 absolute_displacement_threshold=1 compute_overlap computation_parameters=[Save memory (but be slower)] image_output=[Write to disk] output_directory=',pathname_rev,'");\n'];
% fprintf(fid_Macro,l);
% fclose(fid_Macro);

%% execute Macro file
% tic
% system(['/projectnb/npbssmic/ns/Fiji/Fiji.app/ImageJ-linux64 --headless -macro ',macropath]);
% toc

%% get FIJI stitching info

% filename = filepath;
% f=strcat(filename,'TileConfiguration.registered.txt');
f=strcat(datapath,'aip/vol',num2str(id),'/TileConfiguration.registered.txt');
coord = read_Fiji_coord(f,'aip');
coord(2:3,:)=coord(2:3,:)./10;
%% coordinates correction
% use median corrdinates for all slices
% coord=squeeze(median(coord,1));

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
% due to the 106x106 size of the FOV, the following line has been changed
% accordingly
% x = [0:stepx-1 repmat(stepx,1,round((1-2*Xoverlap)*Xsize)) round(stepx-1):-1:0]./stepx;
% stepy = Yoverlap*Ysize;
% y = [0:stepy-1 repmat(stepy,1,round((1-2*Yoverlap)*Ysize)) round(stepy-1):-1:0]./stepy;
x = [0:stepx-1 repmat(stepx,1,round((1-2*Xoverlap)*Xsize)) round(stepx-1):-1:0]./stepx;
stepy = Yoverlap*Ysize;
y = [0:stepy-1 repmat(stepy,1,round((1-2*Yoverlap)*Ysize)) round(stepy-1):-1:0]./stepy;
    if strcmp(sys,'PSOCT')
        [rampy,rampx]=meshgrid(y, x);
    elseif strcmp(sys,'Thorlabs')
        [rampy,rampx]=meshgrid(x, y);
    end   
ramp=rampx.*rampy;      % blending mask

%% blending & mosaicing

Mosaic = zeros(round(max(Xcen)+Xsize) ,round(max(Ycen)+Ysize));
Masque = zeros(size(Mosaic));
% 
% cd(filename);    

for i=1:length(index)
        
        in = index(i);
        
        % load file and linear blend

%         filename0=dir(strcat(num2str(in),'_ds.mat'));  %for retardance
        filename0=dir(strcat(target,'-',num2str(islice),'-',num2str(in),'.mat'));
        load(filename0.name);
        
        row = round(Xcen(in)-Xsize/2+1:Xcen(in)+Xsize/2);                                                 %changed by stephan
        column = round(Ycen(in)-Ysize/2+1:Ycen(in)+Ysize/2);
        Masque2 = zeros(size(Mosaic));
        Masque2(row,column)=ramp;
        Masque(row,column)=Masque(row,column)+Masque2(row,column);
        if strcmp(sys,'PSOCT')
            Mosaic(row,column)=Mosaic(row,column)+bfg_cross.*Masque2(row,column); %#################################change us to ub if for mub stitch 
        elseif strcmp(sys,'Thorlabs')
            Mosaic(row,column)=Mosaic(row,column)+ub'.*Masque2(row,column);%#################################
        end
        
end

% process the blended image

MosaicFinal=Mosaic./Masque;
% MosaicFinal=MosaicFinal-min(min(MosaicFinal));
MosaicFinal(isnan(MosaicFinal))=0;
% MosaicFinal(MosaicFinal>20)=0;
    if strcmp(sys,'Thorlabs')
        MosaicFinal=MosaicFinal';
    end
save(strcat(result,'.mat'),'MosaicFinal');

% plot in original scale
% 
% figure;
% imshow(MosaicFinal,'XData', (1:size(MosaicFinal,2))*0.05, 'YData', (1:size(MosaicFinal,1))*0.05);
% axis on;
% xlabel('x (mm)')
% ylabel('y (mm)')
% title('Scattering coefficient (mm^-^1)')
% colorbar;caxis([0 10]);

% rescale and save as tiff
% MosaicFinal = uint16(65535*(mat2gray(MosaicFinal)));      
MosaicFinal = single(MosaicFinal);   
%     nii=make_nii(MosaicFinal,[],[],64);
%     cd('C:\Users\jryang\Downloads\');
%     save_nii(nii,'aip_day3.nii');
% cd(filepath);
tiffname=strcat(result,'.tif');
% imwrite(MosaicFinal,tiffname,'Compression','none');
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