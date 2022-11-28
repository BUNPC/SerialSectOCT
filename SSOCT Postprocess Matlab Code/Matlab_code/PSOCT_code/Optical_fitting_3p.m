function Optical_fitting_3p(co, cross, s_seg, z_seg, datapath,threshold, mus_depth, bfg_depth, ds_factor, zf)
% Fitting scattering and retardance of brain tissue
% co: volume data for co pol
% cross: volume data for cross pol
% s_seg: slice number
% Z_seg: tile number
% datapath: datapath for original data
    sur=surprofile2(co,'PSOCT',20); % find surface, downsample=20
%     if mean2(sur)>1
%         sursm=sur;
%         masksur=ones(size(sursm));
%         masksur(sursm>mean2(sur)+2*std2(sur))=0;
%         sursm(masksur==0)=mean2(sursm(masksur==1));
%         sursm = my_convn(sursm,ones(5,5));
%     end
%     
    cd(datapath);
    opts = optimset('Display','off','TolFun',1e-10);
    res = ds_factor;  %A-line averaging factor
    co1=imresize3(co,[size(co,1), size(co,2)/20, size(co,3)/20]);
    cross1=imresize3(cross, [size(cross,1), size(cross,2)/20, size(cross,3)/20]);
    
    ref=single(sqrt(co1.^2+cross1.^2));
    Z_step=3;
%     % sensitivity roll-off correction
%     % w=2.2; % sensitivity roff-off constant, w=2.2 for 5x obj, w=2.22 for 10x obj
%     % I=rolloff_corr(I,w);
% 
    aip=squeeze(mean(ref(ceil(mean2(sur)+5):end,:,:),1));
    mask=zeros(size(aip));
    mask(aip>threshold)=1;
    mask2=zeros(size(ref));
    for i=1:size(ref,1)
        mask2(i,:,:)=mask;
    end
    vol=mask2.*ref;

    %% Prefit with 2 parameters, fixed zf and zr in grey matter
    est_pix = zeros(size(vol,2),size(vol,3),2); 

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
                fun_pix = @(p,zdata)double(sqrt(p(1).*exp(-2.*p(2).*(zdata)).*...
                    (1./(1+((zdata-((zf-sur(i,j))*Z_step+i/(4*10/20)))./70).^2)))); %75; 3-parameter fitting using empirical rayleigh range
                lb = [0.0001 0.0001 ];
                ub=[20 0.03 ];
                try
                   est_pix(i,j,:) = lsqcurvefit(fun_pix,[0.1 0.01 ],z,ydata,lb,ub,opts);
%                    R2(i,j)=1-rn/var(ydata)/(length(ydata)-1);
                catch
                    est_pix(i,j,:)=[0 0 ];
                end
            else
                est_pix(i,j,:) = [0 0 ];
            end
        end           
    end
    
    usPre = single(1000.*squeeze(est_pix(:,:,2)));     % unit:mm-1
    maskUsPre=zeros(size(usPre));
    maskUsPre(usPre>0.2)=1;
    usPre(maskUsPre==0)=mean2(usPre(maskUsPre==1));
    usPre = my_convn(usPre,ones(5,5));
    
    %% fit with 2 parameters, adjusted zf according to prefit mus
    co1=imresize3(co,[size(co,1), size(co,2)/res, size(co,3)/res]);
    cross1=imresize3(cross, [size(cross,1), size(cross,2)/res, size(cross,3)/res]);
    sur=surprofile2(co,'PSOCT',res); % find surface, downsample=10
    if mean2(sur)>1
        sursm=sur;
        masksur=ones(size(sursm));
        masksur(sursm>mean2(sur)+2*std2(sur))=0;
        sursm(masksur==0)=mean2(sursm(masksur==1));
        sursm = my_convn(sursm,ones(10,10));
    end
    ref=single(sqrt(co1.^2+cross1.^2));
    aip=squeeze(mean(ref(ceil(mean2(sur)+5):end,:,:),1));
    mask=zeros(size(aip));
    mask(aip>threshold)=1;
    mask2=zeros(size(ref));
    for i=1:size(ref,1)
        mask2(i,:,:)=mask;
    end
    vol=mask2.*ref;
    
    est_pix = zeros(size(vol,2),size(vol,3),3); 
    R2=zeros(size(vol,2),size(vol,3));
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
%                 est_pix(i,j,3)=((zf-sursm(i,j))*Z_step - usPre(ceil(i/20*res),ceil(j/20*res)) + i/(2.5*10/res)/(usPre(ceil(i/20*res),ceil(j/20*res))/20+1)); % NC6974 NC6047
                est_pix(i,j,3)=((zf-sursm(i,j))*Z_step - usPre(ceil(i/20*res),ceil(j/20*res)) + i/(3.3*10/res)/(usPre(ceil(i/20*res),ceil(j/20*res))/20+1)); % NC6839
%                 est_pix(i,j,3)=((66-sursm(i,j))*Z_step - usPre(ceil(i/20*res),ceil(j/20*res)) + i/(3*10/res)/(usPre(ceil(i/20*res),ceil(j/20*res))/20+1)); % AD10382
%                 est_pix(i,j,3)=((71-sursm(i,j))*Z_step - usPre(ceil(i/20*res),ceil(j/20*res)) + i/(3*10/res)/(usPre(ceil(i/20*res),ceil(j/20*res))/20+1)); % NC6047
                
                fun_pix = @(p,zdata)double(sqrt(p(1).*exp(-2.*p(2).*(zdata)).*...
                    (1./(1+((zdata-est_pix(i,j,3))./(70-(usPre(ceil(i/20*res),ceil(j/20*res)))/2)).^2)))); %75; 3-parameter fitting using empirical rayleigh range
                lb = [0.0001 0.0001 ];
                ub=[20 0.03 ];
                try
                   [est_pix(i,j,1:2), rn] = lsqcurvefit(fun_pix,[0.1 0.006 ],z,ydata,lb,ub,opts);
                   R2(i,j)=1-rn/var(ydata)/(length(ydata)-1);
                catch
                    est_pix(i,j,1:2)=[0 0 ];
                end
            else
                est_pix(i,j,1:2) = [0 0 ];
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

%% fitting retardance slope
    res=ds_factor;
    co1=imresize3(co,[size(co,1), size(co,2)/res, size(co,3)/res]);
    cross1=imresize3(cross, [size(cross,1), size(cross,2)/res, size(cross,3)/res]);
    sur=surprofile2(co,'PSOCT',res); % find surface, downsample=10
%     if mean2(sur)>1
%         sursm=sur;
%         masksur=ones(size(sursm));
%         masksur(sursm>mean2(sur)+2*std2(sur))=0;
%         sursm(masksur==0)=mean2(sursm(masksur==1));
%         sursm = my_convn(sursm,ones(10,10));
%     end
    ref=single(sqrt(co1.^2+cross1.^2));
    aip=squeeze(mean(ref(ceil(mean2(sur)+5):end,:,:),1));
    mask=zeros(size(aip));
    mask(aip>threshold)=1;
    mask2=zeros(size(ref));
    for i=1:size(ref,1)
        mask2(i,:,:)=mask;
    end
%     vol=mask2.*ref;
    ret=single(atan(cross1./co1));
    vol=ret.*mask2;
    est_pix = zeros(size(vol,2),size(vol,3),2);
%     start_depth=zeros(size(vol,2),size(vol,3));
%     us=single(imread(strcat(datapath,'fitting_10x_new/vol',num2str(s_seg),'/',num2str(z_seg),'_mus.tif')));

    for i = 1:size(vol,2)
        for j = 1:size(vol,3)
            int = vol(:,i,j);
            xloc=sur(ceil(i/size(vol,2)*size(sur,1)),ceil(j/size(vol,3)*size(sur,2)))+5;
            m=max(int);
%             [m xloc]=min(int); %xloc=xloc+35;
%             start_depth(i,j)=xloc;
%             xloc=sur(i,j)+5;
            if m > 0.0001
                bfg_depth1=round(bfg_depth-(us(ceil(i/10*res),ceil(j/10*res))-3)*2); %2 for NC6839,NC6974; 4 for NC6074,NC6839,NC21499
                % 3 for AD20832, AD21354,AD21424, CTE8489, All CTE
                l=min(size(int,1)-5,xloc+bfg_depth1-1);
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

%     us=single(imread(strcat(datapath,'fitting_10x_new/vol',num2str(s_seg),'/',num2str(z_seg),'_mus.tif')));
%     bfg_bg=load('/projectnb/npbssmic/ns/distortion_correction/bfg_bg.mat');
    
    %% visualization & save

    bfg = single(squeeze(est_pix(:,:,1)));     % unit:mm-1
%     bfg=bfg+bfg_bg.bg.*0.00013./(1+us./5);
%     savename=strcat('bfg-',num2str(s_seg),'-',num2str(z_seg));%['mus_',num2str(s_seg),'_',num2str(z_seg)];
%     save([datapath, '/fitting/vol', num2str(s_seg),'/',savename, '.mat'],'bfg');
    tiffname=strcat(datapath,'fitting/vol',num2str(s_seg),'/','BFG.tif');
    if z_seg==1
        t = Tiff(tiffname,'w');
    else
        t = Tiff(tiffname,'a');
    end
    tagstruct.ImageLength     = size(bfg,1);
    tagstruct.ImageWidth      = size(bfg,2);
    tagstruct.SampleFormat    = Tiff.SampleFormat.IEEEFP;
    tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
    tagstruct.BitsPerSample   = 32;
    tagstruct.SamplesPerPixel = 1;
    tagstruct.Compression     = Tiff.Compression.None;
    tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
    tagstruct.Software        = 'MATLAB';
    t.setTag(tagstruct);
    t.write(bfg);
    t.close();

    bkg = single(squeeze(est_pix(:,:,2)));
%     savename=strcat('bkg-',num2str(s_seg),'-',num2str(z_seg));%['mub_',num2str(s_seg),'_',num2str(z_seg)];
%     save([datapath, '/fitting/vol', num2str(s_seg),'/',savename, '.mat'],'bkg');
    tiffname=strcat(datapath,'fitting/vol',num2str(s_seg),'/','BKG.tif');
    if z_seg==1
        t = Tiff(tiffname,'w');
    else
        t = Tiff(tiffname,'a');
    end
    tagstruct.ImageLength     = size(bkg,1);
    tagstruct.ImageWidth      = size(bkg,2);
    tagstruct.SampleFormat    = Tiff.SampleFormat.IEEEFP;
    tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
    tagstruct.BitsPerSample   = 32;
    tagstruct.SamplesPerPixel = 1;
    tagstruct.Compression     = Tiff.Compression.None;
    tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
    tagstruct.Software        = 'MATLAB';
    t.setTag(tagstruct);
    t.write(bkg);
    t.close();
    
%     bkg = single(squeeze(est_pix(:,:,2)));
%     savename=strcat('bkg-',num2str(s_seg),'-',num2str(z_seg));%['mub_',num2str(s_seg),'_',num2str(z_seg)];
%     save([datapath, '/fitting/vol', num2str(s_seg),'/',savename, '.mat'],'bkg');
%     start_depth=single(start_depth);
%     tiffname=strcat(datapath,'fitting/vol',num2str(s_seg),'/','start_dpeth.tif');
%     if z_seg==1
%         t = Tiff(tiffname,'w');
%     else
%         t = Tiff(tiffname,'a');
%     end
%     tagstruct.ImageLength     = size(start_depth,1);
%     tagstruct.ImageWidth      = size(start_depth,2);
%     tagstruct.SampleFormat    = Tiff.SampleFormat.IEEEFP;
%     tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
%     tagstruct.BitsPerSample   = 32;
%     tagstruct.SamplesPerPixel = 1;
%     tagstruct.Compression     = Tiff.Compression.None;
%     tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
%     tagstruct.Software        = 'MATLAB';
%     t.setTag(tagstruct);
%     t.write(start_depth);
%     t.close();