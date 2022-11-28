% folder='/projectnb2/npbssmic/ns/201028_PSOCT_Ann_7688/fitting/'; 
% cd(folder);
% nslice=50;
% GM=[];
% WM=[];
% center=[];
% n=250;
% for i=1:nslice
%     load(strcat(folder,'vol',num2str(i),'/mus.mat'))
%     mus=MosaicFinal;
%     list=mus(mus>0.1);
%     list=sort(list);
%     mid=list(findchangepts(list));
% 
%     mask0=mus>0.5;
%     mask0=mask0.*(mus<29);
%     mask=zeros(size(mus));
%     mask(mus<mid-0.5)=1;
% %     figure(10);imagesc(mask.*mask0);
%     GM=mus(mask.*mask0==1);
% %     GM=[GM;mus(mask.*mask0==1)];
% 
%     mask=zeros(size(mus));
%     mask(mus>mid+0.5)=1;
%     WM=mus(mask.*mask0==1);
% %     WM=[WM;mus(mask.*mask0==1)];
% 
% %     mask=ones(size(mus));
% %     mask(mus<mid-0.5)=0;
% %     mask(mus>mid+0.5)=0;
% %     center=[center;mus(mask==1)];
%     
%     figure(1);title('7688');xlabel('mus');
%     h=histogram(GM,200);h.FaceColor=[n/255,n/255,n/255];h.EdgeColor='none';hold on;
%     % hist(2*ones(length(center),1),center,'b');hold on;
%     g=histogram(WM,200);g.FaceColor=[(255-n)/255,(255-n)/255,(255-n)/255];g.EdgeColor='none';hold on
%     n=n-5;
%     pause(0.5)
% end




folder='/projectnb2/npbssmic/ns/201128_PSOCT_Ann_7694/fitting/'; 
cd(folder);
nslice=20;
GM2=[];
WM2=[];
% center=[];
% n=250;
for i=1:nslice
    load(strcat(folder,'vol',num2str(i),'/mus.mat'))
    mus=MosaicFinal;
    list=mus(mus>0.1);
    list=sort(list);
    mid=list(findchangepts(list));

    mask0=mus>0.5;
    mask0=mask0.*(mus<29);
    mask=zeros(size(mus));
    mask(mus<mid-0.5)=1;
    figure(10);imagesc(mask.*mask0);
%     GM=mus(mask.*mask0==1);
    GM2=[GM2;mus(mask.*mask0==1)];

    mask=zeros(size(mus));
    mask(mus>mid+0.5)=1;
    figure(10);imagesc(mask.*mask0)
%     WM=mus(mask.*mask0==1);
    WM2=[WM2;mus(mask.*mask0==1)];

%     mask=ones(size(mus));
%     mask(mus<mid-0.5)=0;
%     mask(mus>mid+0.5)=0;
%     center=[center;mus(mask==1)];
end
f=figure(3);
h=histogram(GM3,200);h.FaceColor=[0.01,0.01,0.01];h.EdgeColor='none';hold on;
% hist(2*ones(length(center),1),center,'b');hold on;
g=histogram(WM3,200);g.FaceColor=[0.7,0.7,0.7];g.EdgeColor='none';hold on
title('PTSD histogram');xlabel('mus(mm^-^1)');
legend({'GM','WM'});set(gca,'FontSize',12)
