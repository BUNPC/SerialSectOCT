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
datapath  = '/projectnb/npbssmic/ns/Ann_Mckee_samples_20T/NC_6839//';
P2path = '/projectnb/npbssmic/ns/Ann_Mckee_samples_20T/NC_6839_2P//';
% directory that stores distortion corrected 3D tiles. Optional
addpath('/projectnb/npbssmic/s/Matlab_code/fitting_code');
addpath('/projectnb/npbssmic/s/Matlab_code/PostProcessing');
addpath('/projectnb/npbssmic/s/Matlab_code/PSOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code/ThorOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code');
nslice=20; % define total number of slices
njobs=nslice;

id=7;%str2num(id);
for islice=id
%     fprintf(strcat('Slice No. ',num2str(islice),' is started.', datestr(now,'DD:HH:MM'),'\n'));
%     BaSiC_shading_and_ref_stitch_PTSD(id,datapath, 50, 44)
    BaSiC_shading_and_ret_stitch(id,P2path,datapath, 88,70, 160)
%      BaSiC_shading_and_ref_stitch(islice,P2path,datapath, 256, 62, 45);  % start depth, thickness(pixels): volume recon start depth needs to be configured for each sample
%     ref_vol_stitch_from_AB(id,datapath, 50, 40);%depth, thickness
%     Concat_ref_vol(nslice,datapath);
    fprintf(strcat('Slice No. ',num2str(islice),' is stitched.', datestr(now,'DD:HH:MM'),'\n'));

fid=fopen(strcat(datapath,'aip/log',num2str(islice),'.txt'),'w');
fclose(fid);
end
cd(strcat(datapath,'aip/'))
logfiles=dir(strcat(datapath,'aip/log*.txt')); 
if length(logfiles)==njobs
    delete log*.txt
   Concat_ref_vol(nslice,datapath);
%    ref_mus(datapath, nslice, nslice*9, 20); % volume intensity correction, comment the mus part if no fitting is generated
end