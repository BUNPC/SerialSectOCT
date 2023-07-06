%%this code to draw juira mask on lipofuscion sigmentation images
%%radius&count&occupation and then extract those images as well as their
%%mean value in excel file of this masked area only

addpath('/projectnb/npbssmic/s/Matlab_code/fitting_code');
addpath('/projectnb/npbssmic/s/Matlab_code/PostProcessing');
addpath('/projectnb/npbssmic/s/Matlab_code/PSOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code/ThorOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code');

%sampleID=["AD_10382" "AD_20832" "AD_20969" "AD_21354" "AD_21424" "CTE_6489" "CTE_6912" "CTE_7019" "CTE_8572" "CTE_7126" "NC_6839" "NC_8095" "NC_21499" "NC_6047" "NC_7597"];
sampleID=["AD_10382"]; 
subject=["radius" "count" "occupation"];

% Create a cell array to store the averaged results
averagedResults = cell(0);

for id = 1:size(sampleID,2)

   datapath=strcat('/projectnb2/npbssmic/ns/Ann_Mckee_samples_10T/',sampleID(id),'_2P/aip/');
   Mask_path=strcat('/projectnb2/npbssmic/ns/Ann_Mckee_samples_10T/cortical thickness/data/',sampleID(id));
   Data_save=strcat('/projectnb2/npbssmic/ns/Ann_Mckee_samples_10T/ROIs_profile/sulcus-crest/',sampleID(id));
   Data_save_combine=strcat('/projectnb2/npbssmic/ns/Ann_Mckee_samples_10T/ROIs_profile/sulcus-crest/');
   
   % Initialize variables to store cumulative values for averaging
   totalNonZeroPixels = zeros(1, size(subject,2));
   totalMeanValue = zeros(1, size(subject,2));
   
   for zz=1:10 % processing only the first slice
       
    for i = 1:size(subject,2)
        
            image_file_name=strcat(datapath,subject(i),'_slice_',num2str(zz),'.tif');
            mask_file_name=strcat(Mask_path,'_mask_supra.tif');
            
            image = imread(image_file_name);
            mask = imread(mask_file_name,zz);

            % Resize musimage to match the size of maskimage
            image = imresize(image, size(mask));

            % Convert mask to binary (0 or 1) by thresholding
            binaryMask = mask > 0;
            maskedImage=image.*double(binaryMask);

            % Save the masked region as a TIFF image
            generatedFilename = fullfile(Data_save+'_2P/Data_jiura_mask/',subject(i)+'_slice_'+num2str(zz)+'_mask_supra.tif');
            SaveTiff(maskedImage,1, generatedFilename);

            % Calculate the number of non-zero pixels
            numNonZeroPixels = nnz(maskedImage);
            
            % Calculate the values of non-zero pixels
            nonZeroValues = maskedImage(maskedImage ~= 0);
            
            % Calculate the mean of non-zero pixel values
            meanValue =mean(nonZeroValues);
            
            % Accumulate values for averaging
            totalNonZeroPixels(i) = totalNonZeroPixels(i) + numNonZeroPixels;
            totalMeanValue(i) = totalMeanValue(i) + meanValue;
    end
   end
   
   % Calculate the average values for each subject
   averageNonZeroPixels = totalNonZeroPixels / (10);
   averageMeanValue = totalMeanValue / (10);
   
   % Store the averaged results in the cell array
   for i = 1:size(subject, 2)
       averagedResult = {sampleID(id), subject(i), averageNonZeroPixels(i), averageMeanValue(i)};
       averagedResults = [averagedResults; averagedResult];
   end
end

% Create a table from the cell array of averaged results
averagedTable = cell2table(averagedResults, 'VariableNames', {'Sample_ID', 'Subject', 'Average_Number_of_NonZero_Pixels', 'Average_Mean_Value'});

% % Save the averaged results to an Excel file
% excelFilename = fullfile(Data_save_combine, 'averaged_supra.xlsx');
% writetable(averagedTable, excelFilename, 'Sheet', 1);