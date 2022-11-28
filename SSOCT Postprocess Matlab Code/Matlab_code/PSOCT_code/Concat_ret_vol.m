function[]=Concat_ret_vol(num_slice, datapath)
% num_slice=3;
filename = strcat(datapath,'dist_corrected/volume/ret',num2str(1),'.mat');
load(filename);
volume=zeros(size(Ret,1),size(Ret,2),11*num_slice);

for islice=1:num_slice
    
    filename = strcat(datapath,'dist_corrected/volume/ret',num2str(islice),'.mat');
    load(filename);
    
%     Mosaic=Mosaic(:,2:1231,:);
    
%    Mosaic=10000.*(Mosaic-min(Mosaic(:)))+0.001;
    % simple linear normalization over depth

    %Mosaic=slide_win_norm(Mosaic,[10 10]);
    
    volume(:,:,(islice-1)*11+1:islice*11)=Ret;
    
    info=strcat('loading slice No.',num2str(islice),' is finished.\n');
    fprintf(info);
end

% save as TIFF
% s=uint16(65535*(mat2gray(volume))); 
ret=single(volume/65535*180);
save('ret.mat','ret');
cd(strcat(datapath,'dist_corrected/volume/'));
clear options;
options.big = true; % Use BigTIFF format
saveastiff(ret, 'ret.btf', options);
% tiffname=strcat(datapath,'dist_corrected/volume/ret.tif');
% for i=1:size(s,3)
%     t = Tiff(tiffname,'a');
%     image=squeeze(s(:,:,i));
%     tagstruct.ImageLength     = size(image,1);
%     tagstruct.ImageWidth      = size(image,2);
%     tagstruct.SampleFormat    = Tiff.SampleFormat.IEEEFP;
%     tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
%     tagstruct.BitsPerSample   = 32;
%     tagstruct.SamplesPerPixel = 1;
%     tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
%     tagstruct.Compression = Tiff.Compression.None;
%     tagstruct.Software        = 'MATLAB';
%     t.setTag(tagstruct);
%     t.write(image);
%     t.close();
% end
info=strcat('concatinating slices is finished.\n');
fprintf(info)