function [ Chirp ] = OCTFileGetChirp( handle )
% OCTFILEGETCHIRP Get the chirp vector in an OCT file
%   data = OCTFILEGETCHIRP( handle ) Get the chirp vector in an OCT file
%
%   The chirp vector describes the lambda to k mapping. This vector is only
%   stored in the OCT file if raw data storage is used.
%
    Chirp = OCTFileGetRealData( handle, 'data\Chirp.data' );
end

