function sur=surprofile2(slice,sys,ds_factor)
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
        start_pxl=3;
    end
                                            
    % find edge using the first order derivative
    sur=zeros((sizeX/ds_factor),round(sizeY/ds_factor));
    for k=1:round(sizeY/ds_factor)
        bscan=squeeze(vol(:,:,((k-1)*ds_factor+1):(k*ds_factor)));
        for i=1:(sizeX/ds_factor)
            aline=squeeze(bscan(:,((i-1)*ds_factor+1):(i*ds_factor),:));
            aline=squeeze(mean(mean(aline,2),3));
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
