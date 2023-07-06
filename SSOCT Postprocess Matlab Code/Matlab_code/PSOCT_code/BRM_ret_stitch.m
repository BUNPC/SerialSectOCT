datapath='/projectnb/npbssmic/ns/PSOCT-qBRM_sample/sample2/qBRM_orientation/Retardance_9by11/';
%% stitch the retardance using the coordinates from AIP stitch
% add subfunctions for the script
addpath('/projectnb/npbssmic/s/Matlab_code/fitting_code');
addpath('/projectnb/npbssmic/s/Matlab_code/PostProcessing');
addpath('/projectnb/npbssmic/s/Matlab_code/PSOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code/ThorOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code');
cd(datapath);
sys='PSOCT';
% mosaic parameters
Xoverlap=0.1;
Yoverlap=0.1;
Xsize=2960;                                                                              %changed by stephan
Ysize=2960;
%% get FIJI stitching info
% use following 3 lines if stitch using OCT coordinates
f=strcat(datapath,'TileConfiguration.registered.txt');
coord = read_Fiji_coord(f,'RGB_norm');
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


%% blending & mosaicing
Mosaic = zeros(round(max(Xcen)+Xsize) ,round(max(Ycen)+Ysize));
Masque = zeros(size(Mosaic));

for i=1:length(index)
        in = index(i);
        ret_aip=single(imread(strcat(datapath,'ret_',num2str(in,'%03d'),'.tif'),1));
        row = round(Xcen(in)-Xsize/2+1:Xcen(in)+Xsize/2);                              
        column = round(Ycen(in)-Ysize/2+1:Ycen(in)+Ysize/2);
        Masque2 = zeros(size(Mosaic));
        Masque2(row,column)=ramp;
        Masque(row,column)=Masque(row,column)+Masque2(row,column);
        if strcmp(sys,'PSOCT')
            Mosaic(row,column)=Mosaic(row,column)+ret_aip.*Masque2(row,column); 
        elseif strcmp(sys,'Thorlabs')
            Mosaic(row,column)=Mosaic(row,column)+ret_aip'.*Masque2(row,column);
        end
        
end

ret_aip=Mosaic./Masque;
ret_aip(isnan(ret_aip))=0;
ret_aip = single(ret_aip);  

%     nii=make_nii(MosaicFinal,[],[],64);
%     cd('C:\Users\jryang\Downloads\');
%     save_nii(nii,'aip_day3.nii');
% cd(filepath);
tiffname=strcat(datapath,'retardance.tif');
SaveTiff(ret_aip,1,tiffname);