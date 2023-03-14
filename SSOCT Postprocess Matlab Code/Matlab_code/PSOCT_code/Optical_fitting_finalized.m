function Optical_fitting_3p(co, cross, s_seg, z_seg, datapath,aip_threshold, mus_depth, bfg_depth, ds_factor, zf, zf_tilt)
% Fitting scattering and retardance of brain tissue
% co: volume data for co pol
% cross: volume data for cross pol
% s_seg: slice number
% Z_seg: tile number
% datapath: datapath for original data
% aip_threshold: intensity threshold to remove agarose, use same value as
% in OCT_recon.m
% mus_depth: number of pixels for fitting mus
% bfg_depth: number of pixels for fitting birefringence
% ds_factor: downsample factor
% zf: average depth of focus
% zf_tilt: tilt of zf

    cd(datapath);
    opts = optimset('Display','off','TolFun',1e-10);
    co1=imresize3(co,[size(co,1), size(co,2)/20, size(co,3)/20]);
    cross1=imresize3(cross, [size(cross,1), size(cross,2)/20, size(cross,3)/20]);
    ref=single(sqrt(co1.^2+cross1.^2));
    sur=surprofile2(ref,'PSOCT',1); % find surface, downsample=20
    Z_step=3;

%     % sensitivity roll-off correction
%     % w=2.2; % sensitivity roff-off constant, w=2.2 for 5x obj, w=2.22 for 10x obj
%     % I=rolloff_corr(I,w);

    aip=squeeze(mean(ref(1:110,:,:),1));
    mask=zeros(size(aip));
    mask(aip>aip_threshold)=1;
    mask2=zeros(size(ref));
    for i=1:size(ref,1)
        mask2(i,:,:)=mask;
    end
    vol=mask2.*ref;
    clear mask2
    clear ref
    
    %% Prefit with 2 parameters, zr = 70 um, zf = (zf-surface)*Z_step and adjust according to zf_tilt
    param = zeros(size(vol,2),size(vol,3),2); 

    for i = 1:size(vol,2)
        for j = 1:size(vol,3)
            aline = vol(:,i,j);
            aline = aline - mean(aline(10:20));
            start_depth=sur(i,j)+2;
            fit_depth=min(length(aline)-5,start_depth+mus_depth-1);
            if max(aline) > 0.05
                ydata = double(aline(start_depth:fit_depth)');
                zdata = (2:length(ydata)+1)*Z_step;
                fun_pix = @(p,zdata)double(sqrt(p(1).*exp(-2.*p(2).*(zdata)).*(1./(1+((zdata-((zf-sur(i,j))*Z_step+i*20/zf_tilt))./70).^2)))); 
                lb = [0.0001 0.0001 ];
                ub=[20 0.03 ];
                try
                   param(i,j,:) = lsqcurvefit(fun_pix,[0.1 0.01 ],zdata,ydata,lb,ub,opts);

                catch
                    param(i,j,:)=[0 0 ];
                end
            else
                param(i,j,:) = [0 0 ];
            end
        end           
    end
    
    musPrefit = single(1000.*squeeze(param(:,:,2)));     % unit:mm-1
    maskUsPre=zeros(size(musPrefit));
    maskUsPre(musPrefit>0.2)=1;
    musPrefit(maskUsPre==0)=mean2(musPrefit(maskUsPre==1));
    musPrefit = my_convn(musPrefit,ones(5,5));
    
    %% fit again with 2 parameters, adjusted zf and zr according to prefit results
    co1=imresize3(co,[size(co,1), round(size(co,2)/ds_factor), round(size(co,3)/ds_factor)]);
    cross1=imresize3(cross, [size(cross,1), round(size(cross,2)/ds_factor), round(size(cross,3)/ds_factor)]);
    ref=single(sqrt(co1.^2+cross1.^2));
    sur=surprofile2(ref,'PSOCT',1); % find surface, downsample=10
    % flatten surface where tissue surface is below or above average
    % tissue surface by two standard deviations
    if mean2(sur)>1
        sur_smooth=sur;
        masksur=ones(size(sur_smooth));
        masksur(sur_smooth>mean2(sur)+2*std2(sur))=0;
        sur_smooth(masksur==0)=mean2(sur_smooth(masksur==1));
        sur_smooth = my_convn(sur_smooth,ones(10,10));
    end
    % masking volume to remove agarose
    aip=squeeze(mean(ref(1:110,:,:),1));
    mask=zeros(size(aip));
    mask(aip>aip_threshold)=1;
    mask2=zeros(size(ref));
    for i=1:size(ref,1)
        mask2(i,:,:)=mask;
    end
    vol=mask2.*ref;
    clear mask2
    clear ref

    % start fitting
    param = zeros(size(vol,2),size(vol,3),4); 
    R_2=zeros(size(vol,2),size(vol,3));
    for i = 1:size(vol,2)
        for j = 1:size(vol,3)
            aline = vol(:,i,j);
            aline = aline - mean(aline(10:20));
            start_depth=sur(i,j)+2;                                                             % depth to start fitting, 2 pixel below surface
            fit_depth=min(length(aline)-5,start_depth+mus_depth-1);                             % total fitting depth in pixels

            if max(aline) > 0.05                                                                % remove agarose
                ydata = double(aline(start_depth:fit_depth)');
                zdata = (2:length(ydata)+1)*Z_step;
                %% Correct zf according to multiple factors
                param(i,j,3)=(...
                    (zf-sur_smooth(i,j))*Z_step ...                                             % surface-unflatness caused zf shift
                    - musPrefit(ceil(i/20*ds_factor),ceil(j/20*ds_factor)) ...                  % mus caused zf shift
                    + i*ds_factor/zf_tilt...                                                    % zf tilt across FOV, assuming linear tilt
                    /(musPrefit(ceil(i/20*ds_factor),ceil(j/20*ds_factor))/20+1)...             % mus caused zf tilt across FOV
                    ); % NC6839
                %% correct zr according to mus
                param(i,j,4) = 70-(musPrefit(ceil(i/20*ds_factor),ceil(j/20*ds_factor)))/2;     % mus corrected zr
                %% define fitting function
                fun_pix = @(p,zdata)double(sqrt(...
                    p(1).*exp(-2.*p(2).*(zdata)).*...                                           % mub and mus variables
                    (1./(1+((zdata-param(i,j,3))...                                             % using corrected zf 
                    ./param(i,j,4)).^2))...                                                     % using mus corrected zr
                    ));  
                %% fitting
                lb = [0.0001 0.0001 ];
                ub=[20 0.03 ];
                try
                   [param(i,j,1:2), rn] = lsqcurvefit(fun_pix,[0.1 0.006 ],zdata,ydata,lb,ub,opts);
                   R_2(i,j)=1-rn/var(ydata)/(length(ydata)-1);
                catch
                    param(i,j,1:2)=[0 0 ];
                    display('fitting mus failed')
                end
            else
                param(i,j,1:2) = [0 0 ];
            end
        end           
    end
    %% visualization & save
    R_2=single(R_2);
    tiffname=strcat(datapath,'fitting/vol',num2str(s_seg),'/','R2.tif');
    SaveTiff(R_2,z_seg,tiffname);

    mus = single(1000.*squeeze(param(:,:,2)));     % unit:mm-1
    tiffname=strcat(datapath,'fitting/vol',num2str(s_seg),'/','MUS.tif');
    SaveTiff(mus,z_seg,tiffname);

    mub = single(squeeze(param(:,:,1)));
    tiffname=strcat(datapath,'fitting/vol',num2str(s_seg),'/','MUB.tif');
    SaveTiff(mub,z_seg,tiffname);

    zf = single(squeeze(param(:,:,3)));
    tiffname=strcat(datapath,'fitting/vol',num2str(s_seg),'/','ZF.tif');
    SaveTiff(zf,z_seg,tiffname);

    zr = single(squeeze(param(:,:,4)));
    tiffname=strcat(datapath,'fitting/vol',num2str(s_seg),'/','ZR.tif');
    SaveTiff(zr,z_seg,tiffname);

%% fitting retardance slope
    co1=imresize3(co,[size(co,1), size(co,2)/ds_factor, size(co,3)/ds_factor]);
    cross1=imresize3(cross, [size(cross,1), size(cross,2)/ds_factor, size(cross,3)/ds_factor]);
    ref=single(sqrt(co1.^2+cross1.^2));
    sur=surprofile2(ref,'PSOCT',1); 
    
    % remove agarose
    aip=squeeze(mean(ref(1:110,:,:),1));
    mask=zeros(size(aip));
    mask(aip>aip_threshold)=1;
    mask2=zeros(size(ref));
    for i=1:size(ref,1)
        mask2(i,:,:)=mask;
    end
    ret=single(atan(cross1./co1));
    vol=ret.*mask2;
    clear mask2
    clear ret
    
    % fitting
    param = zeros(size(vol,2),size(vol,3),2);
    for i = 1:size(vol,2)
        for j = 1:size(vol,3)
            aline = vol(:,i,j);
            start_depth=sur(i,j)+5;
            if max(aline) > 0.001
                if exist('mus','var')==0
                    mus=imread(strcat(datapath,'fitting_4x/vol',num2str(s_seg),'/','MUS.tif'),z_seg);
                end
                mus_grey=3;
                mus_ratio=4;
                % 2 for NC6839,NC6974; 4 for NC6074,NC6839,NC21499
                % 3 for AD20832, AD21354,AD21424, CTE8489, All CTE
                fit_depth=round(bfg_depth-(mus(ceil(i/4*ds_factor),ceil(j/4*ds_factor))-mus_grey)*mus_ratio); % correct fit_depth according to mus
                fit_depth=min(size(aline,1)-5,start_depth+fit_depth-1);
                ydata = double(aline(start_depth:fit_depth)');
                zdata = (5:(length(ydata)+4))*Z_step;
                fun_pix = @(p,zdata)p(1)/1.3*2*pi*zdata+p(2);
  
                % upper and lower bound for fitting parameters
                lb = [0.000001 0.001];%75-35
                ub=[0.01 1];%75+35
                try
                   param(i,j,:) = lsqcurvefit(fun_pix,[0.0002 0.05],zdata,ydata,lb,ub,opts);
                catch
                    param(i,j,:)=[0 0];
                end
            else
                param(i,j,:) = [0 0];
            end
        end           
    end

    %% visualization & save

    bfg = single(squeeze(param(:,:,1)));     % unit:mm-1
    tiffname=strcat(datapath,'fitting/vol',num2str(s_seg),'/','BFG.tif');
    SaveTiff(bfg,z_seg,tiffname);

    bkg = single(squeeze(param(:,:,2)));
    tiffname=strcat(datapath,'fitting/vol',num2str(s_seg),'/','BKG.tif');
    SaveTiff(bkg,z_seg,tiffname);
end
