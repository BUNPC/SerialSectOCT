function [ property ] = OCTFileGetProperty( handle, propertyName )
% OCTFILEGETPROPERTY Get property of OCT file
%   data = OCTFILEGETPROPERTY( handle, propertyName ) Get property of OCT file
%
%   Some example properties are: RefractiveIndex, AcquisitionMode. More
%   properties can be examined by looking at the Header.xml file in the
%   root of the OCT file.
%
  property = lookupField(handle.head, propertyName);
end

function res = lookupField(S, propertyName)
  res = [];
  if ~isstruct(S)
     return 
  end
  SNames = fieldnames(S);
  for loopIndex = 1:numel(SNames)
      if ~isempty(strfind(SNames{loopIndex},propertyName))
         res = S.(SNames{loopIndex}).Text;
         return
      else
          r = lookupField(S.(SNames{loopIndex}), propertyName);
          if ~isempty(r)
             res = r;
             return
          end
      end
  end
end