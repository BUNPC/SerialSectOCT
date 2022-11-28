function[]=rewrite_mus_tiles(datapath,islice,ntiles)
cd(strcat(datapath,'fitting/vol',num2str(islice)))
for i=1:ntiles
    
    filename=strcat('mus-',num2str(islice),'-',num2str(i),'.mat');
    load(filename);
    us=single(us);
    tiffname=strcat(datapath,'fitting/vol',num2str(islice),'/','MUS.tif');
    if(i==1)
        t = Tiff(tiffname,'w');
    else
        t = Tiff(tiffname,'a');
    end
    tagstruct.ImageLength     = size(us,1);
    tagstruct.ImageWidth      = size(us,2);
    tagstruct.SampleFormat    = Tiff.SampleFormat.IEEEFP;
    tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
    tagstruct.BitsPerSample   = 32;
    tagstruct.SamplesPerPixel = 1;
    tagstruct.Compression     = Tiff.Compression.None;
    tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
    tagstruct.Software        = 'MATLAB';
    t.setTag(tagstruct);
    t.write(us);
    t.close();
end
