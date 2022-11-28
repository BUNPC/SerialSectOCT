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
datapath  = strcat('/projectnb2/npbssmic/ns/210310_4x4x2cm_milestone/');
% directory that stores distortion corrected 3D tiles. Optional
addpath('/projectnb/npbssmic/s/Matlab_code/PSOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code/ThorOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code');

nslice=156; % define total number of slices

% the following indented lines are for multi-thread processing
% on BU SCC only. The purpose here is to divide the data into njobs groups,
% njobs being the number of threads used. istart and istop are the start and stop tile
% number for id-th thread.
%
% Define your own istart and istop if not running on BU SCC
% the $SGE-TASK-ID environment variable read in is CHARACTER, need to transfer to number
id=str2num(id);

for islice=id           
% Stitching 
    ret_vol_stitch_from_AB(id,datapath);
%   Concat_ref_vol(nslice,datapath);
    fprintf(strcat('Slice No. ',num2str(islice),' is stitched.', datestr(now,'DD:HH:MM'),'\n'));

end