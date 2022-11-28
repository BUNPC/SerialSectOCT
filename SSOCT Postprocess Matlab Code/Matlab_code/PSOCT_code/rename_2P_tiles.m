folder='/projectnb2/npbssmic/ns/Ann_Mckee_samples_20T/Ann_5790_2P/';
source=strcat(folder,'temp1');
cd(source)
files=dir('*.tif');
nfiles=length(files);
for i=1:nfiles
    name=files(i).name;
    tmp=strsplit(name,'_');
    t=tmp{2};
    file_num=str2num(t(1:5))-1;
    
    aip=imread(files(i).name, 1);
    
    tiffname=strcat(folder,'file_',num2str(file_num,'%05.f'),'.tif');
    t = Tiff(tiffname,'w');
    tagstruct.ImageLength     = size(aip,1);
    tagstruct.ImageWidth      = size(aip,2);
    tagstruct.SampleFormat    = 2;
    tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
    tagstruct.BitsPerSample   = 16;
    tagstruct.SamplesPerPixel = 1;
    tagstruct.Compression     = Tiff.Compression.None;
    tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
    tagstruct.Software        = 'MATLAB';
    t.setTag(tagstruct);
    t.write(aip);
    t.close();
    
    aip=imread(files(i).name, 2);
    
    tiffname=strcat(folder,'file_',num2str(file_num,'%05.f'),'.tif');
    t = Tiff(tiffname,'a');
    tagstruct.ImageLength     = size(aip,1);
    tagstruct.ImageWidth      = size(aip,2);
    tagstruct.SampleFormat    = 2;
    tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
    tagstruct.BitsPerSample   = 16;
    tagstruct.SamplesPerPixel = 1;
    tagstruct.Compression     = Tiff.Compression.None;
    tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
    tagstruct.Software        = 'MATLAB';
    t.setTag(tagstruct);
    t.write(aip);
    t.close();
end