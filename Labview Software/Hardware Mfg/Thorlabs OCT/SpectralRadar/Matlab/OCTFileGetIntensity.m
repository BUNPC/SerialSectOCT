function [ Intensity ] = OCTFileGetIntensity( handle )
% OCTFILEGETINTENSITY  Get the intensity data from an .oct file.
%   data = OCTFILEGETINTENSITY( handle, dataName ) Get the intensity data from an .oct file.
%
    Intensity = OCTFileGetRealData( handle, 'data\Intensity.data' );
end

