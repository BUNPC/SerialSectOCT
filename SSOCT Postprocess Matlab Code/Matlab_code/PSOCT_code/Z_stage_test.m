% add subfunctions for the script. Change directory if not running on BU SCC
addpath('/projectnb/npbssmic/s/Matlab_code/fitting_code');
addpath('/projectnb/npbssmic/s/Matlab_code/PostProcessing');
addpath('/projectnb/npbssmic/s/Matlab_code/PSOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code/ThorOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code');
% specify dataset directory
datapath  = '/projectnb2/npbssmic/ns/Z_stage_test/';

for islice=1:25
name1=strcat(datapath,num2str(islice),'-',num2str(1),'-',num2str(800),'-',num2str(200),'-',num2str(200),'-B.dat'); 
dim1=[800 1 200 1 200];
amp = ReadDat_int16(name1, dim1)./65535*4;
plot(amp(:,100,100))
% view3D(amp);
end