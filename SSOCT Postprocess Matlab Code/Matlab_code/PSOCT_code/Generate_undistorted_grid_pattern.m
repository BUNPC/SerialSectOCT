function Generate_undistorted_grid_pattern(folder, center_x,center_y,angle, length_x,length_y)
image=zeros(1100,1100);
angle=angle/180*pi;
for x=1:1100
    for y=1:1100
        dx=x-center_x;
        dy=y-center_y;
        dl=sqrt(dx^2+dy^2);
        theta=atan(dx/dy);
        dx_r=dl*cos(theta-angle);
        if mod(dx_r,length_x)<1.5 || mod(dx_r,length_x)>length_x-1.5
            image(x,y)=255;
        end
        dy_r=dl*sin(theta-angle);
        if mod(dy_r,length_y)<1.5 || mod(dy_r,length_y)>length_y-1.5
            image(x,y)=255;
        end
    end
end

name=strcat(folder,'\undistorted.tif');
t = Tiff(name,'w');
image=single(image);
tagstruct.ImageLength     = size(image,1);
tagstruct.ImageWidth      = size(image,2);
tagstruct.SampleFormat    = Tiff.SampleFormat.IEEEFP;
tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
tagstruct.BitsPerSample   = 32;
tagstruct.SamplesPerPixel = 1;
tagstruct.RowsPerStrip    = 16;
tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
tagstruct.Software        = 'MATLAB';
t.setTag(tagstruct)
t.write(image);
t.close();

