function[]=Sum_all_2P(folder, ntiles)
addpath('/projectnb/npbssmic/s/Matlab_code/fitting_code');
addpath('/projectnb/npbssmic/s/Matlab_code/PostProcessing');
addpath('/projectnb/npbssmic/s/Matlab_code/PSOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code/ThorOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code');

% folder='/projectnb2/npbssmic/ns/210626_2P_test/';
cd(folder);
files=dir('*.tif');
shade1=zeros(2048,2048);
shade2=zeros(2048,2048);

for i=1:ntiles

    imageData1 = double(imread(files(i).name, 1))./65535;
    imageData2 = double(imread(files(i).name, 2))./65535;
    shade1=shade1+imageData1;
    shade2=shade2+imageData2;
end

shade1=single(shade1./max(shade1(:)));
save(strcat(folder,'shade1.mat'),'shade1');


shade2=single(shade2./max(shade2(:)));
save(strcat(folder,'shade2.mat'),'shade2');