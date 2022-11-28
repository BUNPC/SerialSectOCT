folder= '/projectnb2/npbssmic/ns/BA4445_4/';
datapath=strcat(folder,'dist_corrected/'); 
P2path = '/projectnb2/npbssmic/ns/BA4445_4_2P/';   % 2P file path
% add subfunctions for the script. Change directory if not running on BU SCC
addpath('/projectnb/npbssmic/s/Matlab_code/fitting_code');
addpath('/projectnb/npbssmic/s/Matlab_code/PostProcessing');
addpath('/projectnb/npbssmic/s/Matlab_code/PSOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code/ThorOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code');
cd(datapath);

filename0=dir(strcat('co-1-*.dat')); % count #tiles per slice
ntile=154;%length(filename0);
nslice=120; % define total number of slices
% create_dir(nslice, folder);  
njobs=30;
section=ceil(nslice/njobs);
%     the $SGE-TASK-ID environment variable read in is CHARACTER, need to transfer to number
id=str2num(id);
istart=(id-1)*section+1;
istop=id*section;
cd(datapath);
for islice=istart:istop
    cd(datapath);
    for iFile=1:ntile
        filename0=dir(strcat('cross-',num2str(islice),'-',num2str(iFile),'-*.dat'));
        if length(filename0)==1
            name=strsplit(filename0(1).name,'.');  
            name_dat=strsplit(name{1},'-');
            slice_index=islice;
            % Xrpt and Yrpt are x and y scan repetition, default = 1
            Zsize = str2num(name_dat{4}); Xrpt = 1; Xsize=str2num(name_dat{5}); Yrpt = 1; Ysize = str2num(name_dat{6});
            dim1=[Zsize Xrpt Xsize Yrpt Ysize];     % tile size for reflectivity 
            name1=strcat('co-',num2str(islice),'-',num2str(iFile),'-',num2str(Zsize),'-',num2str(Xsize),'-',num2str(Ysize),'.dat'); % gen file name for reflectivity

            % load reflectivity data
            ifilePath = [datapath,name1];
            co = ReadDat_int16(ifilePath, dim1)./65535*4; 
            name1=strcat('cross-',num2str(islice),'-',num2str(iFile),'-',num2str(Zsize),'-',num2str(Xsize),'-',num2str(Ysize),'.dat'); % gen file name for reflectivity
    %         load reflectivity data
            ifilePath = [datapath,name1];
            cross = ReadDat_int16(ifilePath, dim1)./65535*4; 
            message=strcat('Tile No. ',string(iFile),' is read.', datestr(now,'DD:HH:MM'),'\n');
            fprintf(message);
            if mod(islice,2)>0    
                height=round(Gen_slice_height(0.1,islice,folder));
            end
            cross=cross(height+15:height+50,:,:);
            co=co(height+15:height+50,:,:);
            ret=single(atan(cross./co))./pi/2*90;
            ret_aip=single(squeeze(mean(ret,1)));

            % Saving retardance AIP.tif
            ret_aip=single(ret_aip);
            tiffname=strcat(folder,'retardance/vol',num2str(islice),'/','RET.tif');
            if iFile==1
                t = Tiff(tiffname,'w');
            else
                t = Tiff(tiffname,'a');
            end
            tagstruct.ImageLength     = size(ret_aip,1);
            tagstruct.ImageWidth      = size(ret_aip,2);
            tagstruct.SampleFormat    = Tiff.SampleFormat.IEEEFP;
            tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
            tagstruct.BitsPerSample   = 32;
            tagstruct.SamplesPerPixel = 1;
            tagstruct.Compression     = Tiff.Compression.None;
            tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
            tagstruct.Software        = 'MATLAB';
            t.setTag(tagstruct);
            t.write(ret_aip);
            t.close();
        else
            ret_aip=single(zeros(1000,1000));
            tiffname=strcat(folder,'retardance/vol',num2str(islice),'/','RET.tif');
            if iFile==1
                t = Tiff(tiffname,'w');
            else
                t = Tiff(tiffname,'a');
            end
            tagstruct.ImageLength     = size(ret_aip,1);
            tagstruct.ImageWidth      = size(ret_aip,2);
            tagstruct.SampleFormat    = Tiff.SampleFormat.IEEEFP;
            tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
            tagstruct.BitsPerSample   = 32;
            tagstruct.SamplesPerPixel = 1;
            tagstruct.Compression     = Tiff.Compression.None;
            tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
            tagstruct.Software        = 'MATLAB';
            t.setTag(tagstruct);
            t.write(ret_aip);
            t.close();
        end
        
    end
    sys = 'PSOCT';
    % specify mosaic parameters, you can get it from Imagej stitching
    xx=866;    % xx is the X displacement of two adjacent tile align in the X direction
    xy=0;     % xy is the Y displacement of two adjacent tile align in the X direction, default to 0
    yy=866;    % yy is the Y displacement of two adjacent tile align in the Y direction
    yx=0;      % xx is the X displacement of two adjacent tile align in the Y direction, default to 0
    numX=14;    % #tiles in X direction
    numY=11;    % #tiles in Y direction
    Xoverlap=0.15;   % overlap in X direction
    Yoverlap=0.15;   % overlap in Y direction
    disp=[xx xy yy yx];
    mosaic=[numX numY Xoverlap Yoverlap];
    pattern = 'bidirectional';  % mosaic pattern, could be bidirectional or unidirectional
    pxlsize=[1000 1000];
    % % AIP_stitch(folder,disp,mosaic,pxlsize,id,pattern,sys); 
    Ret_stitch('ret_aip', P2path,folder,disp,mosaic,pxlsize,islice,pattern,sys)
    message=strcat('slcie No. ',string(islice),' is stitched.', datestr(now,'DD:HH:MM'),'\n');
    fprintf(message);
end
