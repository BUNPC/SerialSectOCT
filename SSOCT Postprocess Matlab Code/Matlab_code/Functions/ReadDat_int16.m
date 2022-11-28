% load 3D data, Return Dim.nk_Dim.nx_Dim.ny, applicable for non-stop Ascan
% Rpt_extract=[Rpt_start, Rpt_interval, Rpt_n]
% input: 
    % filePath=[folderPath filename]
    % Dim.nk: number of spectrum pixel (camera pixel)
    % Dim.nxRpt:  nA repeat
    % Dim.nx: nA per Bscan
    % Dim.nyRpt: nB repeat
    % Dim.ny: nB to load
    % iseg: the ith segment
    % ARpt_extract: data load information, [RptA_start,RptA_Interval,RptA_n];
    % RptBscan: load Bscan repeat data
% output:
    % DAT [Dim.nk,RptA_n_P*Dim.nx*Dim.nyRpt,Dim.ny]
%%%%%%%%%%%%%%%%%%%%% EXAMPLE
% filePath=[datapath,filename];
% [Dim, fNameBase,fIndex]=GetNameInfoRaw(filename);
% disp(['Loading data to select the field of focus... ', num2str(floor(N_YChks/2)), ', ',datestr(now,'DD-HH:MM:SS')]);
% DimChk=Dim;  DimChk.ny=1; 
% ARpt_extract=[RptA_start,RptA_Interval,RptA_n];
% DAT = ReadDat_int16(filePath, DimChk, floor(N_YChks/2),ARpt_extract); % NII_ori: nk_Nx_ny,Nx=nt*nx;  floor(N_kfile/2)
function DAT= ReadDat_int16(filePath, Dim, iseg, ARpt_extract,RptBscan) 
if nargin <3
    iseg=1;
    ARpt_extract=[1 1 Dim.nxRpt];
    RptBscan=0;
end
if nargin <4
    ARpt_extract=[1 1 Dim.nxRpt];
    RptBscan=0;
end
if nargin <5
    RptBscan=0;
end
RptA_start_P=ARpt_extract(1);
RptA_interval_P=ARpt_extract(2);
RptA_n_P=ARpt_extract(3);

DAT = zeros(Dim.nk,RptA_n_P*Dim.nx*Dim.nyRpt,Dim.ny, 'single');
% read data   
fid=fopen(filePath,'r','l');
Start_iseg=(iseg-1)*Dim.nk*Dim.nxRpt*Dim.nx*Dim.nyRpt*Dim.ny*2;
for i = 1:Dim.ny
    fseek(fid,Start_iseg+(i-1)*Dim.nk*Dim.nxRpt*Dim.nx*Dim.nyRpt*2,'bof'); % due to the data type is int16 (bytes16), it therefore has to x2
    frame_data = fread(fid, Dim.nk*Dim.nxRpt*Dim.nx*Dim.nyRpt, 'int16');
    if RptBscan==1
        datatemp(:,:,:)=reshape(frame_data, [Dim.nk Dim.nxRpt*Dim.nx,Dim.nyRpt]);
        datatemp2=permute(datatemp,[1 3 2]);
        datatemp3=reshape(datatemp2,[Dim.nk,Dim.nyRpt*Dim.nxRpt*Dim.nx]);
        DAT(:,:,i)=datatemp3;
    else
        if RptA_n_P == Dim.nxRpt
            DAT(:,:,i)=reshape(frame_data, [Dim.nk Dim.nxRpt*Dim.nx*Dim.nyRpt]);
        else % read data with a different read-nxRpt value than the acquisition-nxRpt
            data_ori = zeros(Dim.nk,Dim.nxRpt,Dim.nx*Dim.nyRpt, 'single');
            data_ori(:,:,:) = reshape(frame_data, [Dim.nk Dim.nxRpt, Dim.nx*Dim.nyRpt]);
            DAT(:,:,i)=reshape(data_ori(:,RptA_start_P:RptA_interval_P:RptA_start_P+(RptA_n_P-1)*RptA_interval_P,:),[Dim.nk,RptA_n_P*Dim.nx*Dim.nyRpt]);
        end
    end
            
    if (mod(i,ceil(Dim.ny/2)) == 0)  
        disp(['... ReadDat int16 ' num2str(i) '/' num2str(Dim.ny) '	' datestr(now,'HH:MM')]);  
    end    
end
fclose(fid);
   

   