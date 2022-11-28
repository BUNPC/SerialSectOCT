function[]=ref_vol_stitch_high_res(id,datapath)

% mosaic parameters
Xsize=1000;
Ysize=1000;
Xoverlap=0.15;
Yoverlap=0.15;

% add path of functions
addpath('/projectnb/npbssmic/s/Matlab_code/PSOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code/ThorOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code/NIfTI_20140122');

%% define coordinates for each tile
filename = strcat(datapath,'aip/vol10/');
f=strcat(filename,'TileConfiguration.registered.txt');
coord = read_Fiji_coord(f,'aip');

Xcen=zeros(size(coord,2),1);
Ycen=zeros(size(coord,2),1);
index=coord(1,:);

for ii=1:size(coord,2)
    Xcen(coord(1,ii))=round(coord(3,ii));
    Ycen(coord(1,ii))=round(coord(2,ii));
end


%% select tiles for sub-region volumetric stitching

Xcen=Xcen-min(Xcen);
Ycen=Ycen-min(Ycen);

Xcen=Xcen+round(Xsize/2);
Ycen=Ycen+round(Ysize/2);

% tile range -199~+200
stepx = floor(Xoverlap*Xsize);
x = [0:stepx-1 repmat(stepx,1,round((1-2*Xoverlap)*Xsize)) stepx-1:-1:0]./stepx;
stepy = floor(Yoverlap*Ysize);
y = [0:stepy-1 repmat(stepy,1,round((1-2*Yoverlap)*Ysize)) stepy-1:-1:0]./stepy;
[rampy,rampx]=meshgrid(y,x);
ramp=rampx.*rampy;      % blending mask


%% blending & mosaicing

thickness=44;


filename = strcat(datapath,'dist_corrected/');
% filename = datapath;
cd(filename);


for nslice=id
    
    Mosaic = zeros(round(max(Xcen))+Xsize/2 ,round(max(Ycen))+Ysize/2,thickness);
    Masque = zeros(size(Mosaic));
    Masque2 = zeros(size(Mosaic));
    filename0=dir(strcat(filename,'co-',num2str(nslice),'-',num2str(1),'-*.dat'));
    % only for PSOCT0103
    % filename0=dir(strcat(filename,num2str(nslice),'-',num2str(1),'-*.dat'));
    name1=strsplit(filename0(1).name,'.');  
    name_dat=strsplit(name1{1},'-');   
    nk = str2num(name_dat{4}); nxRpt = 1; nx=str2num(name_dat{5}); nyRpt = 1; ny = str2num(name_dat{6});
    % only for PSOCT0103
    % nk = 108; nxRpt = 1; nx = 1060; nyRpt = 1; ny = 1060;
    dim=[nk nxRpt nx nyRpt ny];

    for i=1:length(index)

        in = index(i);

        filename0=dir(strcat('co-',num2str(nslice),'-',num2str(in),'-*.dat'));
        ifilePath=[filename,filename0(1).name];
        slice = (ReadDat_int16(ifilePath, dim)).^2;
        filename0=dir(strcat('cross-',num2str(nslice),'-',num2str(in),'-*.dat'));
        ifilePath=[filename,filename0(1).name];
        slice = slice+(ReadDat_int16(ifilePath, dim)).^2;
        slice=sqrt(slice);
        
        %filename0=dir(strcat('ref-',num2str(nslice),'-',num2str(in),'-*.dat'));
        % only for PSOCT0103
        % filename0=dir(strcat(num2str(nslice),'-',num2str(in),'-*.dat'));

        %ifilePath=[filename,filename0(1).name];
        %slice = ReadDat_int16(ifilePath, dim);
        info=strcat('Finished loading tile No.', num2str(in),'\n');
        fprintf(info);

        
        % slice = ReadDat_int16(ifilePath, dim);       
        % only for PSOCT0103
        % slice = ReadDat_single(ifilePath, dim); 
        % slice(31:74,:,:) = speckle_reduction(double(slice(31:74,:,:)));
        slice = convn(slice,ones(3,3,3)./27,'same');
        slice = depth_corr(slice,0.0035);
        slice = slice(66:66+thickness-1,:,:);

%        vol = zeros(thickness,size(slice,2),size(slice,3));

%         for z=1:size(vol,1)
%             vol(z,:,:)=mean(slice((z-1)*4+1:min(z*4,thickness),:,:),1);
%         end
        vol = slice;
        % row and column start with +2 only for PSOCT0103
        row = round(Xcen(in)-Xsize/2+1:Xcen(in)+Xsize/2);
        column = round(Ycen(in)-Ysize/2+1:Ycen(in)+Ysize/2); 


        for j=1:size(vol,1)
            Masque2(row,column,j)=ramp;
            Masque(row,column,j)=Masque(row,column,j)+Masque2(row,column,j);
            Mosaic(row,column,j)=Mosaic(row,column,j)+squeeze(vol(j,:,:)).*Masque2(row,column,j);        
        end 
    end

    Ref=Mosaic./Masque;
    Ref(isnan(Ref(:)))=0;
    Ref=single(Ref);
    save(strcat(datapath,'dist_corrected/volume/ref_high_res_',num2str(nslice),'.mat'),'Ref','-v7.3');
%     % save as TIFF
%     s=uint8(255*(mat2gray(Ref))); 
% 
%     tiffname=strcat(datapath,'dist_corrected/volume/ref',num2str(nslice),'.tif');
% 
%     for i=1:size(s,3)
%         t = Tiff(tiffname,'a');
%         image=squeeze(s(:,:,i));
%         tagstruct.ImageLength     = size(image,1);
%         tagstruct.ImageWidth      = size(image,2);
%         tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
%         tagstruct.BitsPerSample   = 8;
%         tagstruct.SamplesPerPixel = 1;
%         tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
%         tagstruct.Compression = Tiff.Compression.None;
%         tagstruct.Software        = 'MATLAB';
%         t.setTag(tagstruct);
%         t.write(image);
%         t.close();
%     end
    
    info=strcat('Volumetric reconstruction of slice No.', num2str(nslice), ' is done.\n');
    fprintf(info);

end