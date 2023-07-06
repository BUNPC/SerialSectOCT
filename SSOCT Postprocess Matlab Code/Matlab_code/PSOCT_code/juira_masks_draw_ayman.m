% this code to overlay the ROI i draw in the mus_images on lipofuscion
% segmentation images and extract the line profile data on crest1/2
% sculs1/2 and post process those excels on my laptop code to average 10
% slices per case
clear all; close all; clc;

% using channel2 of 2PM
addpath('/projectnb/npbssmic/s/Matlab_code/fitting_code');
addpath('/projectnb/npbssmic/s/Matlab_code/PostProcessing');
addpath('/projectnb/npbssmic/s/Matlab_code/PSOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code/ThorOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code');

%thresh=[6000,2500,2500,3000,3000]; %putting a threshhold for each sample to differentiate agarose from sample surface
% sampleID=["NC_6047_2P" "NC_6839_2P" "NC_6974_2P" "NC_7597_2P" "NC_8095_2P"  "NC_8653_2P"  "NC_21499_2P"];
% thresh=[2500; 2500; 3000; 3000; 3000; 3000; 2500];
% sampleID=["AD_10382_2P" "AD_20832_2P" "AD_20969_2P" "AD_21354_2P" "AD_21424_2P" "CTE_6489_2P" "CTE_6912_2P" "CTE_7019_2P" "CTE_7126_2P" "CTE_8572_2P" "NC_6047_2P" "NC_6839_2P" "NC_6974_2P" "NC_7597_2P" "NC_8095_2P"  "NC_8653_2P"  "NC_21499_2P"];

sampleID=["AD_10382" "AD_20832" "AD_20969" "AD_21354"  "CTE_6489" "CTE_6912" "CTE_7019" "NC_6839" "NC_8095" "NC_8653" "NC_21499" "NC_6047" "NC_7597"];
samplesize=["1149" "736";"990" "950"; "988" "902"; "893" "719"; "1082" "997"; "1175" "857"; "1173" "904"; "1081" "808"; "986" "845"; "1084" "808"; "1077" "716";"1086" "810";"990" "997"];
 %sampleID=["AD_21424_2P" "CTE_8572_2P" ]; %only 2 crest& 1 sculs
 %samplesize=[ "988" "809";"898" "998"]; 
%sampleID=["NC_21499"];
%samplesize=["1077" "716"];
subject=["radius" "count" "occupation"];
for id = 1:size(sampleID,2)

   datapath=strcat('/projectnb2/npbssmic/ns/Ann_Mckee_samples_10T/',sampleID(id),'_2P/aip/');
   ROI_path=strcat('/projectnb2/npbssmic/ns/Ann_Mckee_samples_10T/ROIs/sulcus-crest/',sampleID(id));
   datasave=strcat('/projectnb2/npbssmic/ns/Ann_Mckee_samples_10T/ROIs_profile_ayman/ayman_lipo_result_of_juira_masks');
   
    %% segment lipofuscin %%ImageJ%%
        for i = 1:size(subject,2)

            macropath=strcat(datapath,'roi_Jiura_sculs_crest.ijm');
            fid_Macro = fopen(macropath, 'w');
            for zz=1:10
                file_name=strcat(datapath,subject(i),'_slice_',num2str(zz),'.tif');
                fprintf(fid_Macro,'open("%s");\n',file_name);
            end
            fprintf(fid_Macro,'run("Images to Stack", "use");\n');
            fprintf(fid_Macro,'run("Size...", "width=%s height=%s depth=10 average interpolation=Bilinear");\n',samplesize(id,1),samplesize(id,2));
            Roi_name=strcat(ROI_path,'_GM_ref.zip');
            fprintf(fid_Macro,'roiManager("Open","%s");\n',Roi_name);
            for zz=1:10
                 fprintf(fid_Macro,'roiManager("Select",%s);\n',num2str(zz-1));
                 fprintf(fid_Macro,'run("Measure");\n');
            end
            Roi_save=strcat(ROI_path,'/DataSet_crest1');
            fprintf(fid_Macro,'saveAs("Measurements", "%s/%s_%s_GM_ref.csv");\n',datasave,sampleID(id),subject(i));
            fprintf(fid_Macro,'run("Clear Results");\n');
            fprintf(fid_Macro,'roiManager("Deselect");\n');
            fprintf(fid_Macro,'roiManager("Delete");\n');



            for zz=1:10
                file_name=strcat(datapath,subject(i),'_slice_',num2str(zz),'.tif');
                fprintf(fid_Macro,'open("%s");\n',file_name);
            end
            fprintf(fid_Macro,'run("Images to Stack", "use");\n');
            fprintf(fid_Macro,'run("Size...", "width=%s height=%s depth=10 average interpolation=Bilinear");\n',samplesize(id,1),samplesize(id,2));
            Roi_name=strcat(ROI_path,'_GM_sul.zip');
            fprintf(fid_Macro,'roiManager("Open","%s");\n',Roi_name);
            for zz=1:10
                 fprintf(fid_Macro,'roiManager("Select",%s);\n',num2str(zz-1));
                 fprintf(fid_Macro,'run("Measure");\n');
            end
            Roi_save=strcat(ROI_path,'/DataSet_crest1');
            fprintf(fid_Macro,'saveAs("Measurements", "%s/%s_%s_GM_sul.csv");\n',datasave,sampleID(id),subject(i));
            fprintf(fid_Macro,'run("Clear Results");\n');
            fprintf(fid_Macro,'roiManager("Deselect");\n');
            fprintf(fid_Macro,'roiManager("Delete");\n');



             for zz=1:10
                file_name=strcat(datapath,subject(i),'_slice_',num2str(zz),'.tif');
                fprintf(fid_Macro,'open("%s");\n',file_name);
            end
            fprintf(fid_Macro,'run("Images to Stack", "use");\n');
            fprintf(fid_Macro,'run("Size...", "width=%s height=%s depth=10 average interpolation=Bilinear");\n',samplesize(id,1),samplesize(id,2));
            Roi_name=strcat(ROI_path,'_WM_sul.zip');
            fprintf(fid_Macro,'roiManager("Open","%s");\n',Roi_name);
            for zz=1:10
                 fprintf(fid_Macro,'roiManager("Select",%s);\n',num2str(zz-1));
                 fprintf(fid_Macro,'run("Measure");\n');
            end
            Roi_save=strcat(ROI_path,'/DataSet_crest1');
            fprintf(fid_Macro,'saveAs("Measurements", "%s/%s_%s_WM_sul.csv");\n',datasave,sampleID(id),subject(i));
            fprintf(fid_Macro,'run("Clear Results");\n');
            fprintf(fid_Macro,'roiManager("Deselect");\n');
            fprintf(fid_Macro,'roiManager("Delete");\n');



 
             for zz=1:10
                file_name=strcat(datapath,subject(i),'_slice_',num2str(zz),'.tif');
                fprintf(fid_Macro,'open("%s");\n',file_name);
            end
            fprintf(fid_Macro,'run("Images to Stack", "use");\n');
            fprintf(fid_Macro,'run("Size...", "width=%s height=%s depth=10 average interpolation=Bilinear");\n',samplesize(id,1),samplesize(id,2));
            Roi_name=strcat(ROI_path,'_WM_ref.zip');
            fprintf(fid_Macro,'roiManager("Open","%s");\n',Roi_name);
            for zz=1:10
                 fprintf(fid_Macro,'roiManager("Select",%s);\n',num2str(zz-1));
                 fprintf(fid_Macro,'run("Measure");\n');
            end
            Roi_save=strcat(ROI_path,'/DataSet_crest1');
            fprintf(fid_Macro,'saveAs("Measurements", "%s/%s_%s_WM_ref.csv");\n',datasave,sampleID(id),subject(i));
            fprintf(fid_Macro,'run("Clear Results");\n');
            fprintf(fid_Macro,'roiManager("Deselect");\n');
            fprintf(fid_Macro,'roiManager("Delete");\n');





            fprintf(fid_Macro,'close;\n');
            fprintf(fid_Macro,'run("Quit");\n');
            fclose(fid_Macro);
            % call imagej from matlab to run the macro code we just generated
            % above
            system(strcat("xvfb-run -a ", "/projectnb/npbssmic/ns/Fiji/Fiji.app/ImageJ-linux64 --run ",macropath));
        end
end