slice=Ref;
sys='PSOCT';
n=3;
    v=ones(3,n,n)./(n*n*3);
    vol=convn(slice,v,'same');

    % define the number of B scans and the maximum possible depth of surface
    sizeY=size(vol,2);
    sizeX=size(vol,1);
    
    % define the starting pixel for surface finding
    if strcmp(sys,'PSOCT')
        start_pxl=3;
    elseif strcmp(sys,'Thorlabs')
        start_pxl=30;
    end
                                            
    % find edge using the first order derivative
    ds_factor=10;
    sur=zeros((sizeX/10),round(sizeY/10));
    for k=1:round(sizeY/10)
        bscan=squeeze(vol(:,((k-1)*ds_factor+1):(k*ds_factor),:));
        for i=1:(sizeX/10)
            aline=squeeze(bscan(((i-1)*ds_factor+1):(i*ds_factor),:,:));
            aline=squeeze(mean(mean(aline,1),2));
            [m]=max(aline(1:23));
            if m>1.2
%                 dl=diff(movmean(aline,10));
%                 [~, loc]=max(dl(start_pxl:start_pxl+150));                                                %changed by stephan on 191128
                loc=findchangepts(aline(1:23));
                loc=loc+start_pxl;
                sur(i,k)=loc;
            else
                sur(i,k)=0;
            end
        end
    end

