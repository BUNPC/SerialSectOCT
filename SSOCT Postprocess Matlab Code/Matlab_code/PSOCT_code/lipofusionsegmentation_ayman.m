%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% first step upload the samples
%"background suppression" 
%   1-calculate threshold for differeniating agrous from sample surface
%   2-make mask that agrous=1; sample=0
%   3- if image(mask>0)= threshold
% now background = thershold value and the sample is the same "normalize"
% back ground=1 and sample is greater
%"Lipofusion segmentation"
% high value ==1  // low value ==0

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% generating lipofuscin distribution based on 2PM images
% using channel2 of 2PM
addpath('/projectnb/npbssmic/s/Matlab_code/fitting_code');
addpath('/projectnb/npbssmic/s/Matlab_code/PostProcessing');
addpath('/projectnb/npbssmic/s/Matlab_code/PSOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code/ThorOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code');

% sampleID=["AD_10382_2P" "AD_20832_2P" "AD_20969_2P" "AD_21354_2P" "AD_21424_2P"];
%sampleID=["CTE_6489_2P" "CTE_6912_2P" "CTE_7019_2P" "CTE_7126_2P" "CTE_8572_2P"];
sampleID=["NC_301181_2P"];
thresh=[3000];
%thresh=[6000,2500,2500,3000,3000]; %putting a threshhold for each sample to differentiate agarose from sample surface
% sampleID=["NC_6047_2P" "NC_6839_2P" "NC_6974_2P" "NC_7597_2P" "NC_8095_2P"  "NC_8653_2P"  "NC_21499_2P"];
% thresh=[2500; 2500; 3000; 3000; 3000; 3000; 2500];
% sampleID=["AD_10382_2P" "AD_20832_2P" "AD_20969_2P" "AD_21354_2P" "AD_21424_2P" "CTE_6489_2P" "CTE_6912_2P" "CTE_7019_2P" "CTE_7126_2P" "CTE_8572_2P" "NC_6047_2P" "NC_6839_2P" "NC_6974_2P" "NC_7597_2P" "NC_8095_2P"  "NC_8653_2P"  "NC_21499_2P"];
for id = 1:size(sampleID,2)
    datapath=strcat('/projectnb2/npbssmic/ns/Ann_Mckee_samples_10T/',sampleID(id),'/aip/');
  agar_thresh=thresh(id); % threshold to differentiate agarose. Double check for each sample

    for zz=1:24 % processing 10 images per sample
    %% smooth background  %%matlab%%
        image=single(imread(strcat(datapath,'channel2-',num2str(zz),'.tif'),1));
        mask=ones(size(image));
        mask(image>agar_thresh)=0;
        image(mask>0)=agar_thresh;
        SaveTiff(image,1,strcat(datapath,'channel2_',num2str(zz),'_bg_cleared.tif'));

    %% segment lipofuscin %%ImageJ%%
        macropath=strcat(datapath,'lipofuscin.ijm');
        fid_Macro = fopen(macropath, 'w');
        file_name=strcat(datapath,'channel2_',num2str(zz),'_bg_cleared.tif');
        fprintf(fid_Macro,'open("%s");\n',file_name);
        fprintf(fid_Macro,'run("Duplicate...", " ");\n');
        fprintf(fid_Macro,'run("Gaussian Blur...", "sigma=50");\n');
        nominator=strcat('channel2_',num2str(zz),'_bg_cleared.tif');
        denominator=strcat('channel2_',num2str(zz),'_bg_cleared-1.tif');
        fprintf(fid_Macro,'imageCalculator("Divide create", "%s","%s");\n',nominator,denominator);
%         normed_path=strcat(datapath,'channel2_',num2str(zz),'_normed.tif');
%         fprintf(fid_Macro,'saveAs("Tiff", "%s");\n',normed_path);
        fprintf(fid_Macro,'setThreshold(1.4000, 1000000);\n'); %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% using lower bound 1.3.
        fprintf(fid_Macro,'setOption("BlackBackground", true);\n');
        fprintf(fid_Macro,'run("Convert to Mask");setAutoThreshold("Huang dark no-reset");\n');
        fprintf(fid_Macro,'setOption("ScaleConversions",true);\n');
        fprintf(fid_Macro,'run("8-bit");\n');
        seg_path=strcat(datapath,'channel2_',num2str(zz),'_seg.tif');
        fprintf(fid_Macro,'saveAs("Tiff", "%s");\n',seg_path);
        fprintf(fid_Macro,'close;\n');
        fprintf(fid_Macro,'close;\n');
        fprintf(fid_Macro,'close;\n');
        fprintf(fid_Macro,'run("Quit");\n');
        fclose(fid_Macro);
        % call imagej from matlab to run the macro code we just generated
        % above
        system(strcat("xvfb-run -a ", "/projectnb/npbssmic/ns/Fiji/Fiji.app/ImageJ-linux64 --run ",macropath));
        % remove the boundary artifacts by using dilation and save
        % segmentation
        image=single(imread(strcat(datapath,'channel2_',num2str(zz),'_seg.tif'),1));
        mask=imdilate(mask,strel('disk',50));
        image(mask>0)=0;
        SaveTiff(image,1,strcat(datapath,'channel2_',num2str(zz),'_ayman_seg.tif'));
    
    %% calculating lipofuscin distributions
    cd(datapath)
    fprintf(strcat("processing " ,datapath, "\n"))
%     for zz=11:12 % process 1-10 depth
        % load segementation image
        image=single(imread(strcat(datapath,'channel2_',num2str(zz),'_ayman_seg.tif')));
        
        kernel=100;
        X=size(image,1);
        Y=size(image,2);
        size_map=[];
        density_map=[];
        occupation_map=[];
        ii=0;
        % sliding window, window size = kernel
        for x=1:round(kernel/2):X-kernel
            ii=ii+1; jj=0;
            for y=1:round(kernel/2):Y-kernel
                jj=jj+1;
                % take the current ROI defined by the kernel size
                area=image(x:x+kernel,y:y+kernel);
                % using MATLAB functions bwconncomp and NumObjects to count
                % lipofusion particles
                cc=bwconncomp(area); N=cc.NumObjects; pixels=sum(sum(area))/255;
                for pp =1:cc.NumObjects
                    [row,col]=ind2sub([kernel+1,kernel+1],cc.PixelIdxList{pp});
                    if any(row==1) || any(row==kernel+1) || any(col==1) || any(col==kernel+1)
                        pixels=pixels-length(row);
                        N=N-1;
                    % remove small lipofuscin
                    elseif length(cc.PixelIdxList{pp})<10
                        pixels=pixels-length(row); N=N-1;
                    end
                end
                if N>0
                    size_map(ii,jj)=sqrt(pixels/N*4/pi);
                else
                    size_map(ii,jj)=0;
                end
                density_map(ii,jj) = cc.NumObjects*25;
                occupation_map(ii,jj)=sum(sum(area))/255/100;
            end
        end
        % save distribution maps
        SaveTiff(size_map,1,strcat('radius_slice_',num2str(zz),'.tif'));
        SaveTiff(density_map,1,strcat('count_slice_',num2str(zz),'.tif'));
        SaveTiff(occupation_map,1,strcat('occupation_slice_',num2str(zz),'.tif'));
%         figure;imagesc(size_map)
%         title(strcat('large lipofuscin radius distribution(um) slice',num2str(zz)))
%         colorbar();
%         caxis([3.5 7]);
%         % density distribution
%         figure;imagesc(density_map)
%         title(strcat('lipofuscin number density per mm^2 slice',num2str(zz)))
%         colorbar();
%         caxis([0 2500]);
%         % occupation map
%         figure;imagesc(occupation_map)
%         title(strcat('lipofuscin occupation area(%) slice',num2str(zz)))
%         colorbar();
%         caxis([0 15]);
    end
end