% load 3D data, Return nk_Nx_ny, applicable for non-stop Ascan
function data= ReadDat_single(filePath, dim) % [nk nx nframe/ny]
nk = dim(1); nxRpt = dim(2); nx=dim(3); nyRpt = dim(4); ny = dim(5);
data = zeros(nk,nx*nyRpt,ny, 'single');
% read data   
fid=fopen(filePath,'r','l');
for i = 1:ny
    fseek(fid,(i-1)*nk*nxRpt*nx*nyRpt*4,'bof'); % due to the data type is single (32 bytes), it therefore has to x4
    frame_data = fread(fid, nk*nxRpt*nx*nyRpt, 'single');
    datatemp(:,:,:)=reshape(frame_data, [nk nxRpt*nx,nyRpt]);
    datatemp=permute(datatemp,[1 3 2]);
    datatemp=reshape(datatemp,[nk,nyRpt*nxRpt*nx]);
    data(:,:,i)=datatemp;
end
fclose(fid);
   

   