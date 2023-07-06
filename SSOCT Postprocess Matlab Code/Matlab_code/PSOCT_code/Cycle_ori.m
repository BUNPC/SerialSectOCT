function[result]=Cycle_ori(input,Masque)
result=zeros(size(Masque,2),size(Masque,3));
for i=1:size(Masque,2)
    for j=1:size(Masque,3)
        this_pix_ramp=squeeze(Masque(:,i,j));
        if sum(this_pix_ramp>0)<=1
            result(i,j)=sum(squeeze(input(:,i,j)).*this_pix_ramp);
        else
            start=0;
            this_pix=squeeze(input(:,i,j));
            for k=1:4
                if this_pix_ramp(k)>0 
                    if start==0
                       start=k;
                    end
                    d1=abs(this_pix(start)-this_pix(k)-180);
                    d2=abs(this_pix(start)-this_pix(k));
                    d3=abs(this_pix(start)-this_pix(k)+180);
                    [~,m]=min([d1 d2 d3]);
                    this_pix(k)=this_pix(k)-180*(m-2);
                end
            end
            result(i,j)=sum(this_pix.*this_pix_ramp);
        end
    end
end
end
            