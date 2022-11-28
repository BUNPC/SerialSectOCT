
function RetDownsample_Hui(target, datapath,disp,mosaic,pxlsize,islice,pattern,sys,res)
% add subfunctions for the script
addpath('/projectnb/npbssmic/s/Matlab_code');

result=target;
id=islice;

% specify system name
sys = 'PSOCT';

filepath=strcat(datapath,'retardance/vol',num2str(islice),'/');
cd(filepath);
filename0=dir(strcat('*.mat'));
% retname0=dir(strcat('test_processed_','*_retardance.nii'));
ntile=length(filename0);
% total number of slices

for islice=1
    
    % get the directory of all image tiles
%     cd(datapath);
%     filename0=dir(strcat('test_processed_','*_cropped.nii'));
    
    for iFile=1:ntile

        % get data information
        name=strsplit(filename0(iFile).name,'.');
%         name_dat=strsplit(name{1},'_');
        
%         slice_index=name{1};
        slice_index=islice;
        coord=num2str(str2num(name{1}));
        
        % Xrpt and Yrpt are x and y scan repetition, default = 1
%         Zsize = str2num(name{3}); Xrpt = 1; Xsize=str2num(name{4}); Yrpt = 1; Ysize = str2num(name_dat{1});
%         Zsize=120;
%         Xsize=420;
%         Ysize=420;
        
        load(strcat(filename0(iFile).name));
%         aip=Read_nii(datapath,filename0(iFile).name);
        aip_ds = zeros(round(size(ret_aip,1)/res),round(size(ret_aip,2)/res));

        for i = 1:round(size(ret_aip,1)/res)
            for j = 1:round(size(ret_aip,2)/res)
                area = ret_aip((i-1)*res+1:i*res,(j-1)*res+1:j*res);
                int = mean(area(:));
                aip_ds(i,j)=int;
            end
        end
        save(strcat(filepath,coord,'_ds.mat'),'aip_ds');

    end
    
    
    
end