function outdata=slide_win_norm(data,winsize)
%%
% sliding window depth normalization
% winsize: size of sliding window, two elements vector [xsize ysize]
% Author: Jiarui Yang
% 02/19/20

%%
% define the steps in x and y
datasize=size(data);
outdata=zeros(datasize);
stepx=ceil((datasize(1)/winsize(1)));
stepy=ceil((datasize(2)/winsize(2)));

% normalization based on x and y
for i=1:stepx
    for j=1:stepy
        
        cen=[ceil(winsize(1)/2)+(i-1)*winsize(1) ceil(winsize(2)/2)+(j-1)*winsize(2)]; % coordinate of window center
        corr_win=[cen(1)-floor(winsize(1)/2)+1 cen(1)+floor(winsize(1)/2) cen(2)-floor(winsize(2)/2)+1 cen(2)+floor(winsize(2)/2)]; % coordinate of correction window, [xstart xend ystart yend]
        
        % select neighboring window
        if corr_win(1)<winsize(1)
            if corr_win(3)<winsize(2)
                fit_win=[1 3*winsize(1) 1 3*winsize(2)];  % corrdinate of fitting window, which is 3x3 of neighboring correction window, [xstart xend ystart yend]
            elseif corr_win(4)+winsize(2)>datasize(2)
                fit_win=[1 3*winsize(1) datasize(2)-3*winsize(2)+1 datasize(2)];
            else
                fit_win=[1 3*winsize(1) corr_win(3)-winsize(1) corr_win(4)+winsize(1)];
            end
        elseif corr_win(1)+winsize(1)>datasize(1)
            if corr_win(3)<winsize(2)
                fit_win=[datasize(1)-3*winsize(1)+1 datasize(1) 1 3*winsize(2)];  % corrdinate of fitting window, which is 3x3 of neighboring correction window, [xstart xend ystart yend]
            elseif corr_win(4)+winsize(2)>datasize(2)
                fit_win=[datasize(1)-3*winsize(1)+1 datasize(1) datasize(2)-3*winsize(2)+1 datasize(2)];
            else
                fit_win=[datasize(1)-3*winsize(1)+1 datasize(1) corr_win(3)-winsize(1) corr_win(4)+winsize(1)];
            end
        else
            if corr_win(3)<winsize(2)
                fit_win=[corr_win(1)-winsize(1) corr_win(2)+winsize(1) 1 3*winsize(2)];  % corrdinate of fitting window, which is 3x3 of neighboring correction window, [xstart xend ystart yend]
            elseif corr_win(4)+winsize(2)>datasize(2)
                fit_win=[corr_win(1)-winsize(1) corr_win(2)+winsize(1) datasize(2)-3*winsize(2)+1 datasize(2)];
            else
                fit_win=[corr_win(1)-winsize(1) corr_win(2)+winsize(1) corr_win(3)-winsize(1) corr_win(4)+winsize(1)];
            end
        end
        
        % linear fit and normalization
        ind=squeeze(mean(mean(data(fit_win(1):fit_win(2),fit_win(3):fit_win(4),:),1),2));
       % ind=squeeze(mean(mean(data(corr_win(1):corr_win(2),corr_win(3):corr_win(4),:),1),2));
        x=1:length(ind);
        P = polyfit(x,ind',1);
        for z=1:length(ind)
            outdata(corr_win(1):corr_win(2),corr_win(3):corr_win(4),z)=data(corr_win(1):corr_win(2),corr_win(3):corr_win(4),z)./(P(1)*z+P(2));
        end
        
    end
end
end

