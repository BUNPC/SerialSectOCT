function Optical_fitting(co, cross, s_seg, z_seg, datapath, threshold, mus_depth, bfg_depth)
% Fitting scattering and retardance of brain tissue
% co: volume data for co pol
% cross: volume data for cross pol
% s_seg: slice number
% Z_seg: tile number
% datapath: datapath for original data

    cd(datapath);
    opts = optimset('Display','off','TolFun',1e-10);
    %opts = optimoptions('lsqcurvefit','Algorithm','levenberg-marquardt', 'FunctionTolerance', 1e-10);
    res = 10;  %A-line averaging factor
    co=imresize3(co,[size(co,1), size(co,2)/res, size(co,3)/res]);
    cross=imresize3(cross, [size(cross,1), size(cross,2)/res, size(cross,3)/res]);
    
    ref=single(sqrt(co.^2+cross.^2));
    % Z step size
    Z_step=3;
    % sensitivity roll-off correction
    % w=2.2; % sensitivity roff-off constant, w=2.2 for 5x obj, w=2.22 for 10x obj
    % I=rolloff_corr(I,w);


%     load(strcat(datapath,'surf/vol',num2str(s_seg),'/',num2str(z_seg),'.mat'));
%     sur=imresize(sur,10/res);
%     surface=my_convn(sur,ones(9,9));
    
    sur=surprofile3(ref,'PSOCT');
    sur=imresize(sur,10/res);
    aip=squeeze(mean(ref,1));
    mask=zeros(size(aip));
    mask(aip>threshold)=1;
    mask2=zeros(size(ref));
    for i=1:size(ref,1)
        mask2(i,:,:)=mask;
    end
    vol=mask2.*ref;

    %% Curve fitting for the whole image
    est_pix = zeros(size(vol,2),size(vol,3),4); 
    R2=zeros(size(vol,2),size(vol,3));
    chi2 = zeros(size(vol,2),size(vol,3));
%     R=0;
    %% fit whole tile and get rayleigh range
%     int = squeeze(mean(mean(vol,2),3));
%     int = (int - mean(int(end-10:end-5)));
%     tmp=imresize(mask,0.1).*sur;
%     xloc=round(mean(tmp(:)))+2;
%     l=min(size(int,1)-5,xloc+fit_depth-1);
%     ydata = double(int(xloc:l)');
%     z = (2:(length(ydata)+1))*Z_step;
%     fun_pix = @(p,zdata)sqrt(p(1).*exp(-2.*p(2).*(zdata)).*(1./(1+((zdata-p(3))./p(4)).^2))); 
% 
%     lb = [0.0001 0.0001  80-30 50];%75-35
%     ub=[10 0.03 80+30 70];%75+35
%     try
%         [est rn] = lsqcurvefit(fun_pix,[0.01 0.006 100 55],z,ydata,lb,ub,opts);
%         R=1-rn/var(ydata)/(length(ydata)-1);
%     catch
%         est = [0 0 0 0];
%     end
%     message=strcat('Tile No. ',string(z_seg),', mus: ',string(est(2)*1000),', mub: ',string(est(1)),', rayleigh: ', string(est(4)),',  zf: ',string(est(3)),', R2: ',string(R),'\n');
%     fprintf(message);
    %% Curve fitting for the whole image

    for i = 1:round(size(vol,2))
        for j = 1:round(size(vol,3))
            int = vol(:,i,j);
            int = int - mean(int(end-10:end-5));
            m=max(int);
            xloc=sur(i,j)+3;
            if m > 0.05
                l=min(size(int,1)-5,xloc+mus_depth-1);
                ydata = double(int(xloc:l)');
                z = (3:(length(ydata)+2))*Z_step;
%                 fun_pix = @(p,zdata)sqrt(p(1).*exp(-2.*p(2).*(zdata)).*(1./(1+((zdata-p(3))./60).^2))); %75; 3-parameter fitting using empirical rayleigh range
                fun_pix = @(p,zdata)sqrt(p(1).*exp(-2.*p(2).*(zdata)).*(1./(1+((zdata-p(3))./(p(4))).^2))); % 4-parameter fitting using tile-dependent zf and rayleigh range from above fitting

                % upper and lower bound for fitting parameters
                lb = [0.0001 0.0001  50-10 50];% 55um is how deep you put the focus bellow surface when imaging, 10um to suppress noise
                ub=[10 0.03 50+10 90];% 
                   y_data(:,i,j) = ydata;
                try
                   [est_pix(i,j,:) rn] = lsqcurvefit(fun_pix,[0.01 0.006 50 70],z,ydata,lb,ub,opts);
                   R2(i,j)=1-rn/var(ydata)/(length(ydata)-1);
                   p = est_pix(i,j,:);
                   y_pred = sqrt(p(1).*exp(-2.*p(2).*(z)).*(1./(1+((z-p(3))./(p(4))).^2)));
                   chi2(i,j) = sum(((ydata-y_pred).^2)/y_pred);
                catch
                    est_pix(i,j,:)=[0 0 0 0];
                end
            else
                est_pix(i,j,:) = [0 0 0 0];
            end
        end           
    end

%     for i =1
%         figure();
%         p = est_pix(5,4,:);
%         zdata = 9:3:3*(130+2);
%         y_pred = sqrt(p(1).*exp(-2.*p(2).*(zdata)).*(1./(1+((zdata-p(3))./(p(4))).^2)));
%         hold on;
%         plot(zdata,y_data(:,5,4));
%         plot(zdata,y_pred);
%     end
   
    figure();
    imagesc(chi2);
    title('\chi2')
    colorbar;
    caxis([0 0.05]);
    
    %% visualization & save
    R2=single(R2);    
    
%     us = single(1000.*squeeze(est_pix(:,:,2)));     % unit:mm-1
%     ub = single(squeeze(est_pix(:,:,1)));
%         figure();
%     imagesc(us);
%     colorbar;
%     title('\mus')
%     caxis([0 20]);
%     
%     figure();
%     imagesc(ub);
%     title('\mub')
%     colorbar;
%     caxis([0 0.2]);
%     
%     figure;
%     imagesc(1-R2);
%     title('1-R2')
%     colorbar;
%     caxis([0 0.05]);
    
    tiffname=strcat(datapath,'fitting/vol',num2str(s_seg),'/','R2.tif');
    if z_seg==1
        t = Tiff(tiffname,'w');
    else
        t = Tiff(tiffname,'a');
    end
    tagstruct.ImageLength     = size(R2,1);
    tagstruct.ImageWidth      = size(R2,2);
    tagstruct.SampleFormat    = Tiff.SampleFormat.IEEEFP;
    tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
    tagstruct.BitsPerSample   = 32;
    tagstruct.SamplesPerPixel = 1;
    tagstruct.Compression     = Tiff.Compression.None;
    tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
    tagstruct.Software        = 'MATLAB';
    t.setTag(tagstruct);
    t.write(R2);
    t.close();
    
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
        
        zr = single(squeeze(est_pix(:,:,4)));
%     savename=strcat('mub-',num2str(s_seg),'-',num2str(z_seg));
%     save([datapath, '/fitting/vol', num2str(s_seg), '/', savename, '.mat'],'ub');
     tiffname=strcat(datapath,'fitting/vol',num2str(s_seg),'/','ZR.tif');
        if z_seg==1
            t = Tiff(tiffname,'w');
        else
            t = Tiff(tiffname,'a');
        end
        tagstruct.ImageLength     = size(zr,1);
        tagstruct.ImageWidth      = size(zr,2);
        tagstruct.SampleFormat    = Tiff.SampleFormat.IEEEFP;
        tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
        tagstruct.BitsPerSample   = 32;
        tagstruct.SamplesPerPixel = 1;
        tagstruct.Compression     = Tiff.Compression.None;
        tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
        tagstruct.Software        = 'MATLAB';
        t.setTag(tagstruct);
        t.write(zr);
        t.close();
    
    %% fitting retardance slope
    ret=single(atan(cross./co));
    vol=ret.*mask2;
    est_pix = zeros(size(vol,2),size(vol,3),2);
    
    for i = 1:size(vol,2)
        for j = 1:size(vol,3)
            int = vol(:,i,j);
            m=max(int);
            xloc=sur(i,j)+5;
            if m > 0.01
                l=min(size(int,1)-5,xloc+bfg_depth-1);
                ydata = double(int(xloc:l)');
                z = (5:(length(ydata)+4))*Z_step;
                fun_pix = @(p,zdata)p(1)/1.3*2*pi*zdata+p(2);
  
                % upper and lower bound for fitting parameters
                lb = [0.000001 0.001];%75-35
                b=[0.01 1];%75+35
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