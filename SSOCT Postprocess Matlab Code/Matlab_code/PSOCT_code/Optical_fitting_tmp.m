function Optical_fitting_tmp(ref, ret, s_seg, z_seg, datapath)
% Fitting scattering and retardance of brain tissue
% co: volume data for co pol
% cross: volume data for cross pol
% s_seg: slice number
% Z_seg: tile number
% datapath: datapath for original data

    cd(datapath);
    opts = optimset('Display','off','TolFun',1e-10);
    % depth to fit, tunable
%     ref=single(sqrt(co.^2+cross.^2));
    % Z step size
    Z_step=3;
    % sensitivity roll-off correction
    % w=2.2; % sensitivity roff-off constant, w=2.2 for 5x obj, w=2.22 for 10x obj
    % I=rolloff_corr(I,w);

    % the following indent lines are trying to find Z start pixel for fitting for
    % unflat cut.
    sur=surprofile2(ref,'PSOCT');
    aip=squeeze(mean(ref,1));

    mask=zeros(size(aip));
    mask(aip>0.055)=1;

    mask2=zeros(size(ref));
    for i=1:size(ref,1)
        mask2(i,:,:)=mask;
    end
    vol=mask2.*ref;

    %% Curve fitting for the whole image
    fit_depth = round(150); 
    res = 4;  %A-line averaging factor
    est_pix = zeros(round(size(vol,2)/res),round(size(vol,3)/res),3);
    
    for i = 1:round(size(vol,2)/res)
        for j = 1:round(size(vol,3)/res)
            area = vol(:,(i-1)*res+1:i*res,(j-1)*res+1:j*res);
            int = squeeze(mean(mean(area,2),3));
            int = (int - mean(int(end-10:end-5)));
            m=max(int);
            xloc=sur(ceil(i/10*res),ceil(j/10*res))+2;
            if m > 0.05
                l=min(size(int,1)-5,xloc+fit_depth-1);
                ydata = double(int(xloc:l)');
                z = (2:(length(ydata)+1))*Z_step;
                fun_pix = @(p,zdata)sqrt(p(1).*exp(-2.*p(2).*(zdata)).*(1./(1+((zdata-p(3))./(122)).^2))); %75; 3-parameter fitting using empirical rayleigh range
    %             fun_pix = @(p,zdata)sqrt(p(1).*exp(-2.*p(2).*(zdata)).*(1./(1+((zdata-est(3))./(est(4))).^2))); % 2-parameter fitting using tile-dependent zf and rayleigh range from above fitting

                % upper and lower bound for fitting parameters
                lb = [0.001 0.0001  80-35];%75-35
                ub=[10 0.03 80+35];%75+35
                try
                   est_pix(i,j,:) = lsqcurvefit(fun_pix,[0.01 0.006 110],z,ydata,lb,ub,opts);
                catch
                    est_pix(i,j,:)=[0 0 0];
                end
            else
                est_pix(i,j,:) = [0 0 0];
            end
        end           
    end


    %% visualization & save

    us = 1000.*squeeze(est_pix(:,:,2));     % unit:mm-1
    savename=strcat('mus-',num2str(s_seg),'-',num2str(z_seg));%['mus_',num2str(s_seg),'_',num2str(z_seg)];
    save([datapath, '/fitting/vol', num2str(s_seg),'/',savename, '.mat'],'us');

    ub = squeeze(est_pix(:,:,1));
    savename=strcat('mub-',num2str(s_seg),'-',num2str(z_seg));%['mub_',num2str(s_seg),'_',num2str(z_seg)];
    save([datapath, '/fitting/vol', num2str(s_seg), '/', savename, '.mat'],'ub');
    
    
    %% fitting retardance slope
    fit_depth = round(25); 
        Z_step=12;
    mask2=zeros(size(ret));
    for i=1:size(ret,1)
        mask2(i,:,:)=mask;
    end
    vol=ret.*mask2;
    est_pix = zeros(round(size(vol,2)/res),round(size(vol,3)/res),2);
    
    for i = 1:round(size(vol,2)/res)
        for j = 1:round(size(vol,3)/res)
            area = vol(:,(i-1)*res+1:i*res,(j-1)*res+1:j*res);
            int = squeeze(mean(mean(area,2),3));
%             int = (int - mean(int(end-10:end-5)));
            m=max(int);
            xloc=ceil((sur(ceil(i/10*res),ceil(j/10*res)))/4)+2;
            if m > 0.01
                l=min(size(int,1)-5,xloc+fit_depth-1);
                ydata = double(int(xloc:l)');
                z = (2:(length(ydata)+1))*Z_step;
                fun_pix = @(p,zdata)p(1)/1.3*2*pi*zdata+p(2);
  
                % upper and lower bound for fitting parameters
                lb = [0.000001 0.001];%75-35
                b=[0.2 1];%75+35
                try
                   est_pix(i,j,:) = lsqcurvefit(fun_pix,[0.0002 0.05],z,ydata,lb,b,opts);
                catch
                    est_pix(i,j,:)=[0 0];
                end
            else
                est_pix(i,j,:) = [0 0];
            end
        end           
    end


    %% visualization & save

    bfg = squeeze(est_pix(:,:,1));     % unit:mm-1
    savename=strcat('bfg-',num2str(s_seg),'-',num2str(z_seg));%['mus_',num2str(s_seg),'_',num2str(z_seg)];
    save([datapath, '/fitting/vol', num2str(s_seg),'/',savename, '.mat'],'bfg');

    bkg = squeeze(est_pix(:,:,2));
    savename=strcat('bkg-',num2str(s_seg),'-',num2str(z_seg));%['mub_',num2str(s_seg),'_',num2str(z_seg)];
    save([datapath, '/fitting/vol', num2str(s_seg),'/',savename, '.mat'],'bkg');