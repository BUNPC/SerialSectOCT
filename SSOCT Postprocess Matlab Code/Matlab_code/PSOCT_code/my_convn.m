function[image]=my_convn(image,kernel)
if length(size(image))>2
    display('image size wrong!');return
end
if length(size(kernel))~=2
    display('kernel size wrong!');return
end
kernel_x=floor(size(kernel,1)/2)*2;
kernel_y=floor(size(kernel,2)/2)*2;
ext_image=zeros(size(image,1)+kernel_x,size(image,2)+kernel_y);
ext_image(floor(kernel_x/2)+1:size(image,1)+floor(kernel_x/2),floor(kernel_y/2)+1:size(image,2)+floor(kernel_y/2))=image;
ext_image(1:floor(kernel_x/2),floor(kernel_y/2)+1:size(image,2)+floor(kernel_y/2))=image(1:floor(kernel_x/2),:);
ext_image(size(image,1)+floor(kernel_x/2)+1:end,floor(kernel_y/2)+1:size(image,2)+floor(kernel_y/2))=image(size(image,1)-floor(kernel_x/2)+1:end,:);
ext_image(1:size(image,2)+kernel_x,1:floor(kernel_y/2))=ext_image(:,1+floor(kernel_y/2):2*floor(kernel_y/2));
ext_image(1:size(image,2)+kernel_x,size(image,2)+floor(kernel_y/2)+1:end)=ext_image(:,size(ext_image,2)-floor(kernel_y/2)+1-floor(kernel_y/2):end-floor(kernel_y/2));

ext_image=convn(ext_image,kernel,'same')./(size(kernel,1).^2);
image=ext_image(floor(kernel_x/2)+1:size(image,1)+floor(kernel_x/2),floor(kernel_y/2)+1:size(image,2)+floor(kernel_y/2));
return

