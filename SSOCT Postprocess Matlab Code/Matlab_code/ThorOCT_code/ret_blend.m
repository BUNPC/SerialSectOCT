function ret_blend(datapath,islice,mosaic,pxlsize)
% blending retardance 2D image
% Author: Jiarui Yang
    
    % specify datapath of retardance images
    surpath=strcat(datapath,'retardance/vol',num2str(islice),'/');
    cd(surpath);

    % mosaic parameters & pixel size
    Xoverlap=mosaic(3);
    Yoverlap=mosaic(4);
    
    Xsize=pxlsize(1);                                                                              %changed by stephan
    Ysize=pxlsize(2);

    coordfile = strcat(datapath,'aip/vol',num2str(islice),'/');
    f=strcat(coordfile,'TileConfiguration.registered.txt');
    coord = read_Fiji_coord(f,'aip');

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

    % generating blending mask
    stepx = Xoverlap*Xsize;
    x = [0:stepx-1 repmat(stepx,1,(1-2*Xoverlap)*Xsize) stepx-1:-1:0]./stepx;
    stepy = Yoverlap*Ysize;
    y = [0:stepy-1 repmat(stepy,1,(1-2*Yoverlap)*Ysize) stepy-1:-1:0]./stepy;
    [rampy,rampx]=meshgrid(x,y);
    ramp=rampx.*rampy;
    
    %% blending based on AIP coordinates
    Mosaic = zeros(max(Xcen)+round(Xsize/2) ,max(Ycen)+round(Ysize/2));
    Masque = zeros(size(Mosaic));
    Masque2 = zeros(size(Mosaic));
    

    for i=1:length(index)

        in = index(i);

        filename0=dir(strcat(num2str(in),'.mat'));

        load(filename0(1).name);
        info=strcat('Finished loading tile No.', num2str(in),'\n');
        fprintf(info);


        row = Xcen(in)-round(Xsize/2)+1:Xcen(in)+round(Xsize/2);
        column = Ycen(in)-round(Ysize/2)+1:Ycen(in)+round(Ysize/2);  

        Masque2(row,column)=ramp;
        Masque(row,column)=Masque(row,column)+Masque2(row,column);
        Mosaic(row,column)=Mosaic(row,column)+squeeze(ret_aip).*Masque2(row,column);        
    end
    
    Mosaic=Mosaic./Masque;
    Mosaic(isnan(Mosaic(:)))=0;
    
    % save as TIFF
    MosaicFinal=uint16(65535*(mat2gray(Mosaic)));   
    tiffname=('retardance.tif');
    imwrite(MosaicFinal,tiffname,'Compression','none');     
end

