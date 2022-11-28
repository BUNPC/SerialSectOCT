function[slice]=Shading_corr(slice, mask)
for z=1:size(slice,1)
    slice(z,:,:)=squeeze(slice(z,:,:))./mask;
end
