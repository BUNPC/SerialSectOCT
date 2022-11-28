function[k1,k2,b1,b2]=mus_model(Gallyas_GM,COPA_GM,Gallyas_WM,mus_GM,mus_WM,lambda,W)
fun_GM = @(p,xdata,ydata)p(1).*xdata+p(2).*ydata+p(3);
fun_WM = @(p,xdata)p(1).*xdata+p(2);

Loss_fun = @(p,xdata1,ydata1,xdata2,zdata1,zdata2)(fun_GM([p(1) p(2) p(3)],xdata1,ydata1)-zdata1).^2+...
     W.*(fun_WM([p(1) p(4)],xdata2)-zdata2).^2+...
     lambda.*(p(3)-p(4))^2;
 
step_size=0.05;
step=[0 0 0 0];
loss=Loss_fun(p0,Gallyas_GM,COPA_GM,Gallyas_WM,mus_GM,mus_WM);
param=[7 2 2 2];
while loss>0.01
    dif_k1=Loss_fun(param+step_size.*[1,0 0 0],Gallyas_GM,COPA_GM,Gallyas_WM,mus_GM,mus_WM)-loss;
    if abs(dif_k1)>0.01
        step=step+[-1 0 0 0].*dif_k1/abs(dif_k1);
    end
    dif_k2=Loss_fun(param+step_size.*[0,1 0 0],Gallyas_GM,COPA_GM,Gallyas_WM,mus_GM,mus_WM)-loss;
    if abs(dif_k2)>0.01
        step=step+[0 -1 0 0].*dif_k2/abs(dif_k2);
    end
    dif_b1=Loss_fun(param+step_size.*[0,0 1 0],Gallyas_GM,COPA_GM,Gallyas_WM,mus_GM,mus_WM)-loss;
    if abs(dif_b1)>0.01
        step=step+[0 0 -1 0].*dif_b1/abs(dif_b1);
    end
    dif_b2=Loss_fun(param+step_size.*[0,0 0 1],Gallyas_GM,COPA_GM,Gallyas_WM,mus_GM,mus_WM)-loss;
    if abs(dif_b2)>0.01
        step=step+[0 0 0 -1].*dif_b2/abs(dif_b2);
    end
    
    param=param+step*step_size;
    loss=Loss_fun(param,Gallyas_GM,COPA_GM,Gallyas_WM,mus_GM,mus_WM);
end

