%generating macro scripts to unwarp XY plane
pathname='C:\Projects\serialsectioningOCT\Data\Griddistortion\test\macros\';
macropath=[pathname,'Macro.ijm'];
z_step_size=3;
macro_depth=20;
z=10;
fid_Macro = fopen(macropath, 'w');
file_path='C:\\Projects\\serialsectioningOCT\\Data\\Griddistortion\\test\\';
matrix_path='C:\\Projects\\serialsectioningOCT\\Data\\Griddistortion\\0621\\';
for Z=1:z
    fprintf(fid_Macro,'open("%sundistorted.tif");\n',file_path);
    fprintf(fid_Macro,'open("%sslice%d.tif");\n',file_path,Z);
    fprintf(fid_Macro,'call("bunwarpj.bUnwarpJ_.loadElasticTransform", "%sBMag%d_direct_transf super fine.txt", "undistorted.tif", "slice%d.tif");\n'...
        ,matrix_path,ceil(Z*z_step_size/macro_depth),Z);
    fprintf(fid_Macro,'saveAs("Tiff", "%sslice%d.tif");\n',file_path,Z);
    fprintf(fid_Macro,'close();\n');
    fprintf(fid_Macro,'close();\n');
    fprintf(fid_Macro,'\n');
end
fclose(fid_Macro);
%%
%generating macro scripts to register XY plane and gen transfrom matrix
file_path='C:\\Projects\\serialsectioningOCT\\Data\\Griddistortion\\';
cd(file_path);
files=dir('BMag*.tif');
num_files=length(files);


pathname='C:\Projects\serialsectioningOCT\Data\Griddistortion\test\';
macropath=[pathname,'Macro.ijm'];
fid_Macro = fopen(macropath, 'w');
for i=1:num_files
    fprintf(fid_Macro,'open("%sundistorted.tif");\n',file_path);
    fprintf(fid_Macro,'open("%sBMag%d.tif");\n',file_path,i);
    fprintf(fid_Macro,'run("bUnwarpJ", "source_image=BMag%d.tif target_image=undistorted.tif registration=Mono image_subsample_factor=0 initial_deformation=Coarse final_deformation=[Super Fine] divergence_weight=0 curl_weight=0 landmark_weight=0 image_weight=1 consistency_weight=10 stop_threshold=0.01 verbose save_transformations save_direct_transformation=[C:/Projects/serialsectioningOCT/Data/Griddistortion/0621/BMag%d_direct_transf super fine.txt]");\n',i,i);
    fprintf(fid_Macro,'close();\n');
    fprintf(fid_Macro,'close();\n');
    fprintf(fid_Macro,'close();\n');
    fprintf(fid_Macro,'\n');
end
fclose(fid_Macro);
%%
pathname='C:\Projects\serialsectioningOCT\Data\test\grid_distortion\';
macropath=[pathname,'Macro1.ijm'];
z_step_size=3;
macro_depth=6;
fid_Macro = fopen(macropath, 'w');
file_path='C:\\Projects\\serialsectioningOCT\\Data\\test\\grid_distortion\\';
new_file_path='C:\\Projects\\serialsectioningOCT\\Data\\test\\grid_distortion\\unwarpped1\\';
matrix_path='C:\\Projects\\serialsectioningOCT\\Data\\test\\grid_distortion\\';
for Z=1:30
    fprintf(fid_Macro,'open("%sundistorted%d.tif");\n','C:\\Projects\\serialsectioningOCT\\Data\\test\\grid_distortion\\target\\',Z);
    fprintf(fid_Macro,'open("%sBMag%d.tif");\n',file_path,Z);
    fprintf(fid_Macro,'call("bunwarpj.bUnwarpJ_.loadElasticTransform", "%sBMag%d_direct_transf super fine.txt", "undistorted%d.tif", "BMag%d.tif");\n'...
        ,matrix_path,15,Z,Z);
    fprintf(fid_Macro,'selectWindow("BMag%d.tif");\n',Z);
    fprintf(fid_Macro,'selectWindow("undistorted%d.tif");\n',Z);
    fprintf(fid_Macro,'run("Merge Channels...", "c1=BMag%d.tif c2=undistorted%d.tif create");\n',Z,Z);
    fprintf(fid_Macro,'selectWindow("Composite");\n');
    fprintf(fid_Macro,'saveAs("PNG", "%sBMag%d-matrix%d.png");\n',new_file_path,Z,15);
    fprintf(fid_Macro,'close();\n');
    fprintf(fid_Macro,'\n');
end
fclose(fid_Macro);

%% generate macro for downsampling
pathname='C:\Projects\SSOCT\Data\191204\volume\';
macropath=[pathname,'Macro1.ijm'];
fid_Macro = fopen(macropath, 'w');
file_path='C:\\Projects\\SSOCT\\Data\\191204\\volume\\';
new_file_path='C:/Projects/SSOCT/Data/191204/volume_downsample/';
for Z=4:30
    fprintf(fid_Macro,'open("%svol%d.tif");\n',file_path,Z);
     fprintf(fid_Macro,'selectWindow("vol%d.tif");\n',Z);
    fprintf(fid_Macro,'run("Scale...", "x=0.25 y=0.25 z=0.25 width=1220 height=1256 depth=15 interpolation=Bilinear average process create");\n');

    fprintf(fid_Macro,'saveAs("Tiff", "%svol%d-1.tif");\n',new_file_path,Z);
        fprintf(fid_Macro,'close();\n');
    fprintf(fid_Macro,'selectWindow("vol%d.tif");\n',Z);
    fprintf(fid_Macro,'close();\n');
    fprintf(fid_Macro,'\n');
end
fclose(fid_Macro);

%% generating macro for stacking slices
pathname='C:\Projects\SSOCT\Data\201028_Ann_7688\';
target='surf';
slices=62;
macropath=[pathname,'Macro.ijm'];
fid_Macro = fopen(macropath, 'w');

new_file_path='C:/Projects/SSOCT/Data/201028_Ann_7688/';
for i=1:slices
    file_path=strcat('C:\\Projects\\SSOCT\\Data\\201028_Ann_7688\\',target,'\\vol',num2str(i),'\\');
    fprintf(fid_Macro,'open("%ssur.tif");\n',file_path);
   
end
fprintf(fid_Macro,'run("Images to Stack", "method=[Copy (center)] name=Stack title=[] use");\n');
fclose(fid_Macro);



