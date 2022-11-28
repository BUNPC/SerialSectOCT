function [ ] = OCTFileClose( handle )
% OCTFILECLOSE  Close .oct file.
%   OCTFILECLOSE ( handle ) Close .oct file given a file handle
%
%   Note that OCTFILECLOSE removes the temporary files that are created by
%   OCTFileOpen.
%
%   See also OCTFILEOPEN
%

if exist(handle.path,'file')
  rmdir(handle.path, 's')
end

end

