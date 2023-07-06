
% using channel2 of 2PM
addpath('/projectnb/npbssmic/s/Matlab_code/fitting_code');
addpath('/projectnb/npbssmic/s/Matlab_code/PostProcessing');
addpath('/projectnb/npbssmic/s/Matlab_code/PSOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code/ThorOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code');

sampleID=["AD_10382_2P" "AD_20832_2P" "AD_20969_2P" "AD_21354_2P" "AD_21424_2P"];
%sampleID=["CTE_6489_2P" "CTE_6912_2P" "CTE_7019_2P" "CTE_7126_2P" "CTE_8572_2P"];


%thresh=[6000,2500,2500,3000,3000]; %putting a threshhold for each sample to differentiate agarose from sample surface
% sampleID=["NC_6047_2P" "NC_6839_2P" "NC_6974_2P" "NC_7597_2P" "NC_8095_2P"  "NC_8653_2P"  "NC_21499_2P"];
% thresh=[2500; 2500; 3000; 3000; 3000; 3000; 2500];
% sampleID=["AD_10382_2P" "AD_20832_2P" "AD_20969_2P" "AD_21354_2P" "AD_21424_2P" "CTE_6489_2P" "CTE_6912_2P" "CTE_7019_2P" "CTE_7126_2P" "CTE_8572_2P" "NC_6047_2P" "NC_6839_2P" "NC_6974_2P" "NC_7597_2P" "NC_8095_2P"  "NC_8653_2P"  "NC_21499_2P"];

%for id = 1:size(sampleID,2)
for id=1:2
   datapath=strcat('/projectnb2/npbssmic/ns/Ann_Mckee_samples_10T/',sampleID(id),'/aip/');


   for zz=1:2 % processing 10 images per sample
    %% segment lipofuscin %%ImageJ%%
        macropath=strcat(datapath,'contrast_auto_fire.ijm');
        fid_Macro = fopen(macropath, 'w');
        file_name=strcat(datapath,'count_slice_',num2str(zz),'.tif');
        fprintf(fid_Macro,'open("%s");\n',file_name);
        fprintf(fid_Macro,'run("Fire");\n');
        fprintf(fid_Macro,'run("Enhance Contrast", "saturated=0.35");\n');
        seg_path=strcat(datapath,'count_slice_',num2str(zz),'_fire','.png');
        fprintf(fid_Macro,'saveAs("PNG", "%s");\n',seg_path);
        fprintf(fid_Macro,'close;\n');
        fprintf(fid_Macro,'run("Quit");\n');
        fclose(fid_Macro);
        % call imagej from matlab to run the macro code we just generated
        % above
        system(strcat("xvfb-run -a ", "/projectnb/npbssmic/ns/Fiji/Fiji.app/ImageJ-linux64 --run ",macropath));

   end
end