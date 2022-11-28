function [ ColoredData ] = OCTFileGetColoredData( handle, dataName )
% OCTFILEGETCOLOREDDATA  Get colored data from .oct file.
%   data = OCTFILEGETCOLOREDDATA( handle, dataName ) Get colored data from .oct file
%
%   dataName is the name of the colored data file inside the OCT file. For
%   instance to access the video image on can call
%   OCTFILEGETCOLOREDDATA( 'VideoImage' )
%

L = length(handle.head.DataFiles.DataFile);
sizes = zeros(1,3);
sizes(1) = 4;
filepath = [];

for k = 1:L
   % Get the label element. In this file, each
   % listitem contains only one label.
   thisList = handle.head.DataFiles;
   node = thisList.DataFile{k};
    if ~isempty(node) && ~isempty(strfind(node.Text, dataName))
        sizes(2) = str2double(node.Attributes.SizeZ);
        sizes(3) = str2double(node.Attributes.SizeX);
        filepath = node.Text;
    end
end

fid = fopen([handle.path, filepath]);
ColoredData = fread(fid, prod(sizes), 'uint8=>uint8');
fclose(fid);

ColoredData = permute(reshape(ColoredData, sizes), [3,2,1]);

ColoredData = flipdim(ColoredData(:,:,1:3),3);

end

