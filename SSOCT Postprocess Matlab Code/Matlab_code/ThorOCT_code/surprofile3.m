function sur=surprofile3(slice,sys)

    % volumetric averaging smoothing
    n=3;
    v=ones(3,n,n)./(n*n*3);
    vol=convn(slice,v,'same');

    % define the number of B scans and the maximum possible depth of surface
    sizeY=size(vol,3);
    sizeX=size(vol,2);
    
    % define the starting pixel for surface finding
    if strcmp(sys,'PSOCT')
        start_pxl=3;
    elseif strcmp(sys,'Thorlabs')
        start_pxl=30;
    end
                                            
    % find edge using the first order derivative
    sur=zeros((sizeX),round(sizeY));
    for k=1:sizeY
        bscan=squeeze(vol(:,:,k));
        for i=1:sizeX
            aline=squeeze(bscan(:,i));
            [m,z]=max(aline(start_pxl:end));
            z=min(z+20,size(vol,1)-5);
            if m>0.01
               loc=findchangepts(aline(start_pxl:z));
               loc=loc+start_pxl;
               try
                   sur(i,k)=loc;
               catch
                   sur(i,k)=start_pxl;
               end
            else
                sur(i,k)=0;
            end
        end
    end
end
