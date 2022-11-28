function Optical_fitting_sum_square_error2(co, cross, s_seg, z_seg, datapath)
% Fitting code for the data shared by Hui. 
% I: volume data for 1 tile
% s_seg: slice number
% Z_seg: tile number
% datapath: datapath for original data
% zf: focus depth matrix, X*Y dimension
I=sqrt(co.^2+cross.^2);
cd(datapath);
opts = optimset('Display','off','TolFun',1e-8);
% v=ones(3,19,19)./3/19/19;
% I=convn(I,v,'same');
% depth to fit, tunable
fit_depth = round(180); 
% Z step size
Z_step=0.003;%unit mm
% sensitivity roll-off correction
% w=2.2; % sensitivity roff-off constant, w=2.2 for 5x obj, w=2.22 for 10x obj
% I=rolloff_corr(I,w);

% sur=surprofile2(I,'PSOCT');
aip=squeeze(mean(I,1));

mask=zeros(size(aip));
mask(aip>0.055)=1;

mask2=zeros(size(I));
for i=1:size(I,1)
    mask2(i,:,:)=mask;
end
k=mask2.*I;
co=mask2.*co;
cross=mask2.*cross;

%% Curve fitting for the whole image
res = 10;  %A-line averaging factor
est_pix = zeros(round(size(I,2)/res),round(size(I,3)/res),5);

for i = 1:round(size(I,2)/res)
    for j = 1:round(size(I,3)/res)
        area = k(:,(i-1)*res+1:i*res,(j-1)*res+1:j*res);
        int = squeeze(mean(mean(area,2),3));
%         int = (int - mean(int(end-5:end)));
        m=max(int);
        xloc=30;%sur(ceil(i/10*res),ceil(j/10*res))+2;
        if m > 0.05
            l=min(size(int,1)-5,xloc+fit_depth-1);
            ydata = double(int(xloc:l)');
            z = (2:(length(ydata)+1))*Z_step;
%                 fun_pix = @(p,zdata)sqrt(p(1).*exp(-2.*p(2).*(zdata)).*(1./(1+((zdata-p(3))./(120)).^2))); %75; 3-parameter fitting using empirical rayleigh range
            fun_pix = @(p,zdata)sqrt(p(1).*exp(-2.*p(2).*(zdata)).*(1./(1+((zdata-p(3))./(p(4))).^2)))+p(5); % 4-parameter fitting using tile-dependent zf and rayleigh range from above fitting

            % upper and lower bound for fitting parameters
            lb = [0.001 0.1  (110-5-3*xloc)/1000 (122-30)/1000 0.001];%75-35
            ub=[10 10 (300+55-3*xloc)/1000 (122+30)/1000 1];%75+35
            try
                est_pix(i,j,:) = lsqcurvefit(fun_pix,[0.01 1 150 122 0.01],z,ydata,lb,ub,opts);
            catch
                est_pix(i,j,:)=[0 0 0 0 0];
            end
        else
            est_pix(i,j,:) = [0 0 0 0 0];
        end
    end           
end

mus = squeeze(est_pix(:,:,2));   
mub = squeeze(est_pix(:,:,1));
zf = squeeze(est_pix(:,:,3));
Rs = squeeze(est_pix(:,:,4));
% bg=squeeze(est_pix(:,:,5));
%% fitting co+cross pol
res = 10;  %A-line averaging factor
est_pix = zeros(round(size(I,2)/res),round(size(I,3)/res),3);

for i = 1:round(size(I,2)/res)
    for j = 1:round(size(I,3)/res)
        area = cross(:,(i-1)*res+1:i*res,(j-1)*res+1:j*res);
        int = squeeze(mean(mean(area,2),3));
        m=max(int);
        xloc=30;%sur(ceil(i/10*res),ceil(j/10*res))+2;
        if m > 0.05
            l=min(size(int,1)-5,xloc+fit_depth-1);
            ycross = double(int(xloc:l)');
            z = (2:(length(ycross)+1))*Z_step;
            area = co(:,(i-1)*res+1:i*res,(j-1)*res+1:j*res);
            int = squeeze(mean(mean(area,2),3));
            yco = double(int(xloc:l)');
            
            amp=sqrt(mub(ceil(i/10*res),ceil(j/10*res)).*...
                exp(-2.*mus(ceil(i/10*res),ceil(j/10*res)).*(z)).*...
                (1./(1+((z-zf(ceil(i/10*res),ceil(j/10*res)))./...
                (Rs(ceil(i/10*res),ceil(j/10*res)))).^2)));
            
            fun_cross = @(p,zdata)amp.*abs(sin(p(1)*zdata/1.3*2*pi+p(2)))+p(3); 
            fun_co = @(p,zdata)amp.*abs(cos(p(1)*zdata/1.3*2*pi+p(2)))+p(3); 
            fun_A = @(p,zdata)fun_cross(p,zdata)+0.3*fun_co(p,zdata);
            fun_B=@(p,zdata)fun_co(p,zdata)+0.03*fun_cross(p,zdata);
            % upper and lower bound for fitting parameters
            lb = [0.0001 0.01 0.001];%75-35
            ub=[3 pi .1];%75+35
            ycross2=my_smooth_1D(ycross,10);
            
            % find correct start point
            parami = 0;
            p_param = [];
            for param=0.3:1:4
                parami=parami+1;
                try
                    p_param(parami,:) = lsqcurvefit(fun_A,[param 1 0.01],z,ycross2,lb,ub,opts);
                catch
                    p_param(parami,:) =[0 0 0];
                end
                err(parami)=sum((fun_A(p_param(parami,:),z)-ycross2).^2);
            end
            [~,idx]=min(err);
            p=squeeze(p_param(idx,:));

            yco2=my_smooth_1D(yco,10);
            % find correct start point
            parami = 0;
            p_param = [];
            for param=0.3:1:4
                parami=parami+1;
                try
                    p_param(parami,:) = lsqcurvefit(fun_B,[param 1 0.01],z,yco2,lb,ub,opts);
                catch
                    p_param(parami,:) =[0 0 0];
                end
                err(parami)=sum((fun_B(p_param(parami,:),z)-yco2).^2);
            end
            [~,idx]=min(err);
            p2=squeeze(p_param(idx,:));
            
            p=[(p(1)+p2(1))/2 (p(2)+p2(2))/2 p(3)];%average two channels
            SSE=sum((fun_A(p,z)-ycross).^2)+sum((fun_B([p(1) p(2) p2(3)],z)-yco).^2);
            dif=0.1;
            n_steps=1;
            delta_gamma=.01;
            while abs(dif)>1e-5 && n_steps<20
                n_steps=n_steps+1;
                delta_gamma=-dif/abs(dif)*delta_gamma;%/abs(delta_gamma)*sqrt(abs(dif));
                p(1)=p(1)+delta_gamma;
                p(2)=p(2)+delta_gamma;
                tmp=sum((fun_A(p,z)-ycross).^2)+sum((fun_B([p(1) p(2) p2(3)],z)-yco).^2);
                dif=tmp-SSE;
                SSE=tmp;
            end
            est_pix(i,j,:) = [p(1) p(2) SSE];
        else
            est_pix(i,j,:) = [0 0 0];
        end
    end           
end

%% visualization & save
phase=squeeze(est_pix(:,:,2));

bfg = squeeze(est_pix(:,:,1))./1000;     % unit:mm-1
savename=strcat('bfg-',num2str(s_seg),'-',num2str(z_seg));%['mus_',num2str(s_seg),'_',num2str(z_seg)];
save([datapath, '/fitting/vol', num2str(s_seg),'/',savename, '.mat'],'bfg');

savename=strcat('mus-',num2str(s_seg),'-',num2str(z_seg));%['mus_',num2str(s_seg),'_',num2str(z_seg)];
save([datapath, '/fitting/vol', num2str(s_seg),'/',savename, '.mat'],'mus');

savename=strcat('mub-',num2str(s_seg),'-',num2str(z_seg));%['mus_',num2str(s_seg),'_',num2str(z_seg)];
save([datapath, '/fitting/vol', num2str(s_seg),'/',savename, '.mat'],'mub');

