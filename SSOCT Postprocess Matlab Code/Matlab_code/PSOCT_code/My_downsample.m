function[aip_ds]=My_downsample(aip)
sizeX=size(aip,1);
sizeY=size(aip,2);
ds_factor=10;
aip_ds=zeros((sizeX/ds_factor),round(sizeY/ds_factor));
for k=1:round(sizeY/ds_factor)
    bscan=squeeze(aip(:,((k-1)*ds_factor+1):(k*ds_factor)));
    for i=1:(sizeX/ds_factor)
        aline=squeeze(bscan(((i-1)*ds_factor+1):(i*ds_factor)));
        aline=squeeze(mean(aline));
        aip_ds(i,k)=aline;

    end
end