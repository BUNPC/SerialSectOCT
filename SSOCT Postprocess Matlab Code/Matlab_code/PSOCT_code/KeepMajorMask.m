function[mask2]=KeepMajorMask(mask2, thresh)
% removing all small ilands
% small means less then 5000 pixels
cc=bwconncomp(mask2); 
N=cc.NumObjects;
for ii =1:N
    L(ii)=length(cc.PixelIdxList{ii});
end
[~,kk]=max(L);
if kk ==1
    for ii =2:N
        [row,col]=ind2sub([size(mask2,1),size(mask2,2)],cc.PixelIdxList{ii});
        if length(row)<thresh
            mask2(row,col)=0;
        end
    end
elseif kk ==N
        for ii = 1:N-1
            [row,col]=ind2sub([size(mask2,1),size(mask2,2)],cc.PixelIdxList{ii});
            if length(row)<thresh
                mask2(row,col)=0;
            end
        end
else
    for ii = 1:kk-1
        [row,col]=ind2sub([size(mask2,1),size(mask2,2)],cc.PixelIdxList{ii});
            if length(row)<thresh
                mask2(row,col)=0;
            end
    end
    for ii = kk+1:N
        [row,col]=ind2sub([size(mask2,1),size(mask2,2)],cc.PixelIdxList{ii});
            if length(row)<thresh
                mask2(row,col)=0;
            end
    end
end
        