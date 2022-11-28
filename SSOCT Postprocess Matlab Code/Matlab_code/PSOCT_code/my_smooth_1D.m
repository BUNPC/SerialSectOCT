function[data]=my_smooth_1D(array,kernel)
kernel=floor(kernel/2);
data=zeros(size(array));
for i=1:length(array)
    data(i)=mean(array(max(1,i-kernel):min(i+kernel,length(array))));
end