function[]=Concat_ref_vol_4x4x2(num_slice, datapath)

volume=[];

for islice=1:num_slice
    
    filename = strcat(datapath,'dist_corrected/volume/ref',num2str(islice),'.mat');
    load(filename);
    Ref=imresize3(Ref,0.25);
    
    volume=cat(3,volume,Ref);
    
    info=strcat('loading slice No.',num2str(islice),' is finished.\n');
    fprintf(info);
end

volume = uint16(65535*(mat2gray(volume))); 
tiffname=strcat(datapath,'dist_corrected/volume/ref.tif');

for i=1:size(volume,3)
    t = Tiff(tiffname,'a');
    image=squeeze(volume(:,:,i));
    tagstruct.ImageLength     = size(image,1);
    tagstruct.ImageWidth      = size(image,2);
%     tagstruct.SampleFormat    = Tiff.SampleFormat.IEEEFP;
    tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
    tagstruct.BitsPerSample   = 16;
    tagstruct.SamplesPerPixel = 1;
    tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
    tagstruct.Compression = Tiff.Compression.None;
    tagstruct.Software        = 'MATLAB';
    t.setTag(tagstruct);
    t.write(image);
    t.close();
end
info=strcat('concatinating slices is finished.\n');
fprintf(info);
end