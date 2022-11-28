function dat=TIFF2MAT(tiffname)
%% read TIFF file as mat
% author: Jiarui Yang
% 02/21/20
    tiff_info = imfinfo(tiffname); % return tiff structure, one element per image
    dat = imread(tiffname, 1) ; % read in first image
    %concatenate each successive tiff to tiff_stack
    for ii = 2 : size(tiff_info, 1)
        temp_tiff = imread(tiffname, ii);
        dat = cat(3 , dat, temp_tiff);
    end
end