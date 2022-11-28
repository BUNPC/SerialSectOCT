%remove super high/low mus in cerebellum
mus=mub;
mus_sm=zeros(size(mus));
for i=1:200
    for j=1:200
        v=mus(j,i);
        x1=max(1,j-10);x2=min(200,j+10);
        y1=max(1,i-10);y2=min(200,i+10);
        area=mus(x1:x2,y1:y2);
        
           m=mean(area(:));
           s=std(area(:));
        
        
        if abs(v-m)>0.1*s
            mus_sm(j,i)=m;
        else
            mus_sm(j,i)=mus(j,i);
        end
    end
end
figure;imagesc(mus_sm)
figure;imagesc(mus)

format long
x=1100;y=1100;
[X Y] = meshgrid(1:x,1:y);
XY(:,:,1)=X;
XY(:,:,2)=Y;
% Create Objective Function: 
surfit = @(B,XY)  B(6)+B(1)*XY(:,:,1)+B(2)*XY(:,:,2)+B(3).*(XY(:,:,1)).^2 + B(4).*(XY(:,:,2)).^2+B(5).*XY(:,:,1).*XY(:,:,2); 
% surfit = @(B,XY)  exp(B(1).*XY(:,:,1)) + (1 - exp(B(2).*XY(:,:,2))); 
% Do Regression
B = lsqcurvefit(surfit, [ 0.1 0.1 0.00001 -0.00001  0.0001 45], XY, double(surface_1), [-1 -1 0.00001 -0.001 -0.0001 0],  [1 1 0.001 -0.00001 0.0001 100])
% Calculate Fitted Surface
%%

[X Y] = meshgrid(1:x,1:y);
XY(:,:,1)=X;
XY(:,:,2)=Y;
Z = surfit(B,XY); 
figure;imagesc(Z)