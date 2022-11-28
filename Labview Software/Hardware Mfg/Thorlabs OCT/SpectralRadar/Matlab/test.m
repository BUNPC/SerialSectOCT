% This file shows some example usage of the Matlab OCT scripts
% To use exectute this test file, an OCT dataset name 'testdata.oct' 
% containing a single BScan has to put into this directory

handle = OCTFileOpen('E:\ThorImage DATA\Default\Default_0001_Mode2D.oct');

%%%%% read dataset properties %%%%%%

disp( OCTFileGetProperty(handle, 'AcquisitionMode') );
disp( OCTFileGetProperty(handle, 'RefractiveIndex') );
disp( OCTFileGetProperty(handle, 'Comment') );
disp( OCTFileGetProperty(handle, 'Study') );
disp( OCTFileGetProperty(handle, 'ExperimentNumber') );

%%%%% reading intensity %%%%%%

Intensity = OCTFileGetIntensity(handle);
figure(1);clf;
imagesc(Intensity);

%%%%% reading video image %%%%%%

VideoImage = OCTFileGetColoredData(handle,'VideoImage');
figure(2);clf;
imagesc(VideoImage);

%%%%% reading chirp vector %%%%%%

Chirp = OCTFileGetChirp(handle);
figure(3);clf;
plot(Chirp);

%%%%% reading spectral raw data %%%%%%

NrRawData = OCTFileGetNrRawData(handle);

[RawData, Spectrum] = OCTFileGetRawData(handle, 0);
figure(4);clf;
plot(Spectrum);
figure(5);clf;
imagesc(RawData);

%%%%% close OCT file (deletes temporary files) %%%%%%

OCTFileClose(handle);
