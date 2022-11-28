function MAT2TIFF(dat,tiffname)
    dat=uint8(255*mat2gray(dat));
    for i=1:size(dat,3)
        t = Tiff(tiffname,'a');
        image=squeeze(dat(:,:,i));
        tagstruct.ImageLength     = size(image,1);
        tagstruct.ImageWidth      = size(image,2);
        tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
        tagstruct.BitsPerSample   = 8;
        tagstruct.SamplesPerPixel = 1;
        tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
        tagstruct.Compression = Tiff.Compression.None;
        tagstruct.Software        = 'MATLAB';
        t.setTag(tagstruct);
        t.write(image);
        t.close();
    end
end
