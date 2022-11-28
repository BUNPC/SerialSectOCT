function Exp_Fiji = read_Fiji_coord(filename,opt)

    fid = fopen(filename,'r');
    
    for ii=1:4
        kk = fgets(fid);
    end
    
    ii=0;
    if strcmp(opt,'aip')
        while ~feof(fid)
            ii = ii +1;
            kk = fgets(fid);
%             img(:,ii)=sscanf(kk,['aip%d.tif; ; ( %f, %f)']);
            img(:,ii)=sscanf(kk,['%d_aip.tif; ; ( %f, %f)']);
        end
    elseif strcmp(opt,'ub')
        while ~feof(fid)
            ii = ii +1;
            kk = fgets(fid);
            img(:,ii)=sscanf(kk,['%d_ub.tif; ; ( %f, %f)']);
        end
    elseif strcmp(opt,'us')
        while ~feof(fid)
            ii = ii +1;
            kk = fgets(fid);
            img(:,ii)=sscanf(kk,['%d_us.tif; ; ( %f, %f)']);
        end
    elseif strcmp(opt,'mip')
        while ~feof(fid)
            ii = ii +1;
            kk = fgets(fid);
            img(:,ii)=sscanf(kk,['%d_mip.tif; ; ( %f, %f)']);
        end
    elseif strcmp(opt,'channel1')
    while ~feof(fid)
        ii = ii +1;
        kk = fgets(fid);
        img(:,ii)=sscanf(kk,['%d-channel1.tif; ; ( %f, %f)']);
    end
    elseif strcmp(opt,'ret')
    while ~feof(fid)
        ii = ii +1;
        kk = fgets(fid);
        img(:,ii)=sscanf(kk,['%d_ret.tif; ; ( %f, %f)']);
    end
    elseif strcmp(opt,'Composite')
    while ~feof(fid)
        ii = ii +1;
        kk = fgets(fid);
        img(:,ii)=sscanf(kk,['Composite-%4d.tif; ; ( %f, %f)']);
    end
    end
    fclose(fid);
    Exp_Fiji=img;
end