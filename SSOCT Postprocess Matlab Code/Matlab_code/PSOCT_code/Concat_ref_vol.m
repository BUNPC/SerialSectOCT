function[]=Concat_ref_vol(num_slice, datapath)

cd(strcat(datapath,'dist_corrected/volume'));

addpath('/projectnb/npbssmic/s/Matlab_code/fitting_code');
addpath('/projectnb/npbssmic/s/Matlab_code/PostProcessing');
addpath('/projectnb/npbssmic/s/Matlab_code/PSOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code/ThorOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code');
volume=[];
addpath('/projectnb/npbssmic/s/Matlab_code/NIfTI_20140122');

clear options;
options.big = true; % Use BigTIFF format
options.overwrite = true;
options.append = false;
for islice=1:num_slice
     filename = strcat('ref',num2str(islice),'.mat');
     load(filename);
%    filename = strcat(datapath,'dist_corrected/volume/Ref_BASIC',num2str(islice),'.tif');
%     filename = strcat(datapath,'dist_corrected/volume/ref_raw',num2str(islice),'.btf');
%    if isfile(filename)
%         for plane=1:9
%             Ref(:,:,plane) = single(imread(filename, plane));
%         end
%        Ref=imresize3(Ref,1/2);
        volume=cat(3,volume,Ref);
        
        info=strcat('loading slice No.',num2str(islice),' is finished.\n');
        fprintf(info);
%    end
end
saveastiff(volume, 'ref.btf',options);
% cd(strcat(datapath,'dist_corrected/volume'))
%save as big tiff



% save as nifti
%nii=make_nii(single(volume),[0.012 0.012 0.012],[0 0 0],32,'OCT volume for subject I46');
%save_nii(nii,'/projectnb/npbssmic/ns/200103_PSOCT_2nd_BA44_45_dist_corrected/nii/sub-I46_ses-OCT.nii');

info=strcat('concatinating slices is finished.\n');
fprintf(info);