folder  = '/projectnb2/npbssmic/ns/Ann_Mckee_samples_20T/NC_8095/';
cd(folder)
% add subfunctions for the script. Change directory if not running on BU SCC
addpath('/projectnb/npbssmic/s/Matlab_code/fitting_code');
addpath('/projectnb/npbssmic/s/Matlab_code/PostProcessing');
addpath('/projectnb/npbssmic/s/Matlab_code/PSOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code/ThorOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code');

AIP=dir(strcat(folder,'/aip/aip*.tif'));
nslice=length(AIP);
for islice = 1:nslice
    islice
    cd(strcat(folder,'/aip'))
    aip=single(imread(strcat('aip',num2str(islice),'.tif'), 1));
    aip10x=imresize(aip,0.1);
    aip4x=imresize(aip,0.25);
    mask10x=zeros(size(aip10x));
    mask4x=zeros(size(aip4x));
    mask4x(aip4x>0.012)=1;
    mask10x(aip10x>0.012)=1;
    %% masking 10x birefringence fitting
    cd(strcat(folder,'/fitting_10x'))
    if isfile(strcat('bfg',num2str(islice),'.tif'))
%         bfg10x=single(imread(strcat('bfg',num2str(islice),'.tif'), 1));
        load(strcat('bfg',num2str(islice),'.mat'));
        bfg10x=MosaicFinal;
        bfg10x=single(bfg10x.*mask10x(1:size(bfg10x,1),1:size(bfg10x,2)));
%         save(strcat('bfg',num2str(islice),'.mat'),'bfg10x')
        tiffname=strcat('bfg',num2str(islice),'.tif');
        t = Tiff(tiffname,'w');
        tagstruct.ImageLength     = size(bfg10x,1);
        tagstruct.ImageWidth      = size(bfg10x,2);
        tagstruct.SampleFormat    = Tiff.SampleFormat.IEEEFP;
        tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
        tagstruct.BitsPerSample   = 32;
        tagstruct.SamplesPerPixel = 1;
        tagstruct.Compression     = Tiff.Compression.None;
        tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
        tagstruct.Software        = 'MATLAB';
        t.setTag(tagstruct);
        t.write(bfg10x);
        t.close();
        
%         bkg10x=single(imread(strcat('BKG',num2str(islice),'.tif'), 1));
%         bkg10x=load(strcat('BKG',num2str(islice),'.tif'), 1));
%         bkg10x=bkg10x.*mask10x(1:size(bkg10x,1),1:size(bkg10x,2));
% %         save(strcat('BKG',num2str(islice),'.mat'),'bkg10x')
%         tiffname=strcat('BKG',num2str(islice),'.tif');
%         t = Tiff(tiffname,'w');
%         tagstruct.ImageLength     = size(bkg10x,1);
%         tagstruct.ImageWidth      = size(bkg10x,2);
%         tagstruct.SampleFormat    = Tiff.SampleFormat.IEEEFP;
%         tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
%         tagstruct.BitsPerSample   = 32;
%         tagstruct.SamplesPerPixel = 1;
%         tagstruct.Compression     = Tiff.Compression.None;
%         tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
%         tagstruct.Software        = 'MATLAB';
%         t.setTag(tagstruct);
%         t.write(bkg10x);
%         t.close();
    end
    %% masking 4x birefringence fitting
    cd(strcat(folder,'/fitting_4x'))
    if isfile(strcat('bfg',num2str(islice),'.tif'))
%         bfg4x=single(imread(strcat('bfg',num2str(islice),'.tif'), 1));
        load(strcat('bfg',num2str(islice),'.mat'));
        bfg4x=MosaicFinal;
        bfg4x=single(MosaicFinal.*mask4x(1:size(bfg4x,1),1:size(bfg4x,2)));
%         save(strcat('bfg',num2str(islice),'.mat'),'bfg4x')
        tiffname=strcat('bfg',num2str(islice),'.tif');
        t = Tiff(tiffname,'w');
        tagstruct.ImageLength     = size(bfg4x,1);
        tagstruct.ImageWidth      = size(bfg4x,2);
        tagstruct.SampleFormat    = Tiff.SampleFormat.IEEEFP;
        tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
        tagstruct.BitsPerSample   = 32;
        tagstruct.SamplesPerPixel = 1;
        tagstruct.Compression     = Tiff.Compression.None;
        tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
        tagstruct.Software        = 'MATLAB';
        t.setTag(tagstruct);
        t.write(bfg4x);
        t.close();
        
%         bkg4x=single(imread(strcat('BKG',num2str(islice),'.tif'), 1));
%         bkg4x=bkg4x.*mask4x(1:size(bkg4x,1),1:size(bkg4x,2));
% %         save(strcat('BKG',num2str(islice),'.mat'),'bkg4x')
%         tiffname=strcat('BKG',num2str(islice),'.tif');
%         t = Tiff(tiffname,'w');
%         tagstruct.ImageLength     = size(bkg4x,1);
%         tagstruct.ImageWidth      = size(bkg4x,2);
%         tagstruct.SampleFormat    = Tiff.SampleFormat.IEEEFP;
%         tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
%         tagstruct.BitsPerSample   = 32;
%         tagstruct.SamplesPerPixel = 1;
%         tagstruct.Compression     = Tiff.Compression.None;
%         tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
%         tagstruct.Software        = 'MATLAB';
%         t.setTag(tagstruct);
%         t.write(bkg4x);
%         t.close();
    end
    %% masking 10x scattering fitting
    cd(strcat(folder,'/fitting_10x'))
    if isfile(strcat('mus',num2str(islice),'.tif'))
%         mus10x=single(imread(strcat('mus',num2str(islice),'.tif'), 1));
        load(strcat('mus',num2str(islice),'.mat'));
                mus10x=MosaicFinal;
        mus10x=single(MosaicFinal.*mask10x(1:size(mus10x,1),1:size(mus10x,2)));
%         save(strcat('mus',num2str(islice),'.mat'),'mus10x')
        tiffname=strcat('mus',num2str(islice),'.tif');
        t = Tiff(tiffname,'w');
        tagstruct.ImageLength     = size(mus10x,1);
        tagstruct.ImageWidth      = size(mus10x,2);
        tagstruct.SampleFormat    = Tiff.SampleFormat.IEEEFP;
        tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
        tagstruct.BitsPerSample   = 32;
        tagstruct.SamplesPerPixel = 1;
        tagstruct.Compression     = Tiff.Compression.None;
        tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
        tagstruct.Software        = 'MATLAB';
        t.setTag(tagstruct);
        t.write(mus10x);
        t.close();
        
%         mub10x=single(imread(strcat('mub',num2str(islice),'.tif'), 1));
        load(strcat('mub',num2str(islice),'.mat'));
                mub10x=MosaicFinal;
        mub10x=single(MosaicFinal.*mask10x(1:size(mub10x,1),1:size(mub10x,2)));
%         save(strcat('mub',num2str(islice),'.mat'),'mub10x')
        tiffname=strcat('mub',num2str(islice),'.tif');
        t = Tiff(tiffname,'w');
        tagstruct.ImageLength     = size(mub10x,1);
        tagstruct.ImageWidth      = size(mub10x,2);
        tagstruct.SampleFormat    = Tiff.SampleFormat.IEEEFP;
        tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
        tagstruct.BitsPerSample   = 32;
        tagstruct.SamplesPerPixel = 1;
        tagstruct.Compression     = Tiff.Compression.None;
        tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
        tagstruct.Software        = 'MATLAB';
        t.setTag(tagstruct);
        t.write(mub10x);
        t.close();
        
%         R10x=single(imread(strcat('R2',num2str(islice),'.tif'), 1));
%         load(strcat('R2',num2str(islice),'.mat'));
%         R10x=mus10x.*mask10x(1:size(R10x,1),1:size(R10x,2));
% %         save(strcat('R2',num2str(islice),'.mat'),'R10x')
%         tiffname=strcat('R2',num2str(islice),'.tif');
%         t = Tiff(tiffname,'w');
%         tagstruct.ImageLength     = size(R10x,1);
%         tagstruct.ImageWidth      = size(R10x,2);
%         tagstruct.SampleFormat    = Tiff.SampleFormat.IEEEFP;
%         tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
%         tagstruct.BitsPerSample   = 32;
%         tagstruct.SamplesPerPixel = 1;
%         tagstruct.Compression     = Tiff.Compression.None;
%         tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
%         tagstruct.Software        = 'MATLAB';
%         t.setTag(tagstruct);
%         t.write(R10x);
%         t.close();
    end
    
    %% masking 4x scattering fitting
    cd(strcat(folder,'/fitting_4x'))
    if isfile(strcat('mus',num2str(islice),'.tif'))
%         mus4x=single(imread(strcat('mus',num2str(islice),'.tif'), 1));
        load(strcat('mus',num2str(islice),'.mat'));
                mus4x=MosaicFinal;
        mus4x=single(MosaicFinal.*mask4x(1:size(mus4x,1),1:size(mus4x,2)));
%         save(strcat('mus',num2str(islice),'.mat'),'mus4x')
        tiffname=strcat('mus',num2str(islice),'.tif');
        t = Tiff(tiffname,'w');
        tagstruct.ImageLength     = size(mus4x,1);
        tagstruct.ImageWidth      = size(mus4x,2);
        tagstruct.SampleFormat    = Tiff.SampleFormat.IEEEFP;
        tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
        tagstruct.BitsPerSample   = 32;
        tagstruct.SamplesPerPixel = 1;
        tagstruct.Compression     = Tiff.Compression.None;
        tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
        tagstruct.Software        = 'MATLAB';
        t.setTag(tagstruct);
        t.write(mus4x);
        t.close();
        
%         mub4x=single(imread(strcat('mub',num2str(islice),'.tif'), 1));
        load(strcat('mub',num2str(islice),'.mat'));
                mub4x=MosaicFinal;
        mub4x=single(MosaicFinal.*mask4x(1:size(mub4x,1),1:size(mub4x,2)));
%         save(strcat('mub',num2str(islice),'.mat'),'mub4x')
        tiffname=strcat('mub',num2str(islice),'.tif');
        t = Tiff(tiffname,'w');
        tagstruct.ImageLength     = size(mub4x,1);
        tagstruct.ImageWidth      = size(mub4x,2);
        tagstruct.SampleFormat    = Tiff.SampleFormat.IEEEFP;
        tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
        tagstruct.BitsPerSample   = 32;
        tagstruct.SamplesPerPixel = 1;
        tagstruct.Compression     = Tiff.Compression.None;
        tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
        tagstruct.Software        = 'MATLAB';
        t.setTag(tagstruct);
        t.write(mub4x);
        t.close();
        
%         R4x=single(imread(strcat('R2',num2str(islice),'.tif'), 1));
%         load(strcat('R2',num2str(islice),'.mat'));
%         R4x=mus4x.*mask4x(1:size(R4x,1),1:size(R4x,2));
% %         save(strcat('R2',num2str(islice),'.mat'),'R4x')
%         tiffname=strcat('R2',num2str(islice),'.tif');
%         t = Tiff(tiffname,'w');
%         tagstruct.ImageLength     = size(R4x,1);
%         tagstruct.ImageWidth      = size(R4x,2);
%         tagstruct.SampleFormat    = Tiff.SampleFormat.IEEEFP;
%         tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
%         tagstruct.BitsPerSample   = 32;
%         tagstruct.SamplesPerPixel = 1;
%         tagstruct.Compression     = Tiff.Compression.None;
%         tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
%         tagstruct.Software        = 'MATLAB';
%         t.setTag(tagstruct);
%         t.write(R4x);
%         t.close();
    end
end
        