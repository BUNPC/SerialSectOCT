% volume reconstruction of OCT data
% run this after OCT_recon.m to redo volume reconstruction

% specify dataset directory
OCTpath  = '/projectnb2/npbssmic/ns/PSOCT_2PM_sample/';  % OCT data path.
P2path = '/projectnb2/npbssmic/ns/PSOCT_2PM_sample/2PM/';
mkdir(strcat(OCTpath,'dist_corrected/volume'));
addpath('/projectnb/npbssmic/s/Matlab_code/fitting_code');
addpath('/projectnb/npbssmic/s/Matlab_code/PostProcessing');
addpath('/projectnb/npbssmic/s/Matlab_code/PSOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code/ThorOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code');

nslice=42; % define total number of slices
njobs=nslice;

id=str2num(id);
for islice=id
    fprintf(strcat('Slice No. ',num2str(islice),' is started.', datestr(now,'DD:HH:MM'),'\n'));
    BaSiC_shading_and_ref_stitch(islice,P2path,OCTpath, 322, 50, 44,0,0.035/4);  % Find description for parameters in OCT_recon.m
    fprintf(strcat('Slice No. ',num2str(islice),' is stitched.', datestr(now,'DD:HH:MM'),'\n'));
    fid=fopen(strcat(OCTpath,'dist_corrected/volume/log',num2str(islice),'.txt'),'w');
    fclose(fid);
end
cd(strcat(OCTpath,'dist_corrected/volume/'))
logfiles=dir(strcat(OCTpath,'dist_corrected/volume/log*.txt')); 
if length(logfiles)==njobs
%     delete log*.txt
    Concat_ref_vol(nslice,OCTpath, 0.035/4);
%     ref_mus(datapath, nslice, nslice*8, 20,20); % volume intensity correction, comment the mus part if no fitting is generated
end