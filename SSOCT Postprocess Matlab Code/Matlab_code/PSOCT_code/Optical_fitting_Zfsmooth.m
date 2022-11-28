function Optical_fitting_Zfsmooth(co, cross, s_seg, z_seg, datapath,threshold, mus_depth, bfg_depth, ds_factor)
% Fitting scattering and retardance of brain tissue
% co: volume data for co pol
% cross: volume data for cross pol
% s_seg: slice number
% Z_seg: tile number
% datapath: datapath for original data
    sur=surprofile2(co,'PSOCT');
%     for i=1:size(sur,1)
%         for j=1:size(sur,2)
%             if sur(i,j)<mean2(sur)-std2(sur) || sur(i,j)>mean2(sur)+std2(sur)
%                 sur(i,j)=round(mean2(sur));
%             end
%         end
%     end
    cd(datapath);
    opts = optimset('Display','off','TolFun',1e-10);
    res = ds_factor;  %A-line averaging factor
    co=imresize3(co,[size(co,1), size(co,2)/res, size(co,3)/res]);
    cross=imresize3(cross, [size(cross,1), size(cross,2)/res, size(cross,3)/res]);
    
    ref=single(sqrt(co.^2+cross.^2));
    % Z step size
    Z_step=3;
    % sensitivity roll-off correction
    % w=2.2; % sensitivity roff-off constant, w=2.2 for 5x obj, w=2.22 for 10x obj
    % I=rolloff_corr(I,w);

%     % calculate average surface
%     load(strcat(datapath,'aip/aip',num2str(s_seg),'.mat'));
%     aip=imresize(aip,1/res);
%     
%     surfAll = single(imread(strcat(datapath,'surf/sur',num2str(s_seg),'.tif'), 1));
%     aipSize=size(aip);
%     surfSize=size(surfAll);
%     maskAll=zeros(min(aipSize(1),surfSize(1)),min(aipSize(2),surfSize(2)));
%     maskAll(aip(1:min(aipSize(1),surfSize(1)),1:min(aipSize(2),surfSize(2)))>0.1)=1;
%     tmp=maskAll.*surfAll(1:min(aipSize(1),surfSize(1)),1:min(aipSize(2),surfSize(2)));
%     surfAvg=mean2(tmp(tmp>1));
    
    aip=squeeze(mean(ref,1));
    mask=zeros(size(aip));
    mask(aip>threshold)=1;
    mask2=zeros(size(ref));
    for i=1:size(ref,1)
        mask2(i,:,:)=mask;
    end
    vol=mask2.*ref;

    %% Curve fitting for the whole image
    est_pix = zeros(size(vol,2),size(vol,3),3); 
    R2=zeros(size(vol,2),size(vol,3));
    %% fit whole tile and get rayleigh range
%     R=0;
%     int = squeeze(mean(mean(vol,2),3));
%     int = (int - mean(int(end-20:end-5)));
%     tmp=mask.*sur;
%     xloc=round(mean(tmp(:)))+2;
%     l=min(size(int,1)-5,xloc+mus_depth-1);
%     ydata = double(int(xloc:l)');
%     z = (2:(length(ydata)+1))*Z_step;
%     fun_pix = @(p,zdata)sqrt(p(1).*exp(-2.*p(2).*(zdata)).*(1./(1+((zdata-p(3))./60).^2))); 
% 
%     lb = [0.0001 0.0001  60-30];%75-35
%     ub=[100 0.03 180+30];%75+35
%     try
%         [est rn] = lsqcurvefit(fun_pix,[0.01 0.006 100],z,ydata,lb,ub,opts);
%         R=1-rn/var(ydata)/(length(ydata)-1);
%     catch
%         est = [0 0 0];
%     end
% %     message=strcat('Tile No. ',string(z_seg),', mus: ',string(est(2)*1000),', mub: ',string(est(1)),', rayleigh: ', string(est(4)),',  zf: ',string(est(3)),', R2: ',string(R),'\n');
% %     fprintf(message);
    %% Prefit with 2 parameters, fixed zf and zr in grey matter
    for i = 1:round(size(vol,2))
        for j = 1:round(size(vol,3))
            int = vol(:,i,j);
            int = int - mean(int(10:20));
            m=max(int);
            xloc=sur(ceil(i/size(vol,2)*size(sur,1)),ceil(j/size(vol,3)*size(sur,2)))+2;
            l=min(length(int)-5,xloc+mus_depth-1);
            if m > 0.05
                ydata = double(int(xloc:l)');
                z = (2:length(ydata)+1)*Z_step;
                % find peak depth
                ydatasm=my_smooth_1D(ydata,50);
                [~,est_pix(i,j,3)]=max(ydatasm);
                est_pix(i,j,3)=est_pix(i,j,3)+5;
                
                fun_pix = @(p,zdata)sqrt(p(1).*exp(-2.*p(2).*(zdata)).*...
                    (1./(1+((zdata-est_pix(i,j,3)*Z_step)./65).^2))); %75; 3-parameter fitting using empirical rayleigh range
                lb = [0.0001 0.0001 ];
                ub=[10 0.03 ];
                try
                   [est_pix(i,j,1:2), rn] = lsqcurvefit(fun_pix,[0.1 0.006 ],z,ydata,lb,ub,opts);
                   R2(i,j)=1-rn/var(ydata)/(length(ydata)-1);
                catch
                    est_pix(i,j,:)=[0 0 0];
                end
            else
                est_pix(i,j,:) = [0 0 0];
            end
        end           
    end
    

    %% visualization & save
%     savename=strcat('R2-',num2str(s_seg),'-',num2str(z_seg));
%     save([datapath, '/fitting/vol', num2str(s_seg),'/',savename, '.mat'],'R2');
    R2=single(R2);    
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

%     zr = single(squeeze(est_pix(:,:,4)));
% %     savename=strcat('mub-',num2str(s_seg),'-',num2str(z_seg));
% %     save([datapath, '/fitting/vol', num2str(s_seg), '/', savename, '.mat'],'ub');
%     tiffname=strcat(datapath,'fitting/vol',num2str(s_seg),'/','ZR.tif');
%     if z_seg==1
%         t = Tiff(tiffname,'w');
%     else
%         t = Tiff(tiffname,'a');
%     end
%     tagstruct.ImageLength     = size(zr,1);
%     tagstruct.ImageWidth      = size(zr,2);
%     tagstruct.SampleFormat    = Tiff.SampleFormat.IEEEFP;
%     tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
%     tagstruct.BitsPerSample   = 32;
%     tagstruct.SamplesPerPixel = 1;
%     tagstruct.Compression     = Tiff.Compression.None;
%     tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
%     tagstruct.Software        = 'MATLAB';
%     t.setTag(tagstruct);
%     t.write(zr);
%     t.close();
    