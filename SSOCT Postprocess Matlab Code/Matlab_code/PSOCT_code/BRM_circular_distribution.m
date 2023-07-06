% % First, select ROI on orientation image, save ROIs as Fused1.zip or Fused2.zip or
% % Fused3.zip
% % Then, change the file and retfile
datapath='/projectnb/npbssmic/ns/PSOCT-qBRM_sample/sample2/qBRM_orientation/';
% % specify orientation and retardance image name
% orifile='Fused2';
% retfile='Ret2.tif';
% % write imagej macro command
% macropath=strcat(datapath,'circular_plot.ijm');
% fid_Macro = fopen(macropath, 'w');
% file_name=strcat(datapath,orifile,'.tif');
% fprintf(fid_Macro,'open("%s");\n',file_name);
% fprintf(fid_Macro,'roiManager("Open", "%s%s.zip");\n',datapath,orifile);
% fprintf(fid_Macro,'roiManager("Select", newArray(0,1));\n');
% fprintf(fid_Macro,'run("Set Measurements...", "bounding redirect=None decimal=1");\n');
% fprintf(fid_Macro,'roiManager("Measure");\n');
% fprintf(fid_Macro,'saveAs("Results", "%s%s.csv");\n',datapath,orifile);
% fprintf(fid_Macro,'run("Clear Results");\n');
% fprintf(fid_Macro,'roiManager("Deselect");\n');
% fprintf(fid_Macro,'roiManager("Delete");\n');
% fprintf(fid_Macro,'run("Quit");\n');
% fclose(fid_Macro);
% % call imagej from matlab to run the macro code we just generated above
% system(strcat("xvfb-run -a ", "/projectnb/npbssmic/ns/Fiji/Fiji.app/ImageJ-linux64 --run ",macropath));
% % read measurment from csv file
% Data=csvread(strcat(datapath,strcat(orifile,'.csv')),1,1);
% % load orientation and retardance to memory
% ori=single(imread(strcat(datapath,strcat(orifile,'.tif'))));
% ret=single(imread(strcat(datapath,retfile)));
% % for each ROI
% for ii =1:size(Data,1)
%     ROI=ori(Data(ii,2):Data(ii,2)+Data(ii,4),Data(ii,1):Data(ii,1)+Data(ii,3));
%     ROI=ROI./pi*180;
%     ret_ROI=ret(Data(ii,2):Data(ii,2)+Data(ii,4),Data(ii,1):Data(ii,1)+Data(ii,3));
%     bins=-90:2:90;
%     distribution=zeros(length(bins)-1,1);
%     for bin=1:length(bins)-1
%         bin
%         mask=zeros(size(ROI));
%         mask(bins(bin)<=ROI & ROI<bins(bin+1))=1;
%         distribution(bin)=sum(mask(:))*mean(ret_ROI(mask==1)); % weight by mean retardance
%     end
%     distribution=distribution./max(distribution(:));
%     figure;polar([bins(1:end-1),90:2:270]'./180*pi,[distribution;distribution;distribution(1)])
%     title(strcat('ROI',num2str(ii),'qBRM orientation distribution'))
% end
list=[17,18,19,22,23,24];
for ii = 1:6
    orifile=strcat('phi_20x/phi_',num2str(list(ii),'%03d'),'.tif');
    retfile=strcat('ret_20x/ret_',num2str(list(ii),'%03d'),'.tif');
    
    ori=single(imread(strcat(datapath,orifile),19));
    ori=ori./pi*180;
    ret=single(imread(strcat(datapath,retfile),19));
    bins=-90:2:90;
    distribution=zeros(length(bins)-1,1);
    for bin=1:length(bins)-1
        mask=zeros(size(ori));
        mask(bins(bin)<=ori & ori<bins(bin+1))=1;
        distribution(bin)=sum(mask(:))*mean(ret(mask==1)); % weight by mean retardance
    end
    distribution=distribution./max(distribution(:));
    figure(ii);p=polar([0:2:179,180:2:360]'./180*pi,[distribution;distribution;distribution(1)]);hold on
    p.LineWidth=2;p.Color=[1,0,0];
    title(strcat('ROI',num2str(list(ii)),'qBRM orientation distribution'))
end
%%
% First, select ROI on orientation image, save ROIs as Fused1.zip or Fused2.zip or
% Fused3.zip
% Then, change the file and retfile
datapath='/projectnb/npbssmic/ns/PSOCT-qBRM_sample/sample2/';
% specify orientation and retardance image name
orifile='orientation/ori2D2';
retfile='retardance/ret_aip2regi2brm.tif';
% write imagej macro command
macropath=strcat(datapath,'circular_plot.ijm');
fid_Macro = fopen(macropath, 'w');
file_name=strcat(datapath,orifile,'_regi.tif');
fprintf(fid_Macro,'open("%s");\n',file_name);
fprintf(fid_Macro,'roiManager("Open", "%s%s.zip");\n',datapath,orifile);
fprintf(fid_Macro,'roiManager("Select", newArray(0,1,2,3,4,5));\n');
fprintf(fid_Macro,'run("Set Measurements...", "bounding redirect=None decimal=1");\n');
fprintf(fid_Macro,'roiManager("Measure");\n');
fprintf(fid_Macro,'saveAs("Results", "%s%s.csv");\n',datapath,orifile);
fprintf(fid_Macro,'run("Clear Results");\n');
fprintf(fid_Macro,'roiManager("Deselect");\n');
fprintf(fid_Macro,'roiManager("Delete");\n');
fprintf(fid_Macro,'run("Quit");\n');
fclose(fid_Macro);
% call imagej from matlab to run the macro code we just generated above
system(strcat("xvfb-run -a ", "/projectnb/npbssmic/ns/Fiji/Fiji.app/ImageJ-linux64 --run ",macropath));
% read measurment from csv file
Data=csvread(strcat(datapath,strcat(orifile,'.csv')),1,1);
% load orientation and retardance to memory
ori=single(imread(strcat(datapath,strcat(orifile,'_regi.tif'))));
ret=single(imread(strcat(datapath,retfile)));
% for each ROI
for ii =1:size(Data,1)
    ROI=ori(Data(ii,2):Data(ii,2)+Data(ii,4),Data(ii,1):Data(ii,1)+Data(ii,3));
    ret_ROI=ret(Data(ii,2):Data(ii,2)+Data(ii,4),Data(ii,1):Data(ii,1)+Data(ii,3));
    bins=0:5:180;
    distribution=zeros(length(bins)-1,1);
    for bin=1:length(bins)-1
        bin
        mask=zeros(size(ROI));
        mask(bins(bin)<=ROI & ROI<bins(bin+1))=1;
        if sum(mask(:))>0
            distribution(bin)=sum(mask(:))*mean(ret_ROI(mask==1)); % weight by mean retardance
        else
            distribution(bin)=0;
        end
    end
    distribution=distribution./max(distribution(:));
    figure(ii);p=polar([bins(1:end-1),180:5:360]'./180*pi-pi/2,[distribution;distribution;distribution(1)]);
    p.LineWidth=2;p.Color=[0,1,0]
%     title(strcat('ROI',num2str(ii),'PSOCT orientation distribution'))
end
