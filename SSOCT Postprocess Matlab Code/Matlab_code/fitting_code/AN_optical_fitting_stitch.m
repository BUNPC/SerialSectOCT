 clear all;

scaleF = 10;
Xsize=1060/scaleF;
Ysize=1060/scaleF;
Xoverlap=0.5;
Yoverlap=0.5;

%% get FIJI stitching info

addpath('/projectnb/npbssmic/s/Matlab_code/fitting_code');
addpath('/projectnb/npbssmic/s/Matlab_code/ThorOCT_code');
filename = strcat('/projectnb/npbssmic/ns/200103_PSOCT_2nd_BA44_45_dist_corrected/');
f=strcat(filename,'/aip/vol1/TileConfiguration.registered.txt');
cd(strcat(filename,'/fitting/')); 
coord = read_Fiji_coord(f,'aip');
coord(2,:) = coord(2,:)/scaleF;
coord(3,:) = coord(3,:)/scaleF;

%% define coordinates for each tile

Xcen=zeros(size(coord,2),1);
Ycen=zeros(size(coord,2),1);
index=coord(1,:);
for ii=1:size(coord,2)
    Xcen(coord(1,ii))=round(coord(2,ii));
    Ycen(coord(1,ii))=round(coord(3,ii));
end
Xcen=Xcen-min(Xcen);
Ycen=Ycen-min(Ycen);

Xcen=Xcen+Xsize/2;
Ycen=Ycen+Ysize/2;

% tile range -199~+200
stepx = Xoverlap*Xsize;
x = [0:stepx-1 repmat(stepx,1,(1-2*Xoverlap)*Xsize) stepx-1:-1:0]./stepx;
stepy = Yoverlap*Ysize;
y = [0:stepy-1 repmat(stepy,1,(1-2*Yoverlap)*Ysize) stepy-1:-1:0]./stepy;
[rampy,rampx]=meshgrid(x,y);
ramp=rampx.*rampy;      % blending mask

%% blending & mosaicing
numSlices = 57;
Mosaic3D = zeros(max(Ycen)+Ysize ,max(Xcen)+Xsize, numSlices);
for nSlice = 1:1:numSlices
Mosaic = zeros(max(Xcen)+Xsize ,max(Ycen)+Ysize);
Masque = zeros(size(Mosaic));
    for i=1:length(index)

            in = index(i);

            %% Set file location %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            filename0=dir(strcat('mus_',num2str(nSlice),'_',num2str(in),'.mat'));
            if ~isempty(filename0)
                load(filename0.name);
            else
                us=zeros(Xsize,Ysize);
            end

            row = Xcen(in)-Xsize/2+1:Xcen(in)+Xsize/2;
            column = Ycen(in)-Ysize/2+1:Ycen(in)+Ysize/2;
            Masque2 = zeros(size(Mosaic));
            Masque2(row,column)=ramp;
            Masque(row,column)=Masque(row,column)+Masque2(row,column);
            Mosaic(row,column)=Mosaic(row,column)+us'.*Masque2(row,column);
    end

MosaicFinal=Mosaic./Masque;
MosaicFinal(isnan(MosaicFinal))=0;
MosaicFinal=MosaicFinal';
Mosaic3D(:,:,nSlice) = MosaicFinal;
end

%% plotting
for nSlice = 1:1:numSlices
    figure1 = figure;
    imshow(Mosaic3D(:,:,nSlice));%,'XData', (1:size(MosaicFinal,2))*0.025, 'YData', (1:size(MosaicFinal,1))*0.025);
    axis on;
    xlabel('x (mm)')
    ylabel('y (mm)')
    % title('Scattering coefficient (mm-1)')
    colorbar;caxis([0 10]);
    im_filename = strcat('results/',num2str(nSlice),'.png');
    saveas(figure1, im_filename)
    close all;
end