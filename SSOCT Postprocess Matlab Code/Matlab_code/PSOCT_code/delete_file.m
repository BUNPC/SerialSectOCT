OCTpath  = '/projectnb2/npbssmic/ns/remote_folder/';  % OCT data path.              ADJUST FOR EACH SAMPLE!!!
cd(strcat(OCTpath,'dist_corrected/'))

for islice=1:9
    for itile=1:323
        filename=dir(strcat('co-',num2str(islice),'-',num2str(itile),'-*.dat'));
        co = single(ReadDat_int16(filename(1).name, [263,1,1000,1,1000]))./65535*4;
        m=mean2(mean(co,1));
        if m<0.01
            if length(filename)==1
                delete(filename(1).name)
                display(filename(1).name)
            end
            filename=dir(strcat('cross-',num2str(islice),'-',num2str(itile),'-*.dat'));
            if length(filename)==1
                delete(filename(1).name)
                display(filename(1).name)
            end
            filename=dir(strcat('ori-',num2str(islice),'-',num2str(itile),'-*.dat'));
            if length(filename)==1
                delete(filename(1).name)
                display(filename(1).name)
            end
        end
    end
end
