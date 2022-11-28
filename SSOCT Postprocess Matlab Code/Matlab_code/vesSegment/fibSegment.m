function [I_VE,I_seg] = fibSegment(I, sigma, thres)
% This function performs 3D vessel enhancemnt filtering and thesholding to get
% vessel segmentation
%
% [I_VE,I_seg] = vesSegment(I, sigma, thres)
% I - 3D angiogram
% sigma - array of standard deviation values of gaussian filter to
% calcualte hessian matrix at each voxel
% threshold value to get segmentation
    
    % set parameters
    alpha = 0.25;    
    gamma12 = 0.5;
    gamma23 = 0.5;
    
    % get volume size and cerate the empty voulme for output
    [k,l,m] = size(I);
    I_VE = zeros(k,l,m);
    T_temp = zeros(k,l,m);
    
    % vessel enhancement filtering
    h = waitbar(0,'Please wait... performing vessel enhancement');
    for i = 1:length(sigma)
        waitbar((i-1)/length(sigma));

        [Dxx, Dyy, Dzz, Dxy, Dxz, Dyz] = Hessian3D(I,sigma(i));

        [Lambda1,Lambda2,Lambda3,~,~,~] = eig3volume(Dxx,Dxy,Dxz,Dyy,Dyz,Dzz);
        
        SortL = sort([Lambda1(:)'; Lambda2(:)'; Lambda3(:)'],'descend');
        Lambda1 = reshape(SortL(1,:),size(Lambda1));
        Lambda2 = reshape(SortL(2,:),size(Lambda2));
        Lambda3 = reshape(SortL(3,:),size(Lambda3));
        
        idx = find(Lambda3 < 0 & Lambda2 < 0 & Lambda1 < 0);
        T_temp(idx ) = abs(Lambda3(idx)).*(Lambda2(idx)./Lambda3(idx)).^gamma23.*(1+Lambda1(idx)./abs(Lambda2(idx))).^gamma12 - 0.1.*(abs(Lambda3(idx))).*((Lambda1(idx))./(Lambda3(idx)));
        idx = find(Lambda3 < 0 & Lambda2 < 0 & Lambda1 > 0 & Lambda1 < abs(Lambda2)/alpha);
        T_temp(idx ) = abs(Lambda3(idx)).*(Lambda2(idx)./Lambda3(idx)).^gamma23.*(1-alpha*Lambda1(idx)./abs(Lambda2(idx))).^gamma12;
        if i == 1
            I_VE = T_temp;
        else
            I_VE = max(I_VE,T_temp);
        end
    end
    close(h);
    
    % normalize the data (probably normalizing slice wise might be good?)
    I_VE = (I_VE-min(I_VE(:)))/(max(I_VE(:))-min(I_VE(:)));
    
    % threshold the volume to get segmentation
    T_thres = I_VE;
    T_thres(I_VE<thres) = 0;
    T_thres(I_VE>=thres) = 1;
    
    % get connectivity analysis and remove small disconnected segments
    CC = bwconncomp(T_thres);
    I_seg = T_thres;
    for uuu = 1:length(CC.PixelIdxList)
        if length(CC.PixelIdxList{uuu}) < 100    % default:30
            I_seg(CC.PixelIdxList{uuu}) = 0;
        end
    end
end