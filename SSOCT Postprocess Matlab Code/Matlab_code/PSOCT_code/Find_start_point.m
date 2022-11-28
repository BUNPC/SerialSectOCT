function[z0]=Find_start_point(z,m)
l=size(z,2);
for i=l:-1:1
    if z(i)-m<0
        z0=i;
        break;
    end
end