numFile = 10;
for i=1:numFile
    SCC_ANGIO_Dat2AG('/projectnb/npbssmic/ns/220207_P3/NIR_OCT/500um_tissue/','RAW-2048-0001-00600-002-600-',[1 600 1 -0.24],[2048 1 600 2 600],i);
end