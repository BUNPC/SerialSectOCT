folder='/projectnb2/npbssmic/ns/210709_4x4x2_BA44_45_milestone_2P_31_36_slice/';
cd(strcat(folder,'aip'));
k=dir;
n_folder=length(k)-2;
for i=1:n_folder
    i
    cd(folder)
    cd(strcat(folder,'aip/vol',num2str(i)))
    filename0=dir(strcat('channel1-',num2str(i),'.tif')); % c
    imageData1 = double(imread(filename0(1).name, 1));
    
    tiffname=strcat(folder,'channel1-',num2str(i),'.tif');
    t = Tiff(tiffname,'w');
    image=single(imageData1);
    tagstruct.ImageLength     = size(image,1);
    tagstruct.ImageWidth      = size(image,2);
    tagstruct.SampleFormat    = Tiff.SampleFormat.IEEEFP;
    tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
    tagstruct.BitsPerSample   = 32;
    tagstruct.SamplesPerPixel = 1;
    tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
    tagstruct.Compression = Tiff.Compression.None;
    tagstruct.Software        = 'MATLAB';
    t.setTag(tagstruct);
    t.write(image);
    t.close();
    
    filename0=dir(strcat('channel2-',num2str(i),'.tif')); % c
    imageData1 = double(imread(filename0(1).name, 1));
    
    tiffname=strcat(folder,'channel2-',num2str(i),'.tif');
    t = Tiff(tiffname,'w');
    image=single(imageData1);
    tagstruct.ImageLength     = size(image,1);
    tagstruct.ImageWidth      = size(image,2);
    tagstruct.SampleFormat    = Tiff.SampleFormat.IEEEFP;
    tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
    tagstruct.BitsPerSample   = 32;
    tagstruct.SamplesPerPixel = 1;
    tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
    tagstruct.Compression = Tiff.Compression.None;
    tagstruct.Software        = 'MATLAB';
    t.setTag(tagstruct);
    t.write(image);
    t.close();
end