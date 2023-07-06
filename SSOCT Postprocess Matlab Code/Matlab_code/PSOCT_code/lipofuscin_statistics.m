%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% generating lipofuscin statistics based on previous ROI definition
% CTE8572 only first three slice is useful. others have bad focus and
% surface, probably stage malfunction during imaging
% NC6047 start from slice3
addpath('/projectnb/npbssmic/s/Matlab_code/fitting_code');
addpath('/projectnb/npbssmic/s/Matlab_code/PostProcessing');
addpath('/projectnb/npbssmic/s/Matlab_code/PSOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code/ThorOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code');

sampleID=["AD_10382_2P" "AD_20832_2P" "AD_20969_2P" "AD_21354_2P" "AD_21424_2P" "CTE_6489_2P" "CTE_6912_2P" "CTE_7019_2P" "CTE_7126_2P" "CTE_8572_2P"  "NC_6047_2P" "NC_6839_2P"  "NC_7597_2P" "NC_8095_2P"  "NC_21499_2P" "NC_8653_2P"];% "NC_6974_2P" 
Data=zeros(size(sampleID,2),4,10,2);
for id = 1:size(sampleID,2)
    datapath=strcat('/projectnb2/npbssmic/ns/Ann_Mckee_samples_10T/',sampleID(id),'/aip/');
    cd(datapath)
    fprintf(strcat("processing " ,datapath,"\n"))
    t=strsplit(sampleID(id),'_');
    OCTpath=strcat('/projectnb2/npbssmic/ns/Ann_Mckee_samples_10T/',t(1),'_',t(2),'/');
    if isfolder(strcat(OCTpath,'fitting_10x_new'))
        OCTpath=strcat(OCTpath,'fitting_10x_new/');
    else
        OCTpath=strcat(OCTpath,'fitting_10x/');
    end
    if isfile(strcat(OCTpath,'mus5.mat'))
        load(strcat(OCTpath,'mus5.mat'))
    else
        load(strcat(OCTpath,'mus5_ds10x.mat'))
    end
    if exist('MosaicFinal','var')
        mus=MosaicFinal;
        clear MosaicFinal
    end
    [xx,yy]=size(mus);
    clear mus
    ROI_path=strcat('/projectnb2/npbssmic/ns/Ann_Mckee_samples_10T/ROIs/sulcus-crest/',t(1),"_",t(2));
    %% generating macro files
    macropath=strcat(datapath,'lipofuscin_statistics.ijm');
    fid_Macro = fopen(macropath, 'w');
    zstop=10;
    if sampleID(id)=="NC_6047_2P"
        zstop=12;
    end
    for zz =1:zstop
        file_name=strcat(datapath,'occupation_slice_',num2str(zz),'.tif');
        fprintf(fid_Macro,'open("%s");\n',file_name);
    end
    fprintf(fid_Macro,'run("Images to Stack", "use");\n');
    fprintf(fid_Macro,'run("Scale...", "x=- y=- z=1.0 width=%d height=%d depth=10 interpolation=Bilinear average process create");\n',yy,xx);
    fprintf(fid_Macro,'selectWindow("Stack");;\n');
    fprintf(fid_Macro,'close;\n');
    
    fprintf(fid_Macro,'roiManager("Open", "%s_GM_ref.zip");\n',ROI_path);
    fprintf(fid_Macro,'roiManager("Select", newArray(0,1,2,3,4,5,6,7,8,9));\n');
    fprintf(fid_Macro,'roiManager("Measure");\n');
    fprintf(fid_Macro,'run("Set Measurements...", "mean stack redirect=None decimal=5");\n');
    fprintf(fid_Macro,'saveAs("Results", "%s_GM_ref.csv");\n',ROI_path);
    fprintf(fid_Macro,'run("Clear Results");\n');
    fprintf(fid_Macro,'roiManager("Deselect");\n');
    fprintf(fid_Macro,'roiManager("Delete");\n');
    
    fprintf(fid_Macro,'roiManager("Open", "%s_GM_sul.zip");\n',ROI_path);
    fprintf(fid_Macro,'roiManager("Select", newArray(0,1,2,3,4,5,6,7,8,9));\n');
    fprintf(fid_Macro,'roiManager("Measure");\n');
    fprintf(fid_Macro,'run("Set Measurements...", "mean stack redirect=None decimal=5");\n');
    fprintf(fid_Macro,'saveAs("Results", "%s_GM_sul.csv");\n',ROI_path);
    fprintf(fid_Macro,'run("Clear Results");\n');
    fprintf(fid_Macro,'roiManager("Deselect");\n');
    fprintf(fid_Macro,'roiManager("Delete");\n');
    
    fprintf(fid_Macro,'roiManager("Open", "%s_WM_ref.zip");\n',ROI_path);
    fprintf(fid_Macro,'roiManager("Select", newArray(0,1,2,3,4,5,6,7,8,9));\n');
    fprintf(fid_Macro,'roiManager("Measure");\n');
    fprintf(fid_Macro,'run("Set Measurements...", "mean stack redirect=None decimal=5");\n');
    fprintf(fid_Macro,'saveAs("Results", "%s_WM_ref.csv");\n',ROI_path);
    fprintf(fid_Macro,'run("Clear Results");\n');
    fprintf(fid_Macro,'roiManager("Deselect");\n');
    fprintf(fid_Macro,'roiManager("Delete");\n');
    
    fprintf(fid_Macro,'roiManager("Open", "%s_WM_sul.zip");\n',ROI_path);
    fprintf(fid_Macro,'roiManager("Select", newArray(0,1,2,3,4,5,6,7,8,9));\n');
    fprintf(fid_Macro,'roiManager("Measure");\n');
    fprintf(fid_Macro,'run("Set Measurements...", "mean stack redirect=None decimal=5");\n');
    fprintf(fid_Macro,'saveAs("Results", "%s_WM_sul.csv");\n',ROI_path);
    fprintf(fid_Macro,'run("Clear Results");\n');
    fprintf(fid_Macro,'roiManager("Deselect");\n');
    fprintf(fid_Macro,'roiManager("Delete");\n');
    
    fprintf(fid_Macro,'run("Quit");\n');
    fclose(fid_Macro);
    % call imagej from matlab to run the macro code we just generated
    % above
    system(strcat("xvfb-run -a ", "/projectnb/npbssmic/ns/Fiji/Fiji.app/ImageJ-linux64 --run ",macropath));
        
    %%
    Data(id,1,:,:)=csvread(strcat(ROI_path,'_GM_sul.csv'),1,1);
    Data(id,2,:,:)=csvread(strcat(ROI_path,'_GM_ref.csv'),1,1);
    Data(id,3,:,:)=csvread(strcat(ROI_path,'_WM_sul.csv'),1,1);
    Data(id,4,:,:)=csvread(strcat(ROI_path,'_WM_ref.csv'),1,1);
end
save('/projectnb2/npbssmic/ns/Ann_Mckee_samples_10T/occupation.mat','Data')

figure;bar([1:5,7:11,13:18],mean(Data(:,1,:,1)./Data(:,2,:,1),3));hold on
er=errorbar([1:5,7:11,13:18],mean(Data(:,1,:,1)./Data(:,2,:,1),3), std(Data(:,1,:,1)./Data(:,2,:,1),1,3)/2, std(Data(:,1,:,1)./Data(:,2,:,1),1,3)/2);
er.LineStyle='None';
xticks([1:5,7:11,13:18])
xticklabels(sampleID)
xtickangle(90)
title('GM lipofuscin density sulci/crest')

figure;bar([1:5,7:11,13:18],mean(Data(:,4,:,1),3));hold on
er=errorbar([1:5,7:11,13:18],mean(Data(:,4,:,1),3), std(Data(:,4,:,1),1,3)/2, std(Data(:,4,:,1),1,3)/2);
er.LineStyle='None';
xticks([1:5,7:11,13:18])
xticklabels(sampleID)
xtickangle(90)
title('WM lipofuscin density sulci')
ylabel('% area of lipo')

figure;bar([1:5,7:11,13:18],mean(Data(:,3,:,1)./Data(:,4,:,1),3));hold on
er=errorbar([1:5,7:11,13:18],mean(Data(:,3,:,1)./Data(:,4,:,1),3), std(Data(:,3,:,1)./Data(:,4,:,1),1,3)/2, std(Data(:,3,:,1)./Data(:,4,:,1),1,3)/2);
er.LineStyle='None';
xticks([1:5,7:11,13:18])
xticklabels(sampleID)
xtickangle(90)
title('WM lipofuscin density sulci/crest')


GM=mean(Data(:,1,:,1)./Data(:,2,:,1),3);
figure;bar(1:3,[mean(GM(1:5)),mean(GM(6:10)),mean(GM(11:16))]);hold on
er=errorbar(1:3,[mean(GM(1:5)),mean(GM(6:10)),mean(GM(11:16))],[std(GM(1:5)),std(GM(6:10)),std(GM(11:16))]/2, [std(GM(1:5)),std(GM(6:10)),std(GM(11:16))]/2);
er.LineStyle='None';
xticklabels({'AD','CTE','NC'})
title('GM lipofuscin density sulci/crest')
% ratio, mean group
AD=GM(1:5);
CTE=GM(6:10);
NC=GM(11:16);
% ratio, all data
AD=Data(1:5,3,:,1)./Data(1:5,4,:,1);
CTE=Data(6:10,3,:,1)./Data(6:10,4,:,1);
NC=Data(11:16,3,:,1)./Data(11:16,4,:,1);
% all data
AD=Data(1:5,4,:,1);
CTE=Data(6:10,4,:,1);
NC=Data(11:16,4,:,1);


 %% one-way ANOVA
hogg = [AD(:);CTE(:);NC(:)];
group1 = repmat({'AD'},length(AD(:)),1);
group2 = repmat({'CTE'},length(CTE(:)),1);
group3 = repmat({'NC'},length(NC(:)),1);
Group = [group1;group2;group3];
[p, tbl, stats] = anova1(hogg, Group);
p
boxplot(hogg, Group, 'Notch', 'off');
% ylim([0,1.7])
title('WM lipofuscin density crest')
set(gca, 'FontSize', 20);
ylabel('% area of lipo')
%ylim([0.01 0.25]);
%yticks([10 12.5 15 17.5 20]);
% ylim([3.5*10^(-4) 6.5*10^(-4)]);
%%
%[c,~,~,gnames] = multcompare(stats);

    