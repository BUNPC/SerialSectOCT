%% Curve fitting - estimate effective Reylaigh range and focus depth
datapath  = strcat('/projectnb/npbssmic/ns/200103_PSOCT_2nd_BA44_45_dist_corrected/');
% add subfunctions for the script
addpath('/projectnb/npbssmic/s/Matlab_code/fitting_code');

% load('/projectnb/npbssmic/s/Matlab_code/Matlab_batch/Zf.mat');
% get the directory of all image tiles
cd(datapath);

filename0=dir(strcat('52-*.dat'));

opts = optimset('Display','off','TolFun',1e-10);

n = 1.35;

z_step=3.5/n/1024*1000;     % z step size in micron
        
njobs=19;

% the $SGE-TASK-ID environment variable read in is CHARACTER, need to transfer to number
id=str2num(id);
nfiles = length(filename0);
nsection = round(nfiles/njobs);

istart = (id - 1) * nsection + 1;
iend = id * nsection;

for iFile=istart:iend
     %% get data information
     %filename0=dir(strcat('1-',num2str(iFile),'*.dat'));
     nk = 108; nxRpt = 1; nx=1060; nyRpt = 1; ny = 1060;
     dim=[nk nxRpt nx nyRpt ny];
     
     ifilePath=[datapath,filename0(iFile).name];
     [slice] = ReadDat_single(ifilePath, dim); 
     
    % load(filename0(iFile).name);  
   
     I=slice;%s./length(filename0); 
     
     % curvature correction
   %  load(strcat(datapath,'/grid/curvature_B.mat'));
   %  I = I(:,111:1210,:);
   %  I = FOV_curvature_correction(I, curvature_B, size(I,1), size(I,2), size(I,3));
    
   % volumetric averaging before fitting
    v=ones(3,3,3)./27;
    I=convn(I,v,'same');

    % FOV curvature correction
    % I=curvature_corr(I);
    
    fit_depth = round(108/3);       % depth want to fit, tunable
    
    info = strsplit(filename0(iFile).name,'-');
    s_seg = str2double(info{1});
    z_seg = str2double(info{2});
        
    % sensitivity roll-off correction
    % w=2.22; % sensitivity roff-off constant, w=2.2 for 5x obj, w=2.22 for 10x obj
    % I=rolloff_corr(I,w);

    % Average attenuation for the full ROI
    mean_I = mean(mean(I,2),3);
    mean_I = mean_I - mean(mean_I(end-19:end));
    
    [m,x]=max(mean_I(31:end));
    x = x + 25;
    if x > 60
        x = 60;
    end
    ydata = double(mean_I(x:x-1+fit_depth)');
    z = x*z_step:z_step:(fit_depth+x-1)*z_step;
    fun = @(p,zdata)sqrt(p(1).*exp(-2.*p(2).*zdata).*(1./(1+((zdata-p(3))./p(4)).^2)));
    lb = [0 0 (x-20)*z_step 0];
    ub = [10000 0.02 (x+100)*z_step 150];
    est = lsqcurvefit(fun,[1000 0.001 x*z_step 80],z,ydata,lb,ub,opts);
    A = fun(est,z);
    %  plotting intial fitting
%     figure
%     plot(z,ydata,'b.')
%     hold on
%     plot(z,A,'r-')
%     xlabel('z (um)')
%     ylabel('I')
%     title('Four parameter fit of averaged data')
%     dim = [0.2 0.2 0.3 0.3];
%     str = {'Estimated values: ',['Relative back scattering: ',num2str(round(est(1)),4)],['Scattering coefficient: ',...
%         num2str(est(2)*1000,4),'mm^-^1'],['Focus depth: ',num2str(est(3),4),'um'],['Rayleigh estimate: ',num2str(round(est(4)),4),'um']};
%     annotation('textbox',dim,'String',str,'FitBoxToText','on');

    %% Curve fitting for the whole image
    %load('Zf.mat');
    res = 10;
    est_pix = zeros(round(size(I,2)/res),round(size(I,3)/res),3);
    
    for i = 1:round(size(I,2)/res)
        for j = 1:round(size(I,3)/res)
            area = I(:,(i-1)*res+1:i*res,(j-1)*res+1:j*res);
            int = squeeze(mean(mean(area,2),3));
            int = double(int - mean(int(end-19:end)));
            [m,xloc]=max(int(31:end));
            xloc = xloc + 25;
            if xloc > 60 %300
                xloc = 60;
            end
            if m > 2
                ydata = double(int(xloc:xloc+fit_depth-1)');
                z = xloc*z_step:z_step:(fit_depth+xloc-1)*z_step;
                fun_pix = @(p,zdata)sqrt(p(1).*exp(-2.*p(2).*zdata).*(1./(1+((zdata-p(3))./est(4)).^2)));
                lb = [0 0 0];
                ub=[10000 0.02 1000];
                est_pix(i,j,:) = lsqcurvefit(fun_pix,[1000 0.001 400],z,ydata,lb,ub,opts);
            else
                est_pix(i,j,:) = [0 0 0];
            end
        end           
    end


    %% visualization & save

    us = 1000.*squeeze(est_pix(:,:,2));     % unit:mm-1
    savename=['mus_',num2str(s_seg),'_',num2str(z_seg)];
    save([datapath, '/fitting/', savename, '.mat'],'us');
    % figure;imagesc(us);

    ub = squeeze(est_pix(:,:,1));
    savename=['mub_',num2str(s_seg),'_',num2str(z_seg)];
    save([datapath, '/fitting/', savename, '.mat'],'ub');

    zf = squeeze(est_pix(:,:,3));
    savename=['zf_',num2str(s_seg),'_',num2str(z_seg)];
    save([datapath, '/fitting/', savename, '.mat'],'zf');
    % figure;imagesc(zf);
    
    %zr = squeeze(est_pix(:,:,4));
    %savename=['zr_',num2str(s_seg),'_',num2str(z_seg)];
    %save([datapath, '/fitting/', savename, '.mat'],'zr');
end
