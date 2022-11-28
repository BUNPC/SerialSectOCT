Zsize = 238;
Xrpt=1;Yrpt=1;
Xsize=1000;
Ysize=1000;
dim=[Zsize Xrpt Xsize Yrpt Ysize];     % tile size for reflectivity 
name=strcat('ref-',num2str(1),'-',num2str(45),'-',num2str(Zsize),'-',num2str(Xsize),'-',num2str(Ysize),'.dat'); 
% load data
amp = ReadDat_int16(name, dim)./65535*4;
