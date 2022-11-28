folder_grid='C:\Users\shuaibin\Downloads\20210630\20210630\50umGrid\SingleImage-06302021-1103-003';
display(strcat('reading- ',  ' grid matrix...'));
file=strcat(folder_grid,'\raw_transf super fine.txt');
format longg
T=readtable(file); 
T=table2cell(T);
N=zeros(2*x+3,y);
for i=1:length(T)
    string_split=strsplit(T{i},' ');
    temp=str2double(string_split);
    if isnan(temp)

    else
        N(i,:)=temp(1:y);
    end
end
X=N(3:x+2,:);
Y=N(x+4:2*x+3,:);

M=zeros(4,x,y);
for i = 1:x
    for j = 1:y
        x_=Y(i,j);y_=X(i,j);%MATLAB row and column is dfferent
        if x_>1 && x_<x && y_>1 && y_<y
            M(1,i,j)=mod(x_,1);M(2,i,j)=mod(y_,1);
            M(3,i,j)=floor(x_);M(4,i,j)=floor(y_);
            %xw=mod(x,1);yw=mod(y,1);
            %xp=floor(x);yp=floor(y);
            %T(j,i)=xw*yw*I(xp,yp)+(1-xw)*yw*I(xp+1,yp)+xw*(1-yw)*I(xp,yp+1)+(1-xw)*(1-yw)*I(xp+1,yp+1);
            %image(i,j)=T(i,j,1)*T(i,j,2)*I(T(i,j,3),T(i,j,4))+(1-T(i,j,1))*T(i,j,2)*I(T(i,j,3)+1,T(i,j,4))+T(i,j,1)*(1-T(i,j,2))*I(T(i,j,3),T(i,j,4)+1)+(1-T(i,j,1))*(1-T(i,j,2))*I(T(i,j,3)+1,T(i,j,4)+1);
        end
    end
end
fileID = fopen(strcat(folder_grid,'\grid matrix.bin'), 'w'); 
raw_data = fwrite(fileID,reshape(M,1,4*x*y),'double');
fclose(fileID);