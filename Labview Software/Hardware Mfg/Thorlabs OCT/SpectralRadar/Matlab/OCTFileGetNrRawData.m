function [ nrRawData ] = OCTFileGetNrRawData( handle )
% OCTFILEGETNRRAWDATA  Get number of spectral raw data files in an .oct file.
%   nrRawData = OCTFILEGETNRRAWDATA( handle ) Get number of spectral raw data files in an .oct file
%
%   See also OCTFileGetRawData
%

L = length(handle.head.DataFiles.DataFile);

nrRawData = 0;

for k = 1:L
   % Get the label element. In this file, each
   % listitem contains only one label.
   thisList = handle.head.DataFiles;
   node = thisList.DataFile{k};
    if ~isempty(node) && strcmpi(node.Attributes.Type, 'Raw')
         nrRawData = nrRawData +1;
    end
end

end