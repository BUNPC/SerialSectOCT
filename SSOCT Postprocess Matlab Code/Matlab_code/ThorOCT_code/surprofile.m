function sur=surprofile(slice,sys)

    % volumetric averaging smoothing
    n=3;
    v=ones(3,n,n)./(n*n*3);
    vol=convn(slice,v,'same');

    % define the number of B scans and the maximum possible depth of surface
    sizeY=size(vol,3);
    sizeX=size(vol,2);
    
    % define the starting pixel for surface finding
    if strcmp(sys,'PSOCT')
        start_pxl=6;
    elseif strcmp(sys,'Thorlabs')
        start_pxl=30;
    end
                                            
    % find edge using the first order derivative
    sur=zeros(sizeX,sizeY);
    for k=1:sizeY
        bscan=squeeze(vol(:,:,k));
        for i=1:sizeX
            aline=squeeze(bscan(:,i));
            if max(aline(start_pxl:end))>1e-4
                dl=diff(movmean(aline,5));
                [~, loc]=max(dl(start_pxl:start_pxl+50));                                                %changed by stephan on 191128
                loc=loc+start_pxl;
                sur(i,k)=loc;
            else
                sur(i,k)=0;
            end
        end
    end
end
