function Optical_fitting_MGH(I, s_seg, z_seg, datapath, zf)
% Fitting code for the data shared by Hui. 
% I: volume data for 1 tile
% s_seg: slice number,for initial test, just use arbitrary number like 1
% Z_seg: tile numberfor initial test, just use arbitrary number like 1
% datapath: datapath for original data
% zf: focus depth matrix, X*Y dimension, for initial test, just use
% arbitrary number like 1

cd(datapath);
opts = optimset('Display','off','TolFun',1e-10); % convergence tolerence
v=ones(3,3,3)./27;  % local averaging to make the results more stable
I=convn(I,v,'same');
I=flip(I,3);  % flip the z axis
I=10.^(I./20)./140; % convert to linear scale
% depth to fit, tunable
fit_depth = round(150); 
% Z step size
Z_step=3; %change this after asking hui
% sensitivity roll-off correction
w=2.2; % sensitivity roff-off constant, w=2.2 for 5x obj, w=2.22 for 10x obj
I=rolloff_corr(I,w);

% the following indent lines are trying to find Z start pixel for fitting for
% unflat cut. The start pixel is defined by the average height of tissue
% surface. 
%     sur=surprofile2(I,'PSOCT');
%     aip=squeeze(mean(I,1));
%     aip=My_downsample(aip);
%     mask=zeros(size(aip));
%     mask(aip>0.045)=1;
%     z0=round(mean(mean(sur(mask==1))));
%     if isnan(z0)
%         z0=32;
%     end 
%     if z0>55
%         z0=55;
%     elseif z0<36
%             z0=36;
%     end
% for flat cut, define a constant depth as start of fitting
z0=1; % same value for all tiles, all slices
% cut out the signal above start depth
d=min(fit_depth+z0-1,size(I,3));
I=I(:,:,z0:d);

% correct focus depth accordingly, if there is a focus depth variation
% zf=zf-z0;
% zf=zf.*Z_step;

% The following indent lines average the whole tile and do a fitting, the purpose here is to find the
% average rayleigh range
%
% Or you can use a constant rayleigh range for all tiles

%     mask2=zeros(size(I));
%     for i=1:size(I,1)
%         mask2(i,:,:)=mask;
%     end
%     k=mask2.*I;
    % Average attenuation for the full ROI
    mean_I = squeeze(mean(mean(I,1),2));
    mean_I = mean_I - mean(mean_I(end-5:end));
    % mean_I=flip(mean_I);
    [m,x]=max(mean_I);
%     v1=mean(mean_I(1:x));
%     v2=m-(m-v1)/3;
%     x=Find_start_point(mean_I(1:x),v2);
    x=10;
%     x=max(5,x-);
%     if x>100
%         x=100;
%     elseif x<20
%         x=20;
%     end
%     x=24;
    ydata = double(mean_I(x:end-5)');
    z = (x:(length(ydata)+x-1))*Z_step;
    fun = @(p,zdata)sqrt(p(1).*exp(-2.*p(2).*zdata).*(1./(1+((zdata-p(3))./p(4)).^2)));
    lb = [1 0.0001 2*Z_step 60]; %ask Hui what is the expected rayleigh range
    ub = [300 0.03 80*Z_step 150];
    est = lsqcurvefit(fun,[10 0.01 20*Z_step 80],z,ydata,lb,ub,opts);
     A = fun(est,z);
      % plotting intial fitting
        figure
        plot(z,ydata,'b.')
        hold on
        plot(z,A,'r-')
        xlabel('z (um)')
        ylabel('I')
        title('Four parameter fit of averaged data')
        dim = [0.2 0.2 0.3 0.3];
        str = {'Estimated values: ',['Relative back scattering: ',num2str(est(1),4)],['Scattering coefficient: ',...
            num2str(est(2)*1000,4),'mm^-^1'],['Focus depth: ',num2str(est(3),4),'um'],['Rayleigh estimate: ',num2str(round(est(4)),4),'um']};
        annotation('textbox',dim,'String',str,'FitBoxToText','on');

    %% Curve fitting for the whole image
    res = 5;  %A-line averaging factor, 5 means 10x10 averaging
    est_pix = zeros(round(size(I,2)/res-1),round(size(I,3)/res-1),3);
    
    for i = 1:round(size(I,1)/res)
        for j = 1:round(size(I,2)/res)
            imin=min((i+1)*res,size(I,1));
            jmin=min((j+1)*res,size(I,2));
            area = I((i-1)*res+1:imin,(j-1)*res+1:jmin,:);
            int = squeeze(mean(mean(area,1),2));
            int = (int - mean(int(end-5:end)));
%             xloc=findchangepts(int);
            m=max(int);
            xloc=10;   % empirical start point of fitting is good enough for flat slice
            if m > 1 % change this threshold to avoid fitting agar and save some time
                l=min(size(int,1),xloc+fit_depth-1);
                ydata = double(int(xloc:l)');
                z = (xloc:(length(ydata)+xloc-1))*Z_step;
                fun_pix = @(p,zdata)sqrt(p(1).*exp(-2.*p(2).*(zdata)).*(1./(1+((zdata-p(3))./(est(4))).^2))); % 3-parameter fitting using empirical rayleigh range
    %             fun_pix = @(p,zdata)sqrt(p(1).*exp(-2.*p(2).*(zdata)).*(1./(1+((zdata-est(3))./(est(4))).^2))); % 2-parameter fitting using tile-dependent zf and rayleigh range from above fitting

                % upper and lower bound for fitting parameters
                lb = [1 0.0001  100];
                ub=[300 0.03 200];
                est_pix(i,j,:) = lsqcurvefit(fun_pix,[0.001 0.004 100],z,ydata,lb,ub,opts);
            else
                est_pix(i,j,:) = [0 0 0];
            end
        end           
    end


    %% visualization & save
    mkdir(strcat(datapath, '/fitting','/'));
    mkdir(strcat(datapath, '/fitting/vol', num2str(s_seg),'/'));
    us = 1000.*squeeze(est_pix(:,:,2));     % unit:mm-1
    savename=strcat('mus-',num2str(s_seg),'-',num2str(z_seg));%['mus_',num2str(s_seg),'_',num2str(z_seg)];
    save([datapath, '/fitting/vol', num2str(s_seg),'/',savename, '.mat'],'us');

    ub = squeeze(est_pix(:,:,1));
    savename=strcat('mub-',num2str(s_seg),'-',num2str(z_seg));%['mub_',num2str(s_seg),'_',num2str(z_seg)];
    save([datapath, '/fitting/vol', num2str(s_seg), '/', savename, '.mat'],'ub');