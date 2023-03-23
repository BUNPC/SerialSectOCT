function[]=Concat_ref_vol(num_slice, datapath, aip_threshold)
% concatenate all slices into a volume stack
% default is 10x10 pixel downsample, which is 30x30x35um voxel size

cd(strcat(datapath,'dist_corrected/volume'));
addpath('/projectnb/npbssmic/s/Matlab_code/fitting_code');
addpath('/projectnb/npbssmic/s/Matlab_code/PostProcessing');
addpath('/projectnb/npbssmic/s/Matlab_code/PSOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code/ThorOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code');
addpath('/projectnb/npbssmic/s/Matlab_code/NIfTI_20140122');

volume=[];
clear options;
options.big = true; % Use BigTIFF format
options.overwrite = true;
options.append = false;
for islice=1:num_slice
   filename = strcat('ref_4ds',num2str(islice),'.mat');
   if isfile(filename)
       load(filename);
       Ref=single(imresize3(Ref,0.4));
       
       %% remove agarose
    % %     if rem(id,2)==0
    % %         id_aip=id-1;
    % %     else
    % %         id_aip=id;
    % %     end
%         id_aip=id;
%         while ~isfile(strcat(datapath,'aip/aip',num2str(id_aip),'.mat'))
%             pause(600);
%         end
%         load(strcat(datapath,'aip/aip',num2str(id_aip),'.mat'));
%         AIP=imresize(AIP,0.1);
%         mask=zeros(size(AIP));
%         mask(AIP>aip_threshold)=1;
% 
%         if size(mask,1)>size(Ref,1)
%             xx=size(Ref,1);
%         else
%             xx=size(mask,1);
%         end
%         if size(mask,2)>size(Ref,2)
%             yy=size(Ref,2);
%         else
%             yy=size(mask,2);
%         end
%         for ii = 1:size(Ref,3)
%             Ref(1:xx,1:yy,ii)=Ref(1:xx,1:yy,ii).*mask(1:xx,1:yy);
%         end

       % normalize total image intensity
       for zz = 1:size(Ref,3)
           plane=squeeze(Ref(:,:,zz));
           m=mean(mean(plane(plane>0.001)));
           Ref(:,:,zz)=plane./m;
       end
       volume=cat(3,volume,Ref);
       info=strcat('loading slice No.',num2str(islice),' is finished.\n');
       fprintf(info);
   end
end

saveastiff(single(volume), 'ref_10ds.btf',options);

% save as nifti
%nii=make_nii(single(volume),[0.012 0.012 0.012],[0 0 0],32,'OCT volume for subject I46');
%save_nii(nii,'/projectnb/npbssmic/ns/200103_PSOCT_2nd_BA44_45_dist_corrected/nii/sub-I46_ses-OCT.nii');

info=strcat('concatinating slices is finished.\n');
fprintf(info);