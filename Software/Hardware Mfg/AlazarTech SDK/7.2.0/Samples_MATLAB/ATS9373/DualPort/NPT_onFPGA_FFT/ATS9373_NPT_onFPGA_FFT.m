%---------------------------------------------------------------------------
%
% Copyright (c) 2008-2016 AlazarTech, Inc.
%
% AlazarTech, Inc. licenses this software under specific terms and
% conditions. Use of any of the software or derivatives thereof in any
% product without an AlazarTech digitizer board is strictly prohibited.
%
% AlazarTech, Inc. provides this software AS IS, WITHOUT ANY WARRANTY,
% EXPRESS OR IMPLIED, INCLUDING, WITHOUT LIMITATION, ANY WARRANTY OF
% MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. AlazarTech makes no
% guarantee or representations regarding the use of, or the results of the
% use of, the software and documentation in terms of correctness, accuracy,
% reliability, currentness, or otherwise; and you rely on the software,
% documentation and results solely at your own risk.
%
% IN NO EVENT SHALL ALAZARTECH BE LIABLE FOR ANY LOSS OF USE, LOSS OF
% BUSINESS, LOSS OF PROFITS, INDIRECT, INCIDENTAL, SPECIAL OR CONSEQUENTIAL
% DAMAGES OF ANY KIND. IN NO EVENT SHALL ALAZARTECH%S TOTAL LIABILITY EXCEED
% THE SUM PAID TO ALAZARTECH FOR THE PRODUCT LICENSED HEREUNDER.
%
%---------------------------------------------------------------------------
%
% This sample demonstrates how to configure a ATS9373 to make
% a onFPGA FFT NPT_onFPGA_FFT acquisition.
%

% Add path to AlazarTech mfiles
addpath('..\..\..\Include')


%%%%%%%%%%
%% MAIN %%
%%%%%%%%%%

% Call mfile with library definitions
AlazarDefs

% Load driver library
if ~alazarLoadLibrary()
    fprintf('Error: ATSApi library not loaded\n');
    return
end

% TODO: Select a board
systemId = int32(1);
boardId = int32(1);

% Get a handle to the board
boardHandle = AlazarGetBoardBySystemID(systemId, boardId);
setdatatype(boardHandle, 'voidPtr', 1, 1);
if boardHandle.Value == 0
    fprintf('Error: Unable to open board system ID %u board ID %u\n', systemId, boardId);
    return
end

% Get a handle to the FFT module
numModules = libpointer('uint32Ptr', uint32(0));
retCode = AlazarDSPGetModules(boardHandle, 0, 0, numModules);
if retCode ~= ApiSuccess
    fprintf('Error: AlazarDSPGetModules failed -- %s\n', errorToText(retCode));
    return
end
if numModules.Value < 1
    fprintf('This board does any DSP modules.\n');
    return
end

fftHandle = boardHandle;
retCode = AlazarDSPGetModules(boardHandle, 1, fftHandle, 0);
if retCode ~= ApiSuccess
    fprintf('Error: AlazarDSPGetModules failed -- %s\n', errorToText(retCode));
    return
end

% TODO: Select the record length
recordLength_samples = 2048;

% Configure the board's sample rate, input, and trigger settings
if ~configureBoard(boardHandle, fftHandle, recordLength_samples)
    fprintf('Error: Board configuration failed\n');
    return
end

% Acquire data, optionally saving it to a file
if ~acquireData(boardHandle, fftHandle, recordLength_samples)
    fprintf('Error: Acquisition failed\n');
    return
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Configure board function %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [result] = configureBoard(boardHandle, fftHandle, recordLength_samples)
% Configure sample rate, input, and trigger settings

% Call mfile with library definitions
AlazarDefs

% set default return code to indicate failure
result = false;

% TODO: Select clock parameters as required to generate this sample rate.
%
% For example: if samplesPerSec is 100.e6 (100 MS/s), then:
% - select clock source INTERNAL_CLOCK and sample rate SAMPLE_RATE_100MSPS
% - select clock source FAST_EXTERNAL_CLOCK, sample rate SAMPLE_RATE_USER_DEF,
%   and connect a 100 MHz signalto the EXT CLK BNC connector.

% global variable used in acquireData.m
global samplesPerSec;

samplesPerSec = 4000000000.0;

retCode = ...
    AlazarSetCaptureClock(  ...
        boardHandle,        ... % HANDLE -- board handle
        INTERNAL_CLOCK,     ... % U32 -- clock source id
        SAMPLE_RATE_4000MSPS, ... % U32 -- sample rate id
        CLOCK_EDGE_RISING,  ... % U32 -- clock edge id
        0                   ... % U32 -- clock decimation
        );
if retCode ~= ApiSuccess
    fprintf('Error: AlazarSetCaptureClock failed -- %s\n', errorToText(retCode));
    return
end
% TODO: Select channel A input parameters as required.
retCode = ...
    AlazarInputControlEx( ...
        boardHandle, ... % HANDLE -- board handle
        CHANNEL_A, ... % U32 -- input channel
        DC_COUPLING, ... % U32 -- input coupling id
        INPUT_RANGE_PM_400_MV, ... % U32 -- input range id
        IMPEDANCE_50_OHM ... % U32 -- input impedance id
        );
if retCode ~= ApiSuccess
    fprintf('Error: AlazarInputControlEx failed -- %s\n', errorToText(retCode));
    return
end
% TODO: Select channel B input parameters as required.
retCode = ...
    AlazarInputControlEx( ...
        boardHandle, ... % HANDLE -- board handle
        CHANNEL_B, ... % U32 -- input channel
        DC_COUPLING, ... % U32 -- input coupling id
        INPUT_RANGE_PM_400_MV, ... % U32 -- input range id
        IMPEDANCE_50_OHM ... % U32 -- input impedance id
        );
if retCode ~= ApiSuccess
    fprintf('Error: AlazarInputControlEx failed -- %s\n', errorToText(retCode));
    return
end

% TODO: Select trigger inputs and levels as required
retCode = ...
    AlazarSetTriggerOperation( ...
        boardHandle, ... % HANDLE -- board handle
        TRIG_ENGINE_OP_J, ... % U32 -- trigger operation
        TRIG_ENGINE_J, ... % U32 -- trigger engine id
        TRIG_CHAN_A, ... % U32 -- trigger source id
        TRIGGER_SLOPE_POSITIVE, ... % U32 -- trigger slope id
        150, ... % U32 -- trigger level from 0 (-range) to 255 (+range)
        TRIG_ENGINE_K, ... % U32 -- trigger engine id
        TRIG_DISABLE, ... % U32 -- trigger source id for engine K
        TRIGGER_SLOPE_POSITIVE, ... % U32 -- trigger slope id
        128 ... % U32 -- trigger level from 0 (-range) to 255 (+range)
        );
if retCode ~= ApiSuccess
    fprintf('Error: AlazarSetTriggerOperation failed -- %s\n', errorToText(retCode));
    return
end

% TODO: Select external trigger parameters as required
retCode = ...
    AlazarSetExternalTrigger( ...
        boardHandle, ... % HANDLE -- board handle
        DC_COUPLING, ... % U32 -- external trigger coupling id
        ETR_TTL ... % U32 -- external trigger range id
        );
if retCode ~= ApiSuccess
    fprintf('Error: AlazarSetExternalTrigger failed -- %s\n', errorToText(retCode));
    return
end

% TODO: Set trigger delay as required.
triggerDelay_sec = 0;
triggerDelay_samples = uint32(floor(triggerDelay_sec * samplesPerSec + 0.5));
retCode = AlazarSetTriggerDelay(boardHandle, triggerDelay_samples);
if retCode ~= ApiSuccess
    fprintf('Error: AlazarSetTriggerDelay failed -- %s\n', errorToText(retCode));
    return;
end

% TODO: Set trigger timeout as required.

% NOTE:
% The board will wait for a for this amount of time for a trigger event.
% If a trigger event does not arrive, then the board will automatically
% trigger. Set the trigger timeout value to 0 to force the board to wait
% forever for a trigger event.
%
% IMPORTANT:
% The trigger timeout value should be set to zero after appropriate
% trigger parameters have been determined, otherwise the
% board may trigger if the timeout interval expires before a
% hardware trigger event arrives.
triggerTimeout_sec = 0;
triggerTimeout_clocks = uint32(floor(triggerTimeout_sec / 10.e-6 + 0.5));
retCode = ...
    AlazarSetTriggerTimeOut( ...
        boardHandle, ... % HANDLE -- board handle
        triggerTimeout_clocks ... % U32 -- timeout_sec / 10.e-6 (0 == wait forever)
        );
if retCode ~= ApiSuccess
    fprintf('Error: AlazarSetTriggerTimeOut failed -- %s\n', errorToText(retCode));
    return
end

% TODO: Configure AUX I/O connector as required
retCode = ...
    AlazarConfigureAuxIO( ...
        boardHandle, ... % HANDLE -- board handle
        AUX_OUT_TRIGGER, ... % U32 -- mode
        0 ... % U32 -- parameter
        );
if retCode ~= ApiSuccess
    fprintf('Error: AlazarConfigureAuxIO failed -- %s\n', errorToText(retCode));
    return
end

% FFT Configuration
dspModuleId = libpointer('uint32Ptr', zeros(1));
retCode = ...
    AlazarDSPGetInfo( ...
        fftHandle, ...
        dspModuleId, ...
        0, 0, 0, 0, 0 ...
        );
if retCode ~= ApiSuccess
    fprintf('Error: AlazarDSPGetInfo failed -- %s\n', errorToText(retCode));
    return
end
if (dspModuleId.Value ~= DSP_MODULE_FFT)
    fprintf('Error: DSP module is not FFT\n');
    return
end

fftLength_samples = 1;
while fftLength_samples < recordLength_samples
    fftLength_samples = fftLength_samples * 2;
end

% TODO: Select the window function type
windowType = DSP_WINDOW_HANNING;

% Create and fill the window function
window = libpointer('singlePtr', ones(fftLength_samples, 1));
retCode = ...
    AlazarDSPGenerateWindowFunction( ...
        windowType, ...
        window, ...
        recordLength_samples, ...
        fftLength_samples - recordLength_samples ...
        );
if retCode ~= ApiSuccess
    fprintf('Error: AlazarDSPGenerateWindowFunction failed -- %s\n', errorToText(retCode));
    return
end

% Set the window function
retCode = ...
    AlazarFFTSetWindowFunction( ...
        fftHandle, ...
        fftLength_samples, ...
        window, ...
        0 ...
        );
if retCode ~= ApiSuccess
    fprintf('Error: AlazarFFTSetWindowFunction failed -- %s\n', errorToText(retCode));
    return
end

% TODO: Select the background subtraction record
backgroundSubtractionRecord = libpointer('int16Ptr', zeros(recordLength_samples, 1));

retCode = ...
    AlazarFFTBackgroundSubtractionSetRecordS16( ...
        fftHandle, ...
        backgroundSubtractionRecord, ...
        recordLength_samples ...
        );
if retCode ~= ApiSuccess
    fprintf('Error: AlazarFFTBackgroundSubtractionSetRecordS16 failed -- %s\n', errorToText(retCode));
    return
end

retCode = ...
    AlazarFFTBackgroundSubtractionSetEnabled( ...
        fftHandle, ...
        true ...
        );
if retCode ~= ApiSuccess
    fprintf('Error: AlazarFFTBackgroundSubtractionSetEnabled failed -- %s\n', errorToText(retCode));
    return
end

% set return code to indicate success
result = true;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Acquire data function %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [result] = acquireData(boardHandle, fftHandle, recordLength_samples)
% Make an AutoDMA acquisition from dual-ported memory.

% global variable set in configureBoard.m
global samplesPerSec;

% set default return code to indicate failure
result = false;

% call mfile with library definitions
AlazarDefs

% TODO: Specify the number of records per DMA buffer
recordsPerBuffer = 10;

% TODO: Specify the total number of buffers to capture
buffersPerAcquisition = 10;

% Single channel only
channelMask = CHANNEL_A;

% TODO: Select if you wish to save the sample data to a binary file
saveData = false;

% TODO: Select if you wish to plot the data to a chart
drawData = false;

% TODO: Select the FFT output format
outputFormat = FFT_OUTPUT_FORMAT_U16_LOG;

% TODO: Select the presence of NPT footers
footer = FFT_FOOTER_NONE;

% Calculate the number of enabled channels from the channel mask
channelCount = 0;
channelsPerBoard = 1;
for channel = 0:channelsPerBoard - 1
    channelId = 2^channel;
    if bitand(channelId, channelMask)
        channelCount = channelCount + 1;
    end
end

if (channelCount < 1) || (channelCount > channelsPerBoard)
    fprintf('Error: Invalid channel mask %08X\n', channelMask);
    return
end

% Get the sample and memory size
[retCode, boardHandle, maxSamplesPerRecord, bitsPerSample] = AlazarGetChannelInfo(boardHandle, 0, 0);
if retCode ~= ApiSuccess
    fprintf('Error: AlazarGetChannelInfo failed -- %s\n', errorToText(retCode));
    return
end

% Configure the FFT
fftLength_samples = 1;
while fftLength_samples < recordLength_samples
        fftLength_samples = fftLength_samples * 2;
end

bytesPerOutputRecord = libpointer('uint32Ptr', zeros(1));
retCode = AlazarFFTSetup( ...
    fftHandle, ...
    channelMask, ...
    recordLength_samples, ...
    fftLength_samples, ...
    outputFormat, ...
    footer, ...
    0, ...
    bytesPerOutputRecord);
if retCode ~= ApiSuccess
    printf('Error: AlazarSetRecordSize failed -- %s\n', AlazarErrorToText(retCode));
    return
end

samplesPerBuffer = (fftLength_samples / 2) * recordsPerBuffer * channelCount;
bytesPerBuffer = bytesPerOutputRecord.Value * recordsPerBuffer;

% TODO: Select the number of DMA buffers to allocate.
% The number of DMA buffers must be greater than 2 to allow a board to DMA into
% one buffer while, at the same time, your application processes another buffer.
bufferCount = uint32(4);

% Create an array of DMA buffers
buffers = cell(1, bufferCount);
for bufferIndex = 1 : bufferCount
    pbuffer = AlazarAllocBuffer( ...
                boardHandle, ...
                bytesPerBuffer ...
                );
    if pbuffer == 0
        fprintf('Error: AlazarAllocBuffer %u samples failed\n', samplesPerBuffer);
        return
    end
    buffers(1, bufferIndex) = { pbuffer };
end

% TODO: Select AutoDMA flags as required
admaFlags = ADMA_EXTERNAL_STARTCAPTURE + ADMA_NPT + ADMA_DSP;

retCode = AlazarBeforeAsyncRead( ...
    boardHandle, ...
    channelMask, ...
    0, ...
    bytesPerOutputRecord.Value, ...
    recordsPerBuffer, ...
    hex2dec('7FFFFFFF'), ...
    admaFlags ...
    );
if retCode ~= ApiSuccess
    fprintf('Error: AlazarBeforeAsyncRead failed -- %s\n', errorToText(retCode));
    return
end

% Post the buffers to the board
for bufferIndex = 1 : bufferCount
    pbuffer = buffers{1, bufferIndex};
    retCode = AlazarPostAsyncBuffer( ...
                boardHandle, ...
                pbuffer, ...
                bytesPerBuffer ...
                );
    if retCode ~= ApiSuccess
        fprintf('Error: AlazarPostAsyncBuffer failed -- %s\n', errorToText(retCode));
        return
    end
end

% Create a data file if required
fid = -1;
if saveData
    fid = fopen('data.bin', 'w');
    if fid == -1
        fprintf('Error: Unable to create data file\n');
    end
end

% Update status
if buffersPerAcquisition == hex2dec('7FFFFFFF')
    fprintf('Capturing buffers until aborted...\n');
else
    fprintf('Capturing %u buffers ...\n', buffersPerAcquisition);
end

% Arm the board system to wait for triggers
retCode = AlazarStartCapture(boardHandle);
if retCode ~= ApiSuccess
    fprintf('Error: AlazarStartCapture failed -- %s\n', errorToText(retCode));
    return
end

% Create a progress window
waitbarHandle = waitbar(0, ...
                        'Captured 0 buffers', ...
                        'Name','Capturing ...', ...
                        'CreateCancelBtn', 'setappdata(gcbf,''canceling'',1)');
setappdata(waitbarHandle, 'canceling', 0);

% Wait for sufficient data to arrive to fill a buffer, process the buffer,
% and repeat until the acquisition is complete
startTickCount = tic;
updateTickCount = tic;
updateInterval_sec = 0.1;
buffersCompleted = 0;
captureDone = false;
success = false;

while ~captureDone

    bufferIndex = mod(buffersCompleted, bufferCount) + 1;
    pbuffer = buffers{1, bufferIndex};

    % Wait for the first available buffer to be filled by the board
    [retCode, boardHandle, bufferOut] = ...
        AlazarDSPGetBuffer( ...
            boardHandle, ...
            pbuffer, ...
            5000 ...
            );
    if retCode == ApiSuccess
        % This buffer is full
        bufferFull = true;
        captureDone = false;
    elseif retCode == ApiWaitTimeout
        % The wait timeout expired before this buffer was filled.
        % The board may not be triggering, or the timeout period may be too short.
        fprintf('Error: AlazarDSPGetBuffer timeout -- Verify trigger!\n');
        bufferFull = false;
        captureDone = true;
    else
        % The acquisition failed
        fprintf('Error: AlazarDSPGetBuffer failed -- %s\n', errorToText(retCode));
        bufferFull = false;
        captureDone = true;
    end

    if bufferFull
        % TODO: Process sample data in this buffer.
        %
        % NOTE:
        %
        % While you are processing this buffer, the board is already
        % filling the next available buffer(s).
        %
        % You MUST finish processing this buffer and post it back to the
        % board before the board fills all of its available DMA buffers
        % and on-board memory.
        %

        if (outputFormat == FFT_OUTPUT_FORMAT_U8_LOG) || ...
           (outputFormat == FFT_OUTPUT_FORMAT_U8_AMP2)
            setdatatype(bufferOut, 'uint8Ptr', 1, samplesPerBuffer);
        elseif (outputFormat == FFT_OUTPUT_FORMAT_U16_LOG) || ...
               (outputFormat == FFT_OUTPUT_FORMAT_U16_AMP2)
           setdatatype(bufferOut, 'uint16Ptr', 1, samplesPerBuffer);
        elseif outputFormat == FFT_OUTPUT_FORMAT_U32
            setdatatype(bufferOut, 'uint32Ptr', 1, samplesPerBuffer);
        elseif (outputFormat == FFT_OUTPUT_FORMAT_REAL_S32) || ...
                (outputFormat == FFT_OUTPUT_FORMAT_IMAG_S32)
            setdatatype(bufferOut, 'int32Ptr', 1, samplesPerBuffer);
        else
            setdatatype(bufferOut, 'singlePtr', 1, samplesPerBuffer);
        end

        % Save the buffer to file
        if fid ~= -1
            samplesWritten = fwrite(fid, bufferOut.Value, 'uint16');
            if samplesWritten ~= samplesPerBuffer
                fprintf('Error: Write buffer %u failed\n', buffersCompleted);
            end
        end

        % Display the buffer on screen
        if drawData
            plot(bufferOut.Value);
        end

        % Make the buffer available to be filled again by the board
        retCode = AlazarPostAsyncBuffer(boardHandle, pbuffer, bytesPerBuffer);
        if retCode ~= ApiSuccess
            fprintf('Error: AlazarPostAsyncBuffer failed -- %s\n', errorToText(retCode));
            captureDone = true;
        end

        % Update progress
        buffersCompleted = buffersCompleted + 1;
        if buffersCompleted >= buffersPerAcquisition
            captureDone = true;
            success = true;
        elseif toc(updateTickCount) > updateInterval_sec
            updateTickCount = tic;

            % Update waitbar progress
            waitbar(double(buffersCompleted) / double(buffersPerAcquisition), ...
                    waitbarHandle, ...
                    sprintf('Completed %u buffers', buffersCompleted));

            % Check if waitbar cancel button was pressed
            if getappdata(waitbarHandle,'canceling')
                break
            end
        end

    end % if bufferFull

end % while ~captureDone

% Save the transfer time
transferTime_sec = toc(startTickCount);

% Close progress window
delete(waitbarHandle);

% Abort the acquisition
retCode = AlazarAbortAsyncRead(boardHandle);
if retCode ~= ApiSuccess
    fprintf('Error: AlazarAbortAsyncRead failed -- %s\n', errorToText(retCode));
end

% Close the data file
if fid ~= -1
    fclose(fid);
end

% Release the buffers
for bufferIndex = 1 : bufferCount
    pbuffer = buffers{1, bufferIndex};
    retCode = AlazarFreeBuffer(boardHandle, pbuffer);
    if retCode ~= ApiSuccess
        fprintf('Error: AlazarFreeBuffer failed -- %s\n', errorToText(retCode));
    end
    clear pbuffer;
end

% Display results
if buffersCompleted > 0
    bytesTransferred = double(buffersCompleted) * double(bytesPerBuffer);
    recordsTransferred = recordsPerBuffer * buffersCompleted;

    if transferTime_sec > 0
        buffersPerSec = buffersCompleted / transferTime_sec;
        bytesPerSec = bytesTransferred / transferTime_sec;
        recordsPerSec = recordsTransferred / transferTime_sec;
    else
        buffersPerSec = 0;
        bytesPerSec = 0;
        recordsPerSec = 0.;
    end

    fprintf('Captured %u buffers in %g sec (%g buffers per sec)\n', buffersCompleted, transferTime_sec, buffersPerSec);
    fprintf('Captured %u records (%.4g records per sec)\n', recordsTransferred, recordsPerSec);
    fprintf('Transferred %u bytes (%.4g bytes per sec)\n', bytesTransferred, bytesPerSec);
end

% set return code to indicate success
result = success;
end