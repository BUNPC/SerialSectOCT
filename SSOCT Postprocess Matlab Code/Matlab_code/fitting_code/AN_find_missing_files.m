dataDir  = strcat('/projectnb/npbssmic/ns/200103_PSOCT_2nd_BA44_45_dist_corrected/');
addpath('/projectnb/npbssmic/s/Matlab_code/fitting_code');
cd(dataDir);
missing_files = {};
count = 1;
for n_slice = 1:1:57
    for n_tile = 1:1:25
        filename0=strcat(dataDir,'/fitting/mus_',num2str(n_slice),'_',num2str(n_tile),'.mat');
        if exist(filename0, 'file')
          % File exists
        else
          % File does not exist
          str_nSlice = num2str(n_slice);
          str_nTile = num2str(n_tile);
          SourceFile = dir(strcat(str_nSlice,'-',str_nTile,'-*.dat'));
          DestinyFile = strcat(dataDir,'/data_missing/',SourceFile(1).name);
          copyfile(SourceFile(1).name, DestinyFile, 'f')
          missing_files(count) = {strcat('mus_',str_nSlice,'_',str_nTile,'.mat')};
          count = count + 1;
        end
    end
end