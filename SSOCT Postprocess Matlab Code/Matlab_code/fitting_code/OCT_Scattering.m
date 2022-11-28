%% Curve fitting - estimate effective Reylaigh range and focus depth
clear all;
datapath  = strcat('/projectnb/npbssmic/ns/220505_P3/NIR_OCT/500_tissue/');

% add subfunctions for the script
addpath('/projectnb/npbssmic/s/Matlab_code/fitting_code');
addpath('/projectnb/npbssmic/s/Matlab_code/ThorOCT_code');

% load('/projectnb/npbssmic/s/Matlab_code/Matlab_batch/Zf.mat');
% get the directory of all image tiles
cd(datapath);

filename0=dir(strcat('RAW-*-2.dat'));

opts = optimset('Display','off','TolFun',1e-10);

n = 1.35;
z_step=3.5/n/1024*1000;     % z step size in micron

% load data
nk = 2048; nxRpt = 1; nx=400; nyRpt = 1; ny = 400;
dim=[nk nxRpt nx nyRpt ny];

slice = zeros(600,400,400);
for i=1:length(filename0)
 ifilePath=[datapath,filename0(i).name];
 data_ori = ReadDat_int16(ifilePath, dim); 
 data=Dat2RR(data_ori,-0.235);
 slice=slice+abs(data(1:600,:,:));
end

I=slice/length(filename0);
aip=squeeze(mean(I,1));
MAT2TIFF(single(aip),'aip.tif');
    
% volumetric averaging before fitting
v=ones(3,3,3)./27;
I=convn(I,v,'same');

fit_depth = round(180/3);       % depth want to fit, tunable
% Average attenuation for the full ROI
 mean_I = mean(mean(I,2),3);
figure;imagesc(squeeze(I(:,200,:)));colormap gray;caxis([0 1]);
% mean_I = mean_I - mean(mean_I(end-19:end));

%%
% [m,x]=max(mean_I(121:200));
% x = x + 120;
% ydata = double(mean_I(x:x-1+fit_depth)');
% z = x*z_step:z_step:(fit_depth+x-1)*z_step;
% fun = @(p,zdata)sqrt(p(1).*exp(-2.*p(2).*zdata).*(1./(1+((zdata-p(3))./p(4)).^2)));
% lb = [0 0 (x-20)*z_step 10];
% ub = [10000 0.02 (x+100)*z_step 150];
% est = lsqcurvefit(fun,[1000 0.001 x*z_step 40],z,ydata,lb,ub,opts);
% A = fun(est,z);
% % plotting intial fitting
% figure
% plot(z,ydata,'b.')
% hold on
% plot(z,A,'r-')
% xlabel('z (um)')
% ylabel('I')
% title('Four parameter fit of averaged data')
% dim = [0.2 0.2 0.3 0.3];
% str = {'Estimated values: ',['Relative back scattering: ',num2str(round(est(1)),4)],['Scattering coefficient: ',...
%     num2str(est(2)*1000,4),'mm^-^1'],['Focus depth: ',num2str(est(3),4),'um'],['Rayleigh estimate: ',num2str(round(est(4)),4),'um']};
% annotation('textbox',dim,'String',str,'FitBoxToText','on');

    %% Curve fitting for the whole image

    res = 10;
    
    est2 = zeros(round(size(I,2)/res),round(size(I,3)/res),2);

    for i = 1:round(size(I,2)/res)
        for j = 1:round(size(I,3)/res)
            
            area = I(:,(i-1)*res+1:i*res,(j-1)*res+1:j*res);
            int = squeeze(mean(mean(area,2),3));
            int = double(int);
            
            % surface finding
            
            [m,xloc]=max(int(351:450));
            
            if m > 0.15
                xloc= 350;
                ydata = double(int(xloc:xloc+fit_depth-1)');
                z = xloc*z_step:z_step:(fit_depth+xloc-1)*z_step;
                fun_pix = @(p,zdata)sqrt(p(1).*exp(-2.*p(2).*zdata));
                lb = [0 0];
                ub=[10000 0.05];
                est2(i,j,:) = lsqcurvefit(fun_pix,[100 0.005],z,ydata,lb,ub,opts);
%                 fun_pix = @(p,zdata)sqrt(p(1).*exp(-2.*p(2).*zdata).*(1./(1+((zdata-p(3))./est(4)).^2)));
%                 lb = [0 0 (xloc-25)*z_step];
%                 ub=[100000 0.02 (xloc+50)*z_step];
%                 [est_pix(i,j,:), rn]= lsqcurvefit(fun_pix,[1000 0.001 xloc*z_step],z,ydata,lb,ub,opts);
%                 R2=1-rn/var(ydata)/(length(ydata)-1);     
                if (i==20 && j==19)
                    % plotting intial fitting
                    figure;
                    plot(z,ydata,'b.');
                    hold on;
                    A=fun_pix(squeeze(est2(i,j,:)),z);
                    plot(z,A,'r-')
                    xlabel('z (um)')
                    ylabel('I')
                    title('Linear fit of exponential data')
                    dim = [0.2 0.2 0.3 0.3];
                end             
            else
                est2(i,j,:)=[0 0];
            end
            

            
        end
        
        disp(['No. ',num2str(i),' B scan has been processed.']);
        
    end
    
%     % visualization & save    
     us = 1000.*squeeze(est2(:,:,2));     % unit:mm-1
     figure;imagesc(us); colormap gray;
     us=single(us);
     MAT2TIFF(us,'mus.tif');