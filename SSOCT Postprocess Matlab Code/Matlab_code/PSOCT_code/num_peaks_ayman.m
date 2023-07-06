addpath('/projectnb/npbssmic/s/Matlab_code/fitting_code');
addpath('/projectnb/npbssmic/s/Matlab_code/PostProcessing');
addpath('/projectnb/npbssmic/s/Matlab_code/PSOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code/ThorOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code');


%sampleID=["AD_10382_2P" "AD_20832_2P" "CTE_6489_2P" "CTE_6912_2P" "NC_21499_2P" "NC_6047_2P"];
%subject=["radius" "count" "occupation"];
%area=["crest1" "crest2" "sculs1" "sculs2"];
sampleID=["AD_21354_2P"];
subject=["count"];
area=["sculs2"];

% Import Excel file
  %ROI_path=strcat('/projectnb2/npbssmic/ns/Ann_Mckee_samples_10T/ROIs_profile/sulcus-crest/',sampleID(id));
  %Roi_save=strcat(ROI_path,'/vol',num2str(zz),'/',subject(ii));
  %ROI_area=strcat(ROI_subject,'/',area(kk));
  ROI_sample=strcat('/projectnb2/npbssmic/ns/Ann_Mckee_samples_10T/ROIs_profile/sulcus-crest/',sampleID);
  ROI_subject=strcat(ROI_sample,'/vol','1','/',subject);
  ROI_area=strcat(ROI_subject,'/',area,'.csv');
data = readmatrix(ROI_area);
data = data(2:end, :);
% Split the data into x and y vectors
x = data(:,1);
y = data(:,2);

% Smooth the data using a moving average filter
smooth_y = movmean(y, 3);

% Find the local maxima (peaks)
[pks, locs] = findpeaks(smooth_y, x, 'MinPeakProminence', 0.2, 'MinPeakDistance', 1);

% Check for peaks that are too close together
if length(pks) > 1
    idx = find(diff(locs) < 20 & abs(diff(pks)) < 110);
    locs(idx+1) = [];
    pks(idx+1) = [];
end

% Calculate the quality factor for each peak
Q = zeros(size(pks));
for i = 1:length(pks)
    % Determine the indices of the points to the left and right of the peak
    if i == 1
        left_idx = 1;
        right_idx = find(x > locs(i+1), 1);
    elseif i == length(pks)
        left_idx = find(x < locs(i-1), 1, 'last');
        right_idx = length(x);
    else
        left_idx = find(x < locs(i-1), 1, 'last');
        right_idx = find(x > locs(i+1), 1);
    end
    
    % Calculate the quality factor for this peak
    peak_x = x(locs(i));
    Q(i) = peak_x/(2*(x(right_idx) - x(left_idx)));
end

% Find the index of the peak with the highest quality factor
[~, idx] = max(Q);

% Plot the data with the peaks and the peak with the highest quality factor
figure;
plot(x, y);
hold on;
plot(locs, pks, 'rv');
plot(locs(idx), pks(idx), 'g*', 'MarkerSize', 10);
xlabel('x');
ylabel('y');
legend('Data', 'Peaks', 'Peak with highest Q-factor');


