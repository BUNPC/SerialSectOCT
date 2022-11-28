
for i=1:size(Ref,3)
    mip=single(squeeze(Ref(:,:,i)));
    tiffname=strcat('1_vol.tif');
    t = Tiff(tiffname,'a');
    tagstruct.ImageLength     = size(mip,1);
    tagstruct.ImageWidth      = size(mip,2);
    tagstruct.SampleFormat    = Tiff.SampleFormat.IEEEFP;
    tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
    tagstruct.BitsPerSample   = 32;
    tagstruct.SamplesPerPixel = 1;
    tagstruct.Compression     = Tiff.Compression.None;
    tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
    tagstruct.Software        = 'MATLAB';
    t.setTag(tagstruct);
    t.write(mip);
    t.close();
end