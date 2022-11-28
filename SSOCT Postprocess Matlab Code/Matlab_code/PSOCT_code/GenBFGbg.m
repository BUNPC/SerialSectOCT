x=100;
y=100;
bg=zeros(x,y);
for i=1:x
    for j=1:y
        if i+2*j<100
            bg(i,j)=(100-(i+2*j))/400;
        end
        if i+2*j>150
            bg(i,j)=(i+2*j-150)/300;
        end
    end
end
figure();imagesc(bg)
save('/projectnb/npbssmic/ns/distortion_correction/bfg_bg_AD7597.mat','bg')
