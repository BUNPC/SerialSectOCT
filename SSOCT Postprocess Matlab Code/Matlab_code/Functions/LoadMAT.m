%% load .mat file
function data=LoadMAT(datapath,filename)
if ~any(ismember(filename,'.mat'))
    filename=[filename,'.mat'];
end
filepath=[datapath,'/',filename];
datamat=load(filepath);
dataname=fieldnames(datamat);
data=datamat.(dataname{1});
clear datamat