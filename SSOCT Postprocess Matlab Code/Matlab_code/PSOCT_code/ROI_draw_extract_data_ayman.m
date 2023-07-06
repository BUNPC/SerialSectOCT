% this code to overlay the ROI i draw in the mus_images on lipofuscion
% segmentation images and extract the line profile data on crest1/2
% sculs1/2 and post process those excels on my laptop code to average 10
% slices per case


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

%sampleID=["AD_10382_2P" "AD_20832_2P" "AD_20969_2P" "AD_21354_2P"  "CTE_6489_2P" "CTE_6912_2P" "CTE_7019_2P" "NC_6839_2P" "NC_6974_2P" "NC_8095_2P" "NC_8653_2P" "NC_21499_2P"];
%samplesize=["1149" "736";"990" "950"; "988" "902"; "893" "719"; "1082" "997"; "1175" "857"; "1173" "904"; "1081" "808"; "1081" "807"; "986" "845"; "1084" "808"; "1077" "716"];
 %sampleID=["AD_21424_2P" "CTE_8572_2P" ]; %only 2 crest& 1 sculs
 %samplesize=[ "988" "809";"898" "998"]; 
sampleID=["NC_21499_2P"];
samplesize=["1077" "716"];
subject=["radius" "count" "occupation"];
for id = 1:size(sampleID,2)

   datapath=strcat('/projectnb2/npbssmic/ns/Ann_Mckee_samples_10T/',sampleID(id),'/aip/');
   ROI_path=strcat('/projectnb2/npbssmic/ns/Ann_Mckee_samples_10T/ROIs_profile/sulcus-crest/',sampleID(id));
    for zz=1:10 % processing 10 images per sample
    %% segment lipofuscin %%ImageJ%%
        for i = 1:size(subject,2)

            macropath=strcat(datapath,'roi_profile_plot.ijm');
            fid_Macro = fopen(macropath, 'w');
            file_name=strcat(datapath,subject(i),'_slice_',num2str(zz),'.tif');
            fprintf(fid_Macro,'open("%s");\n',file_name);
            fprintf(fid_Macro,'run("Size...", "width=%s height=%s depth=1 average interpolation=Bilinear");\n',samplesize(id,1),samplesize(id,2));
            
            Roi_name=strcat(ROI_path,'/RoiSet_crest1/00',num2str(zz),'.roi');
            fprintf(fid_Macro,'roiManager("Open","%s");\n',Roi_name);
            fprintf(fid_Macro,'roiManager("Select",0);\n');
            fprintf(fid_Macro,'run("Clear Results");\n');
            fprintf(fid_Macro,'profile = getProfile();\n');
            fprintf(fid_Macro,'for (i=0; i<profile.length; i++)\n');
            fprintf(fid_Macro,'setResult("Value", i, profile[i]);\n');
            fprintf(fid_Macro,'updateResults();\n');
            Roi_save=strcat(ROI_path,'/DataSet_crest1');
            fprintf(fid_Macro,'saveAs("Measurements", "%s/000%s_%s.csv");\n',Roi_save,num2str(zz),subject(i));
            fprintf(fid_Macro,'run("Clear Results");\n');
            fprintf(fid_Macro,'roiManager("Deselect");\n');
            fprintf(fid_Macro,'roiManager("Delete");\n');


                Roi_name=strcat(ROI_path,'/RoiSet_crest2/00',num2str(zz),'.roi');
            fprintf(fid_Macro,'roiManager("Open","%s");\n',Roi_name);
            fprintf(fid_Macro,'roiManager("Select",0);\n');
            fprintf(fid_Macro,'run("Clear Results");\n');
            fprintf(fid_Macro,'profile = getProfile();\n');
            fprintf(fid_Macro,'for (i=0; i<profile.length; i++)\n');
            fprintf(fid_Macro,'setResult("Value", i, profile[i]);\n');
            fprintf(fid_Macro,'updateResults();\n');
            Roi_save=strcat(ROI_path,'/DataSet_crest2');
            fprintf(fid_Macro,'saveAs("Measurements", "%s/000%s_%s.csv");\n',Roi_save,num2str(zz),subject(i));
            fprintf(fid_Macro,'run("Clear Results");\n');
            fprintf(fid_Macro,'roiManager("Deselect");\n');
            fprintf(fid_Macro,'roiManager("Delete");\n');


                        Roi_name=strcat(ROI_path,'/RoiSet_sculs1/00',num2str(zz),'.roi');
            fprintf(fid_Macro,'roiManager("Open","%s");\n',Roi_name);
            fprintf(fid_Macro,'roiManager("Select",0);\n');
            fprintf(fid_Macro,'run("Clear Results");\n');
            fprintf(fid_Macro,'profile = getProfile();\n');
            fprintf(fid_Macro,'for (i=0; i<profile.length; i++)\n');
            fprintf(fid_Macro,'setResult("Value", i, profile[i]);\n');
            fprintf(fid_Macro,'updateResults();\n');
            Roi_save=strcat(ROI_path,'/DataSet_sculs1');
            fprintf(fid_Macro,'saveAs("Measurements", "%s/000%s_%s.csv");\n',Roi_save,num2str(zz),subject(i));
            fprintf(fid_Macro,'run("Clear Results");\n');
            fprintf(fid_Macro,'roiManager("Deselect");\n');
            fprintf(fid_Macro,'roiManager("Delete");\n');


                        Roi_name=strcat(ROI_path,'/RoiSet_sculs2/00',num2str(zz),'.roi');
            fprintf(fid_Macro,'roiManager("Open","%s");\n',Roi_name);
            fprintf(fid_Macro,'roiManager("Select",0);\n');
            fprintf(fid_Macro,'run("Clear Results");\n');
            fprintf(fid_Macro,'profile = getProfile();\n');
            fprintf(fid_Macro,'for (i=0; i<profile.length; i++)\n');
            fprintf(fid_Macro,'setResult("Value", i, profile[i]);\n');
            fprintf(fid_Macro,'updateResults();\n');
            Roi_save=strcat(ROI_path,'/DataSet_sculs2');
            fprintf(fid_Macro,'saveAs("Measurements", "%s/000%s_%s.csv");\n',Roi_save,num2str(zz),subject(i));
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
end