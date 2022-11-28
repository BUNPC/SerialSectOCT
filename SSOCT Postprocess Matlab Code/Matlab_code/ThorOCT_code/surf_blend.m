function surf_blend(datapath,islice,mosaic,pxlsize,pattern)
    %% stitches surface profile using linear blending
    % Author: Jiarui Yang
    % 01/09/20

    % specify datapath of surface profiles
    surpath=strcat(datapath,'surf/vol',num2str(islice),'/');
    cd(surpath);

    % mosaic parameters & pixel size
    
    numX=mosaic(1);
    numY=mosaic(2);
    Xoverlap=mosaic(3);
    Yoverlap=mosaic(4);
    
    Xsize=pxlsize(1);                                                                              %changed by stephan
    Ysize=pxlsize(2);

    % generating blending mask
    stepx = Xoverlap*Xsize;
    x = [0:stepx-1 repmat(stepx,1,(1-2*Xoverlap)*Xsize) stepx-1:-1:0]./stepx;
    stepy = Yoverlap*Ysize;
    y = [0:stepy-1 repmat(stepy,1,(1-2*Yoverlap)*Ysize) stepy-1:-1:0]./stepy;
    [rampy,rampx]=meshgrid(x,y);
    ramp=rampx.*rampy;

    % generating coordinates grid based on acquisition mode
    numTile=numX*numY;
    grid=zeros(2,numTile);
    % compute grid distances
    xx=(1-Xoverlap)*Xsize;
    yy=(1-Yoverlap)*Ysize;
    xy=0;
    yx=0;
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
         for i=1:numTile
            % odd lines
            if mod(ceil(i/numX),2)==1
                if mod(i,numX)==0
                    grid(1,i)=(numX-1)*xx+floor(i/numX)*yx;
                    grid(2,i)=-(numX-1)*xy-(floor(i/numX)-1)*yy;
                else
                    grid(1,i)=(mod(i,numX)-1)*xx+floor(i/numX)*yx;
                    grid(2,i)=-(mod(i,numX)-1)*xy-floor(i/numX)*yy;
                end
            else    % even lines 
                if mod(i,numX)==0
                    grid(1,i)=floor(i/numX)*yx;
                    grid(2,i)=-(floor(i/numX)-1)*yy;
                else
                    grid(1,i)=(numX-mod(i,numX))*xx+floor(i/numX)*yx;
                    grid(2,i)=-(numX-mod(i,numX))*xy-floor(i/numX)*yy;
                end
            end
            
        end
    end

    grid(2,:)=grid(2,:)-min(grid(2,:));
    
    grid(1,:)=round(grid(1,:))+Xsize/2;
    grid(2,:)=round(grid(2,:))+Ysize/2;

    Mosaic = zeros(max(grid(1,:))+Xsize/2,max(grid(2,:))+Ysize/2);
    Masque = zeros(size(Mosaic));

    for i=1:size(grid,2)

        % load file and linear blend
        filename0=dir(strcat(num2str(i),'.mat'));
        load(filename0(1).name);

        row = round(grid(1,i)-Xsize/2+1:grid(1,i)+Xsize/2);
        column = round(grid(2,i)-Ysize/2+1:grid(2,i)+Ysize/2);

        Masque2 = zeros(size(Mosaic));
        Masque2(row,column)=ramp;
        Masque(row,column)=Masque(row,column)+Masque2(row,column);
        Mosaic(row,column)=Mosaic(row,column)+sur'.*Masque2(row,column);

    end

    MosaicFinal=Mosaic./Masque;
    save('mosaic.mat','MosaicFinal');
    
end