%% GET data information
function [Dim, fNameBase, fIndex]=GetNameInfoRaw(filename0)
Name_info=strsplit(filename0,'-');
% Nk=str2num(Name_info{2});     % # of camera pixel
% Nx_rpt=str2num(Name_info{3}); % # of Ascan repeat
% Nx=str2num(Name_info{4}); % # of Ascan
% Ny_rpt=str2num(Name_info{5}); % # of Bscan repeat
% Ny=str2num(Name_info{6}); % # of Bscan

Dim.nk=str2num(Name_info{2});    %  number of spectrum pixel (camera pixel)
Dim.nxRpt=str2num(Name_info{3}); %  nA repeat
Dim.nx=str2num(Name_info{4});    %  nA per Bscan
Dim.nyRpt=str2num(Name_info{5}); %  nB repeat 
Dim.ny=str2num(Name_info{6});    %  nB per Ychunk

fNameBase=[strjoin(Name_info(1:end-1),'-'),'-'];
fIndexInfo=strsplit(Name_info{end},'.');
fIndex=str2num(fIndexInfo{1});