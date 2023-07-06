function[]=depth_normalize_2(datapath, kernel1, kernel2, ten_ds)
addpath('/projectnb/npbssmic/s/Matlab_code/fitting_code');
addpath('/projectnb/npbssmic/s/Matlab_code/PostProcessing');
addpath('/projectnb/npbssmic/s/Matlab_code/PSOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code/ThorOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code');
%% ref volume correction
cd(datapath);
if ten_ds ==1
    filename=dir(strcat(datapath,'dist_corrected/volume/ref_10ds.btf'));
else
    filename=dir(strcat(datapath,'dist_corrected/volume/ref_4ds.btf'));
end
cd(strcat(datapath,'dist_corrected/volume/'));
stack_norm=[];
try
    for ii=1:100000
        imageData=single(imread(filename(1).name,ii));
        imageData(imageData<3000)=0;
    %     tmp=mean(imageData(imageData>0.1));
        tmp=single(convn(imageData, ones(kernel1,kernel1)./kernel1^2,'same')+500);

        stack_norm(:,:,ii)=single(imageData./tmp);

    end
catch
    display(strcat('total z pixels: ',num2str(ii-1)))
end
stack_norm=uint16(stack_norm./2*65535);
cd(strcat(datapath,'dist_corrected/volume/'))
options.big=true;
options.overwrite=true;
options.append = false;
if ten_ds == 1
    
    saveastiff(stack_norm, 'ref_10ds_norm.btf',options);
else
    saveastiff(stack_norm, 'ref_4ds_norm.btf',options);
end
% %% for each slice multiply by mus
% cd(strcat(datapath,'dist_corrected/volume/'))
% filename=dir(strcat('ref_norm.btf'));
% stack_norm=[];
% for i=1:Z
%     stack_norm(:,:,i)=single(imread(filename(1).name,i));
% end
% % stack_norm=imresize3(stack_norm,[size(stack_norm,1),size(stack_norm,2),size(stack_norm,3)*2]);
% for islice=1:nslice
%     islice
%     cd(strcat(datapath,'fitting/'));
%     filename=dir(strcat(datapath,'fitting/mus',num2str(islice),'.tif'));
%     mus=single(imread(filename(1).name,1));
%     mus=convn(mus,ones(kernel2,kernel2)./kernel2^2,'same');
%     mus=single(mus(1:size(stack_norm,1),1:size(stack_norm,2)));
%     for j=1:(Z/(nslice-50))
%         plane=floor((islice-1-50)*(Z/(nslice-50))+j);
%         stack_norm(:,:,plane)=single(squeeze(stack_norm(:,:,plane)).*mus);
%     end
% end
% % stack_norm=imresize3(stack_norm,[size(stack_norm,1),size(stack_norm,2),size(stack_norm,3)*0.5]);
% stack_norm=single(stack_norm);
% %% save file
% cd(strcat(datapath,'dist_corrected/volume/'))
% options.big=true;
% options.overwrite=true;
% options.append = false;
% saveastiff(stack_norm, 'ref_mus.btf',options)