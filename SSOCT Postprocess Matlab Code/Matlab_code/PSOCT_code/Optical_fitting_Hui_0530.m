function Optical_fitting_Hui_0530(ref, s_seg, z_seg, datapath)
% Fitting scattering and retardance of brain tissue
% co: volume data for co pol
% cross: volume data for cross pol
% s_seg: slice number
% Z_seg: tile number
% datapath: datapath for original data

    cd(datapath);
    opts = optimset('Display','off','TolFun',1e-10);
    % depth to fit, tunable
    % Z step size
    Z_step=2.6;
    % sensitivity roll-off correction
    w=2.2; % sensitivity roff-off constant, w=2.2 for 5x obj, w=2.22 for 10x obj
    ref=rolloff_corr(ref,w);

    sur=surprofile2(ref,'Thorlabs');
    aip=squeeze(mean(ref,1));
    mask=zeros(size(aip));
    mask(aip>50)=1;
    mask2=zeros(size(ref));
    for i=1:size(ref,1)
        mask2(i,:,:)=mask;
    end
    vol=mask2.*ref./1000;

    %% Curve fitting for the whole image
    fit_depth = round(200); 
    res = 10;  %A-line averaging factor
    est_pix = zeros(round(size(vol,2)/res),round(size(vol,3)/res),4);
    tmp=round(imresize(sur,0.2));
    for i = 1:round(size(vol,2)/res)
        for j = 1:round(size(vol,3)/res)
            area = vol(:,(i-1)*res+1:i*res,(j-1)*res+1:j*res);
            int = squeeze(mean(mean(area,2),3));
%             int = (int - mean(int(1:5)));
            m=max(int);
%             xloc=round(tmp(:))+2;
            xloc=tmp(ceil(i/50*res),ceil(j/50*res))+2;
%             xloc=sur(ceil(i/10*res),ceil(j/10*res))+2;
            if m > 0.05
                l=min(size(int,1)-5,xloc+fit_depth-1);
                ydata = double(int(xloc:l)');
                z = (1:(length(ydata)))*Z_step;
                fun_pix = @(p,zdata)sqrt(p(1).*exp(-2.*p(2).*(zdata)).*(1./(1+((zdata-p(3))./50).^2))) +p(4); %75; 3-parameter fitting using empirical rayleigh range
    %             fun_pix = @(p,zdata)sqrt(p(1).*exp(-2.*p(2).*(zdata)).*(1./(1+((zdata-est(3))./(est(4))).^2))); % 2-parameter fitting using tile-dependent zf and rayleigh range from above fitting

                % upper and lower bound for fitting parameters
                lb = [0.1 0.0001 30 0.01];%75-35
                ub=[50 0.03  200 1];%75+35
                try
                   est_pix(i,j,:) = lsqcurvefit(fun_pix,[15 0.003 50 0.05],z,ydata,lb,ub,opts);
                catch
                    est_pix(i,j,:)=[0 0 0 0];
                end
            else
                est_pix(i,j,:) = [0 0 0 0];
            end
        end           
    end
    
    %% visualization & save
    us = single(1000.*squeeze(est_pix(:,:,2)));     % unit:mm-1
    savename=strcat('mus-',num2str(s_seg),'-',num2str(z_seg));
    save([datapath, '/fitting/vol', num2str(s_seg),'/',savename, '.mat'],'us');
%     tiffname=strcat(datapath,'fitting/vol',num2str(s_seg),'/','MUS.tif');
%         if str2num(z_seg)==1
%             t = Tiff(tiffname,'w');
%         else
%             t = Tiff(tiffname,'a');
%         end
%         tagstruct.ImageLength     = size(us,1);
%         tagstruct.ImageWidth      = size(us,2);
%         tagstruct.SampleFormat    = Tiff.SampleFormat.IEEEFP;
%         tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
%         tagstruct.BitsPerSample   = 32;
%         tagstruct.SamplesPerPixel = 1;
%         tagstruct.Compression     = Tiff.Compression.None;
%         tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
%         tagstruct.Software        = 'MATLAB';
%         t.setTag(tagstruct);
%         t.write(us);
%         t.close();
        
    ub = single(squeeze(est_pix(:,:,1)));
    savename=strcat('mub-',num2str(s_seg),'-',num2str(z_seg));
    save([datapath, '/fitting/vol', num2str(s_seg), '/', savename, '.mat'],'ub');
%      tiffname=strcat(datapath,'fitting/vol',num2str(s_seg),'/','MUB.tif');
%         if str2num(z_seg)==1
%             t = Tiff(tiffname,'w');
%         else
%             t = Tiff(tiffname,'a');
%         end
%         tagstruct.ImageLength     = size(ub,1);
%         tagstruct.ImageWidth      = size(ub,2);
%         tagstruct.SampleFormat    = Tiff.SampleFormat.IEEEFP;
%         tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
%         tagstruct.BitsPerSample   = 32;
%         tagstruct.SamplesPerPixel = 1;
%         tagstruct.Compression     = Tiff.Compression.None;
%         tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
%         tagstruct.Software        = 'MATLAB';
%         t.setTag(tagstruct);
%         t.write(ub);
%         t.close();
    
    %% fitting retardance slope
%     fit_depth = round(100); 
%     v=ones(3,3)./9;
%     cross=convn(cross,v,'same');
%     co=convn(co,v,'same');
%     ret=single(atan(cross./co));
%     vol=ret.*mask2;
%     est_pix = zeros(round(size(vol,2)/res),round(size(vol,3)/res),2);
%     
%     for i = 1:round(size(vol,2)/res)
%         for j = 1:round(size(vol,3)/res)
%             area = vol(:,(i-1)*res+1:i*res,(j-1)*res+1:j*res);
%             int = squeeze(mean(mean(area,2),3));
% %             int = (int - mean(int(end-10:end-5)));
%             m=max(int);
%             xloc=sur(ceil(i/10*res),ceil(j/10*res))+2;
%             if m > 0.01
%                 l=min(size(int,1)-5,xloc+fit_depth-1);
%                 ydata = double(int(xloc:l)');
%                 z = (2:(length(ydata)+1))*Z_step;
%                 fun_pix = @(p,zdata)p(1)/1.3*2*pi*zdata+p(2);
%   
%                 % upper and lower bound for fitting parameters
%                 lb = [0.000001 0.001];%75-35
%                 b=[0.01 1];%75+35
%                 try
%                    est_pix(i,j,:) = lsqcurvefit(fun_pix,[0.0002 0.05],z,ydata,lb,b,opts);
%                 catch
%                     est_pix(i,j,:)=[0 0];
%                 end
%             else
%                 est_pix(i,j,:) = [0 0];
%             end
%         end           
%     end
% 
% 
%     %% visualization & save
% 
%     bfg = squeeze(est_pix(:,:,1));     % unit:mm-1
%     savename=strcat('bfg-',num2str(s_seg),'-',num2str(z_seg));%['mus_',num2str(s_seg),'_',num2str(z_seg)];
%     save([datapath, '/fitting/vol', num2str(s_seg),'/',savename, '.mat'],'bfg');
% 
%     bkg = squeeze(est_pix(:,:,2));
%     savename=strcat('bkg-',num2str(s_seg),'-',num2str(z_seg));%['mub_',num2str(s_seg),'_',num2str(z_seg)];
%     save([datapath, '/fitting/vol