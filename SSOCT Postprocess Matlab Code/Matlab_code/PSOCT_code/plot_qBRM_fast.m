

function [phi, phi_m, abs_m] = plot_qBRM_fast(filename, ori, ret)
    % generates and saves retardance and phi images 
    % filename - filepath + filename to save
    % phi_axer, r_axer_abs - fitted qBRM data

    % Load colormap values
    load('C:\Projects\SSOCT\MATLAB\cmap.mat');
    phi_for_cwheel=phi_for_cwheel./pi*180;
    %[cmap, phi_for_cwheel] = create_colormap();

    % Create a mask from retardance and Intensity map
%     mask=zeros(size(ref));
    abs_m=zeros(size(ret));
%     mask(ref>0.09)=1;
%     abs_m = imbinarize(mat2gray(ret.*mask), 'adaptive','ForegroundPolarity','bright','Sensitivity',0.5);
    abs_m((ret)>10)=1;
    
    phi = zeros(size(ori,1),size(ori,2),3);
    phi_m = zeros(size(ori,1),size(ori,2),3);

    % Assign colors to phi map for sub-image
    % Determine color of each pixel based on the orientation angle extracted
    for i = 1:((length(phi_for_cwheel)-1)/2)+1 % Only need to compare with first half of phi vector since phi domain is [0, pi]
        mask = (ori >= phi_for_cwheel(i) & ori < phi_for_cwheel(i+1));
        for k = 1:3
            cmap_mat(:,:,k) = cmap(i,k)*ones(size(ori,1),size(ori,2));
        end
        phi = phi + cmap_mat.*mask;
    end 
    
    phi_m = phi.*abs_m; 
    
    % Normalize abs values
%     abs = (ret - min(min(ret)))./ (max(max(ret)) - min(min(ret)));
%     %remove outliers in data and normalize to one
%     abs_hot = abs;
%     cl = prctile(abs_hot(:), [7 99.9]);
%     abs_hot = (abs_hot-cl(1))./(cl(2)-cl(1));
%     abs_hot(abs_hot>1) = 1;
%     abs_hot(abs_hot<0) = 0;
    % create a figure of retardance image with HSV colormap
%     fig = figure();
%     imagesc(abs_hot);
%     colormap(hsv); 
%     axis image;
%     axis off;
    %exportgraphics(fig,[filename, '_abs_hot.tif'], 'Resolution', 352);
    % save generated images
    
    imwrite(phi_m, [filename, '_phi.tif']);
%     abs = uint16(abs.*(2^16 - 1));
%     imwrite(abs, [filename, '_abs.tif']);
%     save([filename, '_abs.mat'], 'ret');
    
end