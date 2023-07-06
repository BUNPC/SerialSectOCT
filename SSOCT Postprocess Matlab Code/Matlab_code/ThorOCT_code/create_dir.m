function create_dir(nslice,datapath)
%% create folders for each volume during oct processing
% Author: Jiarui Yang
    cd(datapath);
    if exist('aip')==7
        
    else
        mkdir aip
    end
    cd(strcat(datapath,'/aip/'));
    for i=1:nslice
        foldername=strcat('vol',num2str(i));
        if exist(foldername)
        else
           mkdir(foldername);
        end
    end
    cd(datapath);
    if exist('mip')==7
        
    else
        mkdir mip
    end
    cd(strcat(datapath,'mip/'));
    for i=1:nslice
        foldername=strcat('vol',num2str(i));
        if exist(foldername)
        else
           mkdir(foldername);
        end
    end
    cd(datapath);
    if exist('retardance')==7
        
    else
        mkdir retardance
    end
    cd(strcat(datapath,'retardance/'));
    for i=1:nslice
        foldername=strcat('vol',num2str(i));
        if exist(foldername)
        else
           mkdir(foldername);
        end
    end
    cd(datapath);
    if exist('surf')==7
        
    else
        mkdir surf
    end
    cd(strcat(datapath,'surf/'));
    for i=1:nslice
        foldername=strcat('vol',num2str(i));
        if exist(foldername)
        else
           mkdir(foldername);
        end
    end
    cd(datapath);
    if exist('fitting')==7
        
    else
        mkdir fitting
    end
    cd(strcat(datapath,'fitting/'));
    for i=1:nslice
        foldername=strcat('vol',num2str(i));
        if exist(foldername)
        else
           mkdir(foldername);
        end
    end
    cd(datapath);
    if exist('orientation')==7
        
    else
        mkdir orientation
    end
    cd(strcat(datapath,'orientation/'));
    for i=1:nslice
        foldername=strcat('vol',num2str(i));
        if exist(foldername)
        else
           mkdir(foldername);
        end
    end
end