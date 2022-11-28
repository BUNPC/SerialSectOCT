function[]=Concat_ref_high_res_vol(num_slice, datapath)
% num_slice=60;
filename = strcat(datapath,'dist_corrected/volume/ref_high_res_',num2str(1),'.mat');
load(filename);
volume=[];

for islice=1:num_slice
    
    filename = strcat(datapath,'dist_corrected/volume/ref_high_res_',num2str(islice),'.mat');
    load(filename);
    
    volume=cat(3,volume,uint16(Ref.*2000));
    
    info=strcat('loading slice No.',num2str(islice),' is finished.\n');
    fprintf(info);
end

% save as HDF5
save(strcat(datapath,'dist_corrected/volume/ref_high_res.mat'),'volume','-v7.3');
end