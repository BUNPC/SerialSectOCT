function [ handle ] = OCTFileOpen( filename )
% OCTFILEOPEN  Open .oct file.
%   handle = OCTFILEOPEN( filename ) Open .oct file located at filename
%
%   The data files inside the .oct file are extracted into the temporary
%   directory and removed when OCTFileClose is called
%
%   See also OCTFILECLOSE
%

handle.filename = filename;
%handle.path = [pwd, '\OCTData\'];
handle.path = [tempdir, 'OCTData\'];

if exist(handle.path,'file')
   rmdir(handle.path, 's')
end
if ~exist(handle.path,'file')
   mkdir(handle.path, 's')
end
unzip(filename, handle.path);
handle.xml = xmlread([handle.path, 'Header.xml']);
head_oct = xml2struct([handle.path, 'Header.xml']);
handle.head = head_oct.Ocity;

end

