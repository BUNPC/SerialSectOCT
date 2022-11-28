function Find_Grid_Distortion(folder, folder_curve)
%this is for finding grid distortion at different z depth
cd(folder);
files=dir('*.dat');
num_files=length(files);
if num_files>1
    display('more than one files found, only need one file')
else
    file_split=strsplit(files(1).name,'.');
    file_split2=strsplit(string(file_split(1)),'-');
    z=str2double(file_split2{3});
    x=str2double(file_split2{4});
    y=str2double(file_split2{5});
    display("finding grid target in image...")
    C_scan=zeros(z,x,y);
    load(strcat(folder_curve,'\surface.mat'));

    display(strcat("processing: ",files(1).name));
    fileID = fopen(files(1).name); 
    raw_data = single(fread(fileID,'uint16'))./65535*4;
    fclose(fileID);
    C_scan=reshape(raw_data,z,x,y);
    C_scan=C_scan(:,111:1210,:);
    curved_C_scan=zeros(z,x,y);
    for X=1:x
        for Y=1:y
            depth=curvature_B(X,Y);
            curved_C_scan(1:(z-depth),X,Y)=C_scan((depth+1):z,X,Y);
        end
    end
    [~,z0]=max(curved_C_scan(1:z,x/2,y/2));
    Slice=squeeze(curved_C_scan(z0-2,:,:))+squeeze(curved_C_scan(z0-1,:,:))+squeeze(curved_C_scan(z0,:,:))+squeeze(curved_C_scan(z0+1,:,:))+squeeze(curved_C_scan(z0+2,:,:));
    %check curvature correction result
    m=max(z0-10,1);
    M=min(z0+10,z);
    for i=m:M
        slice=squeeze(curved_C_scan(i,:,:));
        Slice=single(slice);
        name=strcat(num2str(i),'.tif');
        t = Tiff(name,'w');
        tagstruct.ImageLength     = size(Slice,1);
        tagstruct.ImageWidth      = size(Slice,2);
        tagstruct.SampleFormat    = Tiff.SampleFormat.IEEEFP;
        tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
        tagstruct.BitsPerSample   = 32;
        tagstruct.SamplesPerPixel = 1;
        tagstruct.RowsPerStrip    = 16;
        tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
        tagstruct.Software        = 'MATLAB';
        t.setTag(tagstruct)
        t.write(Slice);
        t.close();
    end
    Slice=Slice-min(Slice(:))+0.00001;
    Slice=Slice/max(Slice(:));
    %normalize by FOV uniformity
    map=zeros(x,y);
    for i=1:x
        for j=1:y
            mi=max([i-20 1]);mj=max([j-20 1]);
            Mi=min([i+20 x]);Mj=min([j+20 x]);
            map(i,j)=max(max(Slice(mi:Mi,mj:Mj)));
        end
    end

    Slice=Slice./map*255;
    Slice=single(Slice);
    name=strcat('grid.tif');
    t = Tiff(name,'w');
    tagstruct.ImageLength     = size(Slice,1);
    tagstruct.ImageWidth      = size(Slice,2);
    tagstruct.SampleFormat    = Tiff.SampleFormat.IEEEFP;
    tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
    tagstruct.BitsPerSample   = 32;
    tagstruct.SamplesPerPixel = 1;
    tagstruct.RowsPerStrip    = 16;
    tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
    tagstruct.Software        = 'MATLAB';
    t.setTag(tagstruct)
    t.write(Slice);
    t.close();

    %%
    %generating macro scripts to register XY plane and gen transfrom matrix
    file_split=strsplit(folder,'\');
    file_path=strcat(file_split(1),'\\');
    save_path=strcat(file_split(1),'/');
    for i=2:length(file_split)
        file_path=strcat(file_path,file_split(i),'\\');
        save_path=strcat(save_path,file_split(i),'/');
    end
    file_path=file_path{1};
    save_path=save_path{1};
    cd(folder);
    files=dir('grid.tif');
    num_files=length(files);

    display("writing imagej macros")
    pathname=folder;
    macropath=[pathname,'\Macro.ijm'];
    fid_Macro = fopen(macropath, 'w');
    for i=1:num_files
        fprintf(fid_Macro,'open("%sundistorted.tif");\n',file_path);
        fprintf(fid_Macro,'open("%sgrid.tif");\n',file_path);
        fprintf(fid_Macro,'run("bUnwarpJ", "source_image=grid%d.tif target_image=undistorted.tif registration=Mono image_subsample_factor=0 initial_deformation=Coarse final_deformation=[Super Fine] divergence_weight=0 curl_weight=0 landmark_weight=0 image_weight=1 consistency_weight=10 stop_threshold=0.01 verbose save_transformations save_direct_transformation=[%sgrid_direct_transf super fine.txt]");\n',save_path);
        fprintf(fid_Macro,'close();\n');
        fprintf(fid_Macro,'close();\n');
        fprintf(fid_Macro,'close();\n');
        fprintf(fid_Macro,'open("%sgrid.tif");\n',file_path);
        fprintf(fid_Macro,'call("bunwarpj.bUnwarpJ_.convertToRaw", "%sgrid_direct_transf super fine.txt", "%sraw_transf super fine.txt", "grid.tif");\n', file_path,file_path);
        fprintf(fid_Macro,'close();\n');
        fprintf(fid_Macro,'\n');
    end
    fclose(fid_Macro);


end