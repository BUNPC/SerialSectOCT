%% ----------------------------------------- %%
% Note Jan 28 2020:
%
% Current version of code does FOV correction, grid correction & MIP/AIP
% generation, surface finding & profiling, mosacing & blending
%
% Suggested parallelization method: one slice per thread
% 
% volume stitching is currently in another code
%
% Note Oct 28 2019:
%
% Current version of code does FOV correction, grid correction & MIP/AIP
% generation, surface finding & profiling, mosacing & blending
% 
% volume stitching is currently in another code
%
% Note Nov 5 2019:
% 
% All parameters were moved to the beginning of the script
% volume stitching is currently in another code
%
% Note 09/02/2020
%
% Current version of code does FOV correction(optional), grid correction(optional) & MIP/AIP
% generation, surface finding & profiling, mosacing & blending
%
%
% Author: Jiarui Yang, Stephan Chang
%%%%%%%%%%%%%%%%%%%%%%%

% specify dataset directory
datapath  = '/projectnb/npbssmic/ns/BA4445_4/';
P2path = '/projectnb/npbssmic/ns/BA4445_4_2P/';
% directory that stores distortion corrected 3D tiles. Optional
addpath('/projectnb/npbssmic/s/Matlab_code/fitting_code');
addpath('/projectnb/npbssmic/s/Matlab_code/PostProcessing');
addpath('/projectnb/npbssmic/s/Matlab_code/PSOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code/ThorOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code');
nslice=120; % define total number of slices
njobs=120;

id=str2num(id);
section=ceil(nslice/njobs);
istart=(id-1)*section+1;
istop=id*section;
for islice=istart:istop
%     fprintf(strcat('Slice No. ',num2str(islice),' is started.', datestr(now,'DD:HH:MM'),'\n'));
%     BaSiC_shading_and_ref_stitch_PTSD(id,datapath, 50, 44)
%      if mod(islice,2)>0    
%             height=round(Gen_slice_height(0.1,islice,datapath));
%      end
     height=round(Gen_slice_height(0.1,islice-1,datapath));
     BaSiC_shading_and_ref_stitch(islice,P2path,datapath, 154, height+15, 64);  % start depth, thickness(pixels): volume recon start depth needs to be configured for each sample
%     ref_vol_stitch_from_AB(id,datapath, 50, 40);%depth, thickness
%     Concat_ref_vol(nslice,datapath);
    fprintf(strcat('Slice No. ',num2str(islice),' is stitched.', datestr(now,'DD:HH:MM'),'\n'));

fid=fopen(strcat(datapath,'aip/log',num2str(islice),'.txt'),'w');
fclose(fid);
end
% cd(strcat(datapath,'aip/'))
% logfiles=dir(strcat(datapath,'aip/log*.txt')); 
% if length(logfiles)==njobs
%     delete log*.txt
%    Concat_ref_vol(nslice,datapath);
% %    ref_mus(datapath, nslice, (nslice-50)*5, 20,1); % volume intensity correction, comment the mus part if no fitting is generated
% end