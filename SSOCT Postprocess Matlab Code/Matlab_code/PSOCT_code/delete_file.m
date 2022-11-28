datapath  = ;
cd(datapath)
bad_slice=[49 55 61 67 73 79 85 91 97 103];
for i=1:11
    islice=bad_slice(i);
    for itile=1:270
        filename=dir(strcat(datapath,'cross-',num2str(islice),'-',num2str(itile),'-*.dat'));
        if length(filename)==1
            delete(filename(1).name)
            display(filename(1).name)
        end
        filename=dir(strcat(datapath,'co-',num2str(islice),'-',num2str(itile),'-*.dat'));
        if length(filename)==1
            delete(filename(1).name)
            display(filename(1).name)
        end
    end
end
