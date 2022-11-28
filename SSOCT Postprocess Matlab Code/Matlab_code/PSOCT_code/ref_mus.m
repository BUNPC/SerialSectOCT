function[]=ref_mus(datapath, nslice, Z, kernel1, kernel2)
addpath('/projectnb/npbssmic/s/Matlab_code/fitting_code');
addpath('/projectnb/npbssmic/s/Matlab_code/PostProcessing');
addpath('/projectnb/npbssmic/s/Matlab_code/PSOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code/ThorOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code');
%% ref volume correction
% cd(datapath);
% filename=dir(strcat(datapath,'dist_corrected/volume/ref51-108.btf'));
% cd(strcat(datapath,'dist_corrected/volume/'));
% stack_norm=[];
% for i=1:Z
%     imageData=single(imread(filename(1).name,i));
%     tmp=single(convn(imageData, ones(kernel1,kernel1)./kernel1^2,'same')+0.0001);
% %     imageData(imageData<0.115)=0;
%     stack_norm(:,:,i)=single(imageData./tmp);
% end
% stack_norm=single(stack_norm);
% cd(strcat(datapath,'dist_corrected/volume/'))
% options.big=true;
% options.overwrite=true;
% options.append = false;
% saveastiff(stack_norm, 'ref_norm51-108.btf',options)
%% for each slice multiply by mus
cd(strcat(datapath,'dist_corrected/volume/'))
filename=dir(strcat('ref_norm51-108.btf'));
stack_norm=[];
for i=1:Z
    stack_norm(:,:,i)=single(imread(filename(1).name,i));
end
% stack_norm=imresize3(stack_norm,[size(stack_norm,1),size(stack_norm,2),size(stack_norm,3)*2]);
for islice=51:nslice
    islice
    cd(strcat(datapath,'fitting/'));
    filename=dir(strcat(datapath,'fitting/mus',num2str(islice),'.tif'));
    mus=single(imread(filename(1).name,1));
    mus=convn(mus,ones(kernel2,kernel2)./kernel2^2,'same');
    mus=single(mus(1:size(stack_norm,1),1:size(stack_norm,2)));
    for j=1:(Z/(nslice-50))
        plane=floor((islice-1-50)*(Z/(nslice-50))+j);
        stack_norm(:,:,plane)=single(squeeze(stack_norm(:,:,plane)).*mus);
    end
end
% stack_norm=imresize3(stack_norm,[size(stack_norm,1),size(stack_norm,2),size(stack_norm,3)*0.5]);
stack_norm=single(stack_norm);
%% save file
cd(strcat(datapath,'dist_corrected/volume/'))
options.big=true;
options.overwrite=true;
options.append = false;
saveastiff(stack_norm, 'ref_mus51-108.btf',options)