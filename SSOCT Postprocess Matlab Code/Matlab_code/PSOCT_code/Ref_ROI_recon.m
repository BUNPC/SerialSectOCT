addpath('/projectnb/npbssmic/s/Matlab_code/fitting_code');
addpath('/projectnb/npbssmic/s/Matlab_code/PostProcessing');
addpath('/projectnb/npbssmic/s/Matlab_code/PSOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code/ThorOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code');
% specify dataset directory
datapath  = '/projectnb2/npbssmic/ns/feature_paper_sample_OCT/';
cd(strcat(datapath,'dist_corrected/volume/'))
x0=5601;
x1=7300;
y0=2001;
y1=4000;
vol=[];
for islice=51:70
    filename0=dir(strcat('Ref_BASIC',num2str(islice),'.btf'));
    for plane=1:22
        imageData1 = single(imread(filename0(1).name, 1));
        i=(islice-51)*22+plane;
        vol(:,:,i)=imageData1(y0:y1,x0:x1);
    end
end
clear options;
options.big = true; % Use BigTIFF format
options.overwrite = true;
saveastiff(single(vol), strcat(datapath,'dist_corrected/Ref_51-70_ROI1.btf'), options);
   