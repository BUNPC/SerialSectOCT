function Find_FOV_Curvature(folder)
%script for finding FOV curvature
cd(folder);
files=dir('*.dat');
num_files=length(files);
if num_files>1
    display('more than one files, only need one file')
else
    file_split=strsplit(files(1).name,'.');
    file_split2=strsplit(string(file_split(1)),'-');
    z=str2double(file_split2{3});
    x=str2double(file_split2{4});
    y=str2double(file_split2{5});
    curvature=zeros(x,y);
    pixel_size_z=3;
    pixel_size_x=3;

    display(strcat("processing: ",files(1).name));
    fileID = fopen(files(1).name); 
    raw_data = single(fread(fileID,'uint16'))./65535*4;
    fclose(fileID);
    C_line=reshape(raw_data,z,x,y);
    C_line=C_line(:,111:1210,:);

    display("Finding curvature ...");
    [~,z0]=max(C_line(1:z,x/2,y/2));
    for i=1:x
        for j=1:y
            m=max(z0-29,1);
            M=min(z0+29,z);
            [~,locs] = max(C_line(m:M,i,j));
            curvature(i,j)=locs;
        end
    end

%%
%     %fitting
%     format long
%     [X Y] = meshgrid(1:x,1:y);
%     XY(:,:,1)=X;
%     XY(:,:,2)=Y;
%     % Create Objective Function: 
%     surfit = @(B,XY)  B(6)+B(1)*XY(:,:,1)+B(2)*XY(:,:,2)+B(3).*(XY(:,:,1)).^2 + B(4).*(XY(:,:,2)).^2+B(5).*XY(:,:,1).*XY(:,:,2); 
%     % surfit = @(B,XY)  exp(B(1).*XY(:,:,1)) + (1 - exp(B(2).*XY(:,:,2))); 
%     % Do Regression
%     B = lsqcurvefit(surfit, [ 0.1 0.1 0.00001 -0.00001  0.0001 45], XY, curvature, [-1 -1 0.00001 -0.001 -0.0001 0],  [1 1 0.001 -0.00001 0.0001 100])
%     % Calculate Fitted Surface
%     Z = surfit(B,XY); 
    

    %smooth curvature
%     [B,surfit, residual]=Fit_curvature(x,y,curvature);
%     [X, Y] = meshgrid(1:x,1:y);
%     clear XY
%     XY(:,:,1)=X;
%     XY(:,:,2)=Y;
%     curvature=round(surfit(B,XY));
    surface=round(curvature-min(curvature(:)));
%     figure;imagesc(curvature)
    save('surface.mat','surface');

end