dataDir  = strcat('/projectnb/npbssmic/ns/200103_PSOCT_2nd_BA44_45_dist_corrected/');
addpath('/projectnb/npbssmic/s/Matlab_code/fitting_code');
cd(dataDir);
missing_files = {};
count = 1;
for n_slice = 1:1:57
    for n_tile = 1:1:25
        filename0=strcat(dataDir,'/fitting/mus_',num2str(n_slice),'_',num2str(n_tile),'.mat');
        fileName = strcat('mus-',num2str(n_slice),'-',num2str(n_tile),'.mat');
        if exist(filename0, 'file')
%             n_slice = num2str(n_slice);
%             n_tile = num2str(n_tile);
%             filename0=dir(strcat(n_slice,'-',n_tile,'-*.dat'));
%             load(strcat('fitting/mus_',n_slice,'_',n_tile,'.mat'));
%             addpath('fitting_code');
%             figure;
%             subplot(1,2,1)
%             imagesc(us);
%             colormap(gray);
%             axis image;
%             title(fileName);
% 
%             nk = 108; nxRpt = 1; nx=1060; nyRpt = 1; ny = 1060;
%             dim=[nk nxRpt nx nyRpt ny];
%             ifilePath=[filename0(1).name];
%             [slice] = ReadDat_single(ifilePath, dim); 
%             subplot(1,2,2)
%             im_ave = mean(slice);
%             im = squeeze(im_ave);
%             imagesc(im);
%             colormap(gray);
%             axis image;
%             title(filename0(1).name);
        else
          % File does not exist
          missing_files(count) = {fileName};
          count = count + 1;
        end
    end
end

 