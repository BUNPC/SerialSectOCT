function output = median_kernel(input,kernel_size)
% calculate the 3d spatial moving mean
% kernel size has to be odd
% input should be a 3d matrix
% Jiarui Yang
    output = input;
    for x=(kernel_size+1)/2:size(input,1)-(kernel_size-1)/2
        for y=(kernel_size+1)/2:size(input,2)-(kernel_size-1)/2
            for z=(kernel_size+1)/2:size(input,3)-(kernel_size-1)/2
                output(x,y,z)=median(input(x-(kernel_size-1)/2:x+(kernel_size-1)/2,y-(kernel_size-1)/2:y+(kernel_size-1)/2,z-(kernel_size-1)/2:z+(kernel_size-1)/2),'all');
            end
        end
    end
end