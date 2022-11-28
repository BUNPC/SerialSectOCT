function Optical_fitting_6692_fix_rayleigh(co, cross, s_seg, z_seg, datapath)
% Fitting scattering and retardance of brain tissue
% co: volume data for co pol
% cross: volume data for cross pol
% s_seg: slice number
% Z_seg: tile number
% datapath: datapath for original data

    cd(datapath);
    opts = optimset('Display','off','TolFun',1e-10);
    % depth to fit, tunable
    ref=single(sqrt(co.^2+cross.^2));
    % Z step size
    Z_step=3;
    % sensitivity roll-off correction
    % w=2.2; % sensitivity roff-off constant, w=2.2 for 5x obj, w=2.22 for 10x obj
    % I=rolloff_corr(I,w);

    sur=surprofile2(ref,'PSOCT');
    aip=squeeze(mean(ref,1));
    mask=zeros(size(aip));
    mask(aip>0.02)=1;
    mask2=zeros(size(ref));
    for i=1:size(ref,1)
        mask2(i,:,:)=mask;
    end
    vol=mask2.*ref;
    
    fit_depth = round(150); 
    res = 10;  %A-line averaging factor
    est_pix = zeros(round(size(vol,2)/res),round(size(vol,3)/res),3); 
    %% fit whole tile and get rayleigh range
    int = squeeze(mean(mean(vol,2),3));
    int = (int - mean(int(end-10:end-5)));
    tmp=imresize(mask,0.1).*sur;
    xloc=round(mean(tmp(:)))+2;
    l=min(size(int,1)-5,xloc+fit_depth-1);
    ydata = double(int(xloc:l)');
    z = (2:(length(ydata)+1))*Z_step;
    fun_pix = @(p,zdata)sqrt(p(1).*exp(-2.*p(2).*(zdata)).*(1./(1+((zdata-p(3))./p(4)).^2))); 

    lb = [0.001 0.0001  80-55 30];%75-35
    ub=[10 0.03 80+55 200];%75+35
    try
        est = lsqcurvefit(fun_pix,[0.01 0.006 100 70],z,ydata,lb,ub,opts);
    catch
        est = [0 0 0 0];
    end
    message=strcat('Tile No. ',string(z_seg),', rayleigh: ', string(est(4)),',  zf: ',string(est(3)),'\n');
%     fprintf(message);
    %% Curve fitting for the whole image
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
                fun_pix = @(p,zdata)sqrt(p(1).*exp(-2.*p(2).*(zdata)).*(1./(1+((zdata-p(3))./(80)).^2))); %75; 3-parameter fitting using empirical rayleigh range
    %             fun_pix = @(p,zdata)sqrt(p(1).*exp(-2.*p(2).*(zdata)).*(1./(1+((zdata-est(3))./(est(4))).^2))); % 2-parameter fitting using tile-dependent zf and rayleigh range from above fitting

                % upper and lower bound for fitting parameters
                lb = [0.001 0.0001  80-55];%75-35
                ub=[10 0.03 80+55];%75+35
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
    us = single(1000.*squeeze(est_pix(:,:,2)));     % unit:mm-1
%     savename=strcat('mus-',num2str(s_seg),'-',num2str(z_seg));
%     save([datapath, '/fitting/vol', num2str(s_seg),'/',savename, '.mat'],'us');
    tiffname=strcat(datapath,'fitting/vol',num2str(s_seg),'/','MUS.tif');
        if z_seg==1
            t = Tiff(tiffname,'w');
        else
            t = Tiff(tiffname,'a');
        end
        tagstruct.ImageLength     = size(us,1);
        tagstruct.ImageWidth      = size(us,2);
        tagstruct.SampleFormat    = Tiff.SampleFormat.IEEEFP;
        tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
        tagstruct.BitsPerSample   = 32;
        tagstruct.SamplesPerPixel = 1;
        tagstruct.Compression     = Tiff.Compression.None;
        tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
        tagstruct.Software        = 'MATLAB';
        t.setTag(tagstruct);
        t.write(us);
        t.close();
        
    ub = single(squeeze(est_pix(:,:,1)));
%     savename=strcat('mub-',num2str(s_seg),'-',num2str(z_seg));
%     save([datapath, '/fitting/vol', num2str(s_seg), '/', savename, '.mat'],'ub');
     tiffname=strcat(datapath,'fitting/vol',num2str(s_seg),'/','MUB.tif');
        if z_seg==1
            t = Tiff(tiffname,'w');
        else
            t = Tiff(tiffname,'a');
        end
        tagstruct.ImageLength     = size(ub,1);
        tagstruct.ImageWidth      = size(ub,2);
        tagstruct.SampleFormat    = Tiff.SampleFormat.IEEEFP;
        tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
        tagstruct.BitsPerSample   = 32;
        tagstruct.SamplesPerPixel = 1;
        tagstruct.Compression     = Tiff.Compression.None;
        tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
        tagstruct.Software        = 'MATLAB';
        t.setTag(tagstruct);
        t.write(ub);
        t.close();
    
     zf = single(squeeze(est_pix(:,:,3)));
%     savename=strcat('mub-',num2str(s_seg),'-',num2str(z_seg));
%     save([datapath, '/fitting/vol', num2str(s_seg), '/', savename, '.mat'],'ub');
     tiffname=strcat(datapath,'fitting/vol',num2str(s_seg),'/','ZF.tif');
        if z_seg==1
            t = Tiff(tiffname,'w');
        else
            t = Tiff(tiffname,'a');
        end
        tagstruct.ImageLength     = size(zf,1);
        tagstruct.ImageWidth      = size(zf,2);
        tagstruct.SampleFormat    = Tiff.SampleFormat.IEEEFP;
        tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
        tagstruct.BitsPerSample   = 32;
        tagstruct.SamplesPerPixel = 1;
        tagstruct.Compression     = Tiff.Compression.None;
        tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
        tagstruct.Software        = 'MATLAB';
        t.setTag(tagstruct);
        t.write(zf);
        t.close();
    %% fitting retardance slope
%     fit_depth = round(100); 
% %     v=ones(3,3)./9;
% %     cross=convn(cross,v,'same');
% %     co=convn(co,v,'same');
%     ret=single(atan(cross./co.*1.3));
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
%     save([datapath, '/fitting/vol', num2str(s_seg),'/',savename, '.mat'],'bkg');