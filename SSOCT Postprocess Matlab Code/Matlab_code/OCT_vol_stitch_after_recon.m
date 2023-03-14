% volume reconstruction of OCT data
% run this after OCT_recon.m to redo volume reconstruction

% specify dataset directory
datapath  = '/projectnb2/npbssmic/ns/BA4445_samples/I57_part1/';  % OCT data path.
P2path = '/projectnb/npbssmic/ns/Ann_Mckee_samples_20T/NC_6839_2P//';

addpath('/projectnb/npbssmic/s/Matlab_code/fitting_code');
addpath('/projectnb/npbssmic/s/Matlab_code/PostProcessing');
addpath('/projectnb/npbssmic/s/Matlab_code/PSOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code/ThorOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code');

nslice=40; % define total number of slices
njobs=nslice;

id=str2num(id);
for islice=id
    fprintf(strcat('Slice No. ',num2str(islice),' is started.', datestr(now,'DD:HH:MM'),'\n'));
    BaSiC_shading_and_ref_stitch(islice,P2path,datapath, 322, 90, 70,1,0.035/4);  % Find description for parameters in OCT_recon.m
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