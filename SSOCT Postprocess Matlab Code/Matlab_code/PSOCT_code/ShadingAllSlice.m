folder  = '/projectnb2/npbssmic/ns/Ann_Mckee_samples_20T/AD_10382/';
P2path = '/projectnb2/npbssmic/ns/Ann_Mckee_samples_20T/AD_10382_2P/';   % 2P file path
datapath=strcat(folder,'fitting/'); 

% add subfunctions for the script. Change directory if not running on BU SCC
addpath('/projectnb/npbssmic/s/Matlab_code/fitting_code');
addpath('/projectnb/npbssmic/s/Matlab_code/PostProcessing');
addpath('/projectnb/npbssmic/s/Matlab_code/PSOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code/ThorOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code');

cd(datapath);
ntile=77;
nslice=18; % define total number of slices
%% flagg mus tiles
filename = strcat(folder,'fitting/MUS_all.tif');
flagged=0;
for islice=1:nslice
    cd(strcat(datapath,'/vol',num2str(islice)));
    filename0=dir(strcat(folder,'fitting/vol',num2str(islice),'/MUS.tif'));
    for j=1:ntile
        mus = single(imread(filename0(1).name, j));
        if flagged==0
            t = Tiff(filename,'w');
            flagged=1;
        else
            t = Tiff(filename,'a');
        end
        tagstruct.ImageLength     = size(mus,1);
        tagstruct.ImageWidth      = size(mus,2);
        tagstruct.SampleFormat    = Tiff.SampleFormat.IEEEFP;
        tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
        tagstruct.BitsPerSample   = 32;
        tagstruct.SamplesPerPixel = 1;
        tagstruct.Compression     = Tiff.Compression.None;
        tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
        tagstruct.Software        = 'MATLAB';
        t.setTag(tagstruct);
        t.write(mus);
        t.close();

    end   
end
cd(strcat(folder,'fitting/'))
% 
% %% BaSiC shading correction
    macropath=strcat(folder,'fitting/','/BaSiC.ijm');
    cor_filename=strcat(folder,'fitting/','MUS_cor.tif');
    fid_Macro = fopen(macropath, 'w');
    filename=strcat(folder,'fitting/','MUS_all.tif');
    fprintf(fid_Macro,'open("%s");\n',filename);
    fprintf(fid_Macro,'run("BaSiC ","processing_stack=MUS_all.tif flat-field=None dark-field=None shading_estimation=[Estimate shading profiles] shading_model=[Estimate both flat-field and dark-field] setting_regularisationparametes=Automatic temporal_drift=Ignore correction_options=[Compute shading and correct images] lambda_flat=0.50 lambda_dark=0.50");\n');
    fprintf(fid_Macro,'selectWindow("Corrected:MUS_all.tif");\n');
    fprintf(fid_Macro,'saveAs("Tiff","%s");\n',cor_filename);
    fprintf(fid_Macro,'close();\n');
    fprintf(fid_Macro,'close();\n');
    fprintf(fid_Macro,'close();\n');
    fprintf(fid_Macro,'close();\n');
    fprintf(fid_Macro,'run("Quit");\n');
    fclose(fid_Macro);
    try
       system(['xvfb-run -a ' '/projectnb/npbssmic/ns/Fiji/Fiji.app/ImageJ-linux64 --run ',macropath]);
    % %     system(['/projectnb/npbssmic/ns/Fiji/Fiji.app/ImageJ-linux64 -macro ',macropath]);
    catch
    end
    
    try
        % write corrected MUS_cor.tif tiles
        filename0=strcat(folder,'fitting/','MUS_cor.tif');
        filename0=dir(filename0);
        for iFile=1:ntile*nslice
            slice=ceil(iFile/ntile);
            iFile_t=mod(iFile-1,ntile)+1;
            mus = double(imread(filename0(1).name, iFile));
            avgname=strcat(folder,'fitting/vol',num2str(slice),'/',num2str(iFile_t),'.mat');
            save(avgname,'mus');  

            mus=single(mus);
            tiffname=strcat(folder,'fitting/vol',num2str(slice),'/',num2str(iFile_t),'_mus.tif');
            t = Tiff(tiffname,'w');
            tagstruct.ImageLength     = size(mus,1);
            tagstruct.ImageWidth      = size(mus,2);
            tagstruct.SampleFormat    = Tiff.SampleFormat.IEEEFP;
            tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
            tagstruct.BitsPerSample   = 32;
            tagstruct.SamplesPerPixel = 1;
            tagstruct.Compression     = Tiff.Compression.None;
            tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
            tagstruct.Software        = 'MATLAB';
            t.setTag(tagstruct);
            t.write(mus);
            t.close();
        end
    catch
   end