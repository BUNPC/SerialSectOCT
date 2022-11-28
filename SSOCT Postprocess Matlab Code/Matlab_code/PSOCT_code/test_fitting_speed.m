function test_fitting_speed(co, cross, s_seg, z_seg, datapath)
% Fitting code for the data shared by Hui. 
% I: volume data for 1 tile
% s_seg: slice number
% Z_seg: tile number
% datapath: datapath for original data
% zf: focus depth matrix, X*Y dimension
I=sqrt(co.^2+cross.^2);
cd(datapath);
for lim=[1e-3, 1e-4, 1e-5, 1e-6, 1e-7, 1e-8]
    tic
    opts = optimset('Display','off','TolFun',1e-8);
    % v=ones(3,19,19)./3/19/19;
    % I=convn(I,v,'same');
    % depth to fit, tunable
    fit_depth = round(200); 
    % Z step size
    Z_step=0.003;%unit mm
    % sensitivity roll-off correction
    % w=2.2; % sensitivity roff-off constant, w=2.2 for 5x obj, w=2.22 for 10x obj
    % I=rolloff_corr(I,w);

    % the following indent lines are trying to find Z start pixel for fitting for
    % unflat cut. The start pixel is defined by the average height of tissue
    % surface. 
        sur=surprofile2(I,'PSOCT');
        aip=squeeze(mean(I,1));
    %     aip2=My_downsample(aip);
    %     mask=zeros(size(aip2));
    %     mask(aip2>0.055)=1;
    %     z0=round(mean(mean(sur(mask==1))));
    %     if isnan(z0)
    %         z0=30;
    %     end 
    %     if z0>55
    %         z0=55;
    %     elseif z0<36
    %             z0=36;
    %     end
    % for flat cut, define a constant depth as start of fitting
    % z0=30;
    % cut out the signal above start depth
    % d=min(fit_depth+z0-1,size(I,1));
    % I=I(z0:d,:,:);
    % sur=sur-z0;
    % sur(sur<0)=1;
    mask=zeros(size(aip));
    mask(aip>0.055)=1;
    % correct focus depth accordingly, if there is a focus depth variation
    % zf=zf-z0;
    % zf=zf.*Z_step;

    % The following indent lines average the whole tile and do a fitting, the purpose here is to find the
    % average rayleigh range
    %
    % Or you can use a constant rayleigh range for all tiles

        mask2=zeros(size(I));
        for i=1:size(I,1)
            mask2(i,:,:)=mask;
        end
        k=mask2.*I;
        co=mask2.*co;
        cross=mask2.*cross;
    %     % Average attenuation for the full ROI
    %     mean_I = squeeze(mean(mean(k,2),3));
    %     mean_I = mean_I - mean(mean_I(end-5:end));
    %     [m,x]=max(mean_I);
    %     x=findchangepts(mean_I(1:x+20))+17;
    %     ydata = double(mean_I(x:end-5)');
    %     z = (17:(length(ydata)+17-1))*Z_step;
    %     fun = @(p,zdata)sqrt(p(1).*exp(-2.*p(2).*zdata).*(1./(1+((zdata-p(3))./p(4)).^2)));
    %     lb = [0.0001 0.0001 10 65];
    %     ub = [10 0.03 250 150];
    %     est = lsqcurvefit(fun,[0.1 0.01 20*Z_step 150],z,ydata,lb,ub,opts);
    %      A = fun(est,z);
    %       % plotting intial fitting
    %         figure
    %         plot(z,ydata,'b.')
    %         hold on
    %         plot(z,A,'r-')
    %         xlabel('z (um)')
    %         ylabel('I')
    %         title('Four parameter fit of averaged data')
    %         dim = [0.2 0.2 0.3 0.3];
    %         str = {'Estimated values: ',['Relative back scattering: ',num2str(est(1),4)],['Scattering coefficient: ',...
    %             num2str(est(2)*1000,4),'mm^-^1'],['Focus depth: ',num2str(est(3),4),'um'],['Rayleigh estimate: ',num2str(round(est(4)),4),'um']};
    %         annotation('textbox',dim,'String',str,'FitBoxToText','on');

        %% Curve fitting for the whole image
        res = 20;  %A-line averaging factor
        est_pix = zeros(round(size(I,2)/res),round(size(I,3)/res),4);
    %     load(strcat(datapath,'mub_mask.mat'));

        for i = 1:round(size(I,2)/res)
            for j = 1:round(size(I,3)/res)
                area = k(:,(i-1)*res+1:i*res,(j-1)*res+1:j*res);
                int = squeeze(mean(mean(area,2),3));
                int = (int - mean(int(end-5:end)));
                m=max(int);
    %             xloc=x;   % empirical start point of fitting is good enough for flat slice
                xloc=sur(ceil(i/10*res),ceil(j/10*res))+2;
                if m > 0.05
                    l=min(size(int,1)-5,xloc+fit_depth-1);
                    ydata = double(int(xloc:l)');%./sqrt(mub_mask(i,j)));
                    z = (2:(length(ydata)+1))*Z_step;%(xloc:(length(ydata)+xloc-1))*Z_step;
    %                 fun_pix = @(p,zdata)sqrt(p(1).*exp(-2.*p(2).*(zdata)).*(1./(1+((zdata-p(3))./(120)).^2))); %75; 3-parameter fitting using empirical rayleigh range
                    fun_pix = @(p,zdata)sqrt(p(1).*exp(-2.*p(2).*(zdata)).*(1./(1+((zdata-p(3))./(p(4))).^2))); % 4-parameter fitting using tile-dependent zf and rayleigh range from above fitting

                    % upper and lower bound for fitting parameters
                    lb = [0.001 0.0001  130-5-3*xloc 122-30];%75-35
                    ub=[10 10 130+55-3*xloc 122+30];%75+35
                    try
                       est_pix(i,j,:) = lsqcurvefit(fun_pix,[0.01 1 150 122],z,ydata,lb,ub,opts);
                    catch
                        est_pix(i,j,:)=[0 0 0 0];
                    end
                else
                    est_pix(i,j,:) = [0 0 0 0];
                end
            end           
        end

        mus = squeeze(est_pix(:,:,2));   
        mub = squeeze(est_pix(:,:,1));
        zf = squeeze(est_pix(:,:,3));
        Rs = squeeze(est_pix(:,:,4));
        %% fitting co pol
        res = 10;  %A-line averaging factor
        est_pix = zeros(round(size(I,2)/res),round(size(I,3)/res),2);
    %     load(strcat(datapath,'mub_mask.mat'));

        for i = 1:round(size(I,2)/res)
            for j = 1:round(size(I,3)/res)
                area = cross(:,(i-1)*res+1:i*res,(j-1)*res+1:j*res);
                int = squeeze(mean(mean(area,2),3));
    %             int = (int - mean(int(end-5:end)));
                m=max(int);
    %             xloc=x;   % empirical start point of fitting is good enough for flat slice
                xloc=sur(ceil(i/10*res),ceil(j/10*res))+2;
                if m > 0.05
                    l=min(size(int,1)-5,xloc+fit_depth-1);
                    ydata = double(int(xloc:l)');%./sqrt(mub_mask(i,j)));
                    z = (2:(length(ydata)+1))*Z_step;%(xloc:(length(ydata)+xloc-1))*Z_step;
    %                 fun_pix = @(p,zdata)sqrt(p(1).*exp(-2.*p(2).*(zdata)).*(1./(1+((zdata-p(3))./(120)).^2))); %75; 3-parameter fitting using empirical rayleigh range
                    fun_pix = @(p,zdata)abs(sqrt(mub(ceil(i/20*res),ceil(j/20*res)).*exp(-2.*mus(ceil(i/20*res),ceil(j/20*res)).*(zdata)).*(1./(1+((zdata-zf(ceil(i/20*res),ceil(j/20*res)))./(Rs(ceil(i/20*res),ceil(j/20*res)))).^2))).*sin(p(1)*zdata))+p(2); % 2-parameter fitting using tile-dependent zf and rayleigh range from above fitting

                    % upper and lower bound for fitting parameters
                    lb = [0.1 0.001];%75-35
                    ub=[20 1 ];%75+35
                    try
                       est_pix(i,j,:) = lsqcurvefit(fun_pix,[10 0.006],z,ydata,lb,ub,opts);
                    catch
                        est_pix(i,j,:)=[0 0];
                    end
                else
                    est_pix(i,j,:) = [0 0];
                end
            end           
        end
        
      toc
      
        bfg_cross = squeeze(est_pix(:,:,1));     % unit:mm-1
        savename=strcat('bfg_cross-',num2str(s_seg),'-',num2str(z_seg));%['mus_',num2str(s_seg),'_',num2str(z_seg)];
        save([datapath, '/fitting/vol', num2str(s_seg),'/',savename, '.mat'],'bfg_cross');
        figure;imagesc(bfg_cross);

      
end
