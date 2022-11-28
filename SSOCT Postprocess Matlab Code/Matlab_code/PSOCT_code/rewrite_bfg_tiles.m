function[]=rewrite_bfg_tiles(datapath,islice,ntiles)
cd(strcat(datapath,'fitting/vol',num2str(islice)))
for i=1:ntiles
    
    filename=strcat(datapath,'fitting/vol',num2str(islice),'/','bfg-',num2str(islice),'-',num2str(i),'.mat');
%     aip=single(imread(filename(1).name, 1));
    load(filename);bfg=single(bfg);
    tiffname=strcat(datapath,'fitting/vol',num2str(islice),'/','BFG.tif');
    if(i==1)
        t = Tiff(tiffname,'w');
    else
        t = Tiff(tiffname,'a');
    end
    tagstruct.ImageLength     = size(bfg,1);
    tagstruct.ImageWidth      = size(bfg,2);
    tagstruct.SampleFormat    = Tiff.SampleFormat.IEEEFP;
    tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
    tagstruct.BitsPerSample   = 32;
    tagstruct.SamplesPerPixel = 1;
    tagstruct.Compression     = Tiff.Compression.None;
    tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
    tagstruct.Software        = 'MATLAB';
    t.setTag(tagstruct);
    t.write(bfg);
    t.close();
end
