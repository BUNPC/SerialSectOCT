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

% Add path to AlazarTech mfiles
addpath('..\..\..\Include')


%%%%%%%%%%
%% MAIN %%
%%%%%%%%%%

% Call mfile with library definitions
AlazarDefs

% Load driver library
if ~alazarLoadLibrary()
  fprintf('Error: ATSApi.dll not loaded\n');
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

% Configure the board's sample rate, input, and trigger settings
if ~configureBoard(boardHandle)
  fprintf('Error: Board configuration failed\n');
  return
end

% Acquire data, optionally saving it to a file
if ~acquireData(boardHandle)
  fprintf('Error: Acquisition failed\n');
  return
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Configure board function %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [result] = configureBoard(boardHandle)
% Configure sample rate, input, and trigger settings

% Call mfile with library definitions
AlazarDefs

% set default return code to indicate failure
result = false;

% TODO: Specify the sample rate (see sample rate id below)
samplesPerSec = 250000000.0;

% TODO: Select clock parameters as required to generate this sample rate.
%
% For example: if samplesPerSec is 100.e6 (100 MS/s), then:
% - select clock source INTERNAL_CLOCK and sample rate SAMPLE_RATE_100MSPS
% - select clock source FAST_EXTERNAL_CLOCK, sample rate SAMPLE_RATE_USER_DEF,
%   and connect a 100 MHz signalto the EXT CLK BNC connector.

retCode = ...
    AlazarSetCaptureClock(  ...
        boardHandle,        ... % HANDLE -- board handle
        INTERNAL_CLOCK,     ... % U32 -- clock source id
        SAMPLE_RATE_250MSPS, ... % U32 -- sample rate id
        CLOCK_EDGE_RISING,  ... % U32 -- clock edge id
        0                   ... % U32 -- clock decimation
        );
if retCode ~= ApiSuccess
    fprintf('Error: AlazarSetCaptureClock failed -- %s\n', errorToText(retCode));
    return
end
% TODO: Select channel A input parameters as required.
retCode = ...
    AlazarInputControlEx(             ...
        boardHandle,                  ... % HANDLE -- board handle
        CHANNEL_A,     ... % U32 -- input channel
        AC_COUPLING,    ... % U32 -- input coupling id
        INPUT_RANGE_PM_1_V_25, ... % U32 -- input range id
        IMPEDANCE_50_OHM    ... % U32 -- input impedance id
        );
if retCode ~= ApiSuccess
    fprintf('Error: AlazarInputControlEx failed -- %s\n', errorToText(retCode));
    return
end
% TODO: Select channel A bandwidth limit as required
retCode = ...
    AlazarSetBWLimit( ...
        boardHandle,  ... % HANDLE -- board handle
        CHANNEL_A, ... % U8 -- channel identifier
        0             ... % U32 -- 0 = disable, 1 = enable
        );
if retCode ~= ApiSuccess
    fprintf('Error: AlazarSetBWLimit failed -- %s\n', errorToText(retCode));
    return
end
% TODO: Select channel B input parameters as required.
retCode = ...
    AlazarInputControlEx(             ...
        boardHandle,                  ... % HANDLE -- board handle
        CHANNEL_B,     ... % U32 -- input channel
        AC_COUPLING,    ... % U32 -- input coupling id
        INPUT_RANGE_PM_1_V_25, ... % U32 -- input range id
        IMPEDANCE_50_OHM    ... % U32 -- input impedance id
        );
if retCode ~= ApiSuccess
    fprintf('Error: AlazarInputControlEx failed -- %s\n', errorToText(retCode));
    return
end
% TODO: Select channel B bandwidth limit as required
retCode = ...
    AlazarSetBWLimit( ...
        boardHandle,  ... % HANDLE -- board handle
        CHANNEL_B, ... % U8 -- channel identifier
        0             ... % U32 -- 0 = disable, 1 = enable
        );
if retCode ~= ApiSuccess
    fprintf('Error: AlazarSetBWLimit failed -- %s\n', errorToText(retCode));
    return
end

% TODO: Select trigger inputs and levels as required
retCode = ...
    AlazarSetTriggerOperation( ...
        boardHandle,        ... % HANDLE -- board handle
        TRIG_ENGINE_OP_J,   ... % U32 -- trigger operation
        TRIG_ENGINE_J,      ... % U32 -- trigger engine id
        TRIG_CHAN_A,        ... % U32 -- trigger source id
        TRIGGER_SLOPE_POSITIVE, ... % U32 -- trigger slope id
        150,                ... % U32 -- trigger level from 0 (-range) to 255 (+range)
        TRIG_ENGINE_K,      ... % U32 -- trigger engine id
        TRIG_DISABLE,       ... % U32 -- trigger source id for engine K
        TRIGGER_SLOPE_POSITIVE, ... % U32 -- trigger slope id
        128                 ... % U32 -- trigger level from 0 (-range) to 255 (+range)
        );
if retCode ~= ApiSuccess
    fprintf('Error: AlazarSetTriggerOperation failed -- %s\n', errorToText(retCode));
    return
end

% TODO: Select external trigger parameters as required
retCode = ...
    AlazarSetExternalTrigger( ...
        boardHandle,        ... % HANDLE -- board handle
        DC_COUPLING,        ... % U32 -- external trigger coupling id
        ETR_TTL              ... % U32 -- external trigger range id
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
    AlazarSetTriggerTimeOut(    ...
        boardHandle,            ... % HANDLE -- board handle
        triggerTimeout_clocks   ... % U32 -- timeout_sec / 10.e-6 (0 == wait forever)
        );
if retCode ~= ApiSuccess
    fprintf('Error: AlazarSetTriggerTimeOut failed -- %s\n', errorToText(retCode));
    return
end

% TODO: Configure AUX I/O connector as required
retCode = ...
    AlazarConfigureAuxIO(   ...
        boardHandle,        ... % HANDLE -- board handle
        AUX_OUT_TRIGGER,    ... % U32 -- mode
        0                   ... % U32 -- parameter
        );
if retCode ~= ApiSuccess
    fprintf('Error: AlazarConfigureAuxIO failed -- %s\n', errorToText(retCode));
    return
end

% set return code to indicate success
result = true;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Acquire data function %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [result] = acquireData(boardHandle)
% Acquire to on-board memory. After the acquisition is complete,
% transfer data to an application buffer.

% set default return code to indicate failure
result = false;

% Call mfile with library definitions
AlazarDefs

% TODO: Select the number of pre-trigger samples per record
preTriggerSamples = 1024;

%TODO: Select the number of post-trigger samples per record
postTriggerSamples = 1024;

% TODO: Select the number of records in the acquisition
recordsPerCapture = 100;

% TODO: Select the amount of time, in seconds, to wait for a trigger
timeout_sec = 10;

% TODO: Select if you wish to save the sample data to a binary file
saveData = false;

% TODO: Select if you wish to plot the data to a chart
plotData = false;

% TODO: Select which channels read from on-board memory (A, B, or both)
channelMask = CHANNEL_A + CHANNEL_B;

% Calculate the number of enabled channels from the channel mask
channelCount = 0;
channelsPerBoard = 2;
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
[retCode, boardHandle, maxSamplesPerRecord, bitsPerSample] = calllib('ATSApi', 'AlazarGetChannelInfo', boardHandle, 0, 0);
if retCode ~= ApiSuccess
    fprintf('Error: AlazarGetChannelInfo failed -- %s\n', errorToText(retCode));
    return;
end

% Calculate the size of each record in bytes
bytesPerSample = floor((double(bitsPerSample) + 7) / double(8));
samplesPerRecord = uint32(preTriggerSamples + postTriggerSamples);
if samplesPerRecord > maxSamplesPerRecord
    samplesPerRecord = maxSamplesPerRecord;
end
bytesPerRecord = double(bytesPerSample) * samplesPerRecord;

% The buffer must be at least 16 samples larger than the transfer size
samplesPerBuffer = samplesPerRecord + 16;
bytesPerBuffer = samplesPerBuffer * bytesPerSample;

% Set the number of samples per record
retCode = AlazarSetRecordSize(boardHandle, preTriggerSamples, postTriggerSamples);
if retCode ~= ApiSuccess
    fprintf('Error: AlazarSetRecordSize failed -- %s\n', errorToText(retCode));
    return;
end

% Set the number of records in the acquisition
retCode = AlazarSetRecordCount(boardHandle, recordsPerCapture);
if retCode ~= ApiSuccess
    fprintf('Error: AlazarSetRecordCount failed -- %s\n', errorToText(retCode));
    return;
end

% Arm the board system to begin the acquisition
retCode = AlazarStartCapture(boardHandle);
if retCode ~= ApiSuccess
    fprintf('Error: AlazarStartCapture failed -- %s\n', errorToText(retCode));
    return;
end

% Create progress window
waitbarHandle = waitbar(0, ...
                        sprintf('Captured 0 of %u records', recordsPerCapture), ...
                        'Name','Capturing ...', ...
                        'CreateCancelBtn', 'setappdata(gcbf,''canceling'',1)');
setappdata(waitbarHandle, 'canceling', 0);

% Wait for the board to capture all records to on-board memory
fprintf('Capturing %u records ...\n', recordsPerCapture);

tic;
updateTic = tic;
updateInterval_sec = 0.1;
captureDone = false;
triggerTic = tic;
triggerCount = 0;

while ~captureDone
    if ~AlazarBusy(boardHandle)
        % The capture to on-board memory is done
        captureDone = true;
    elseif toc(triggerTic) > timeout_sec
        % The acquisition timeout expired before the capture completed
        % The board may not be triggering, or the capture timeout may be too short.
        fprintf('Error: Capture timeout after %.3f sec -- verify trigger.\n', timeout_sec);
        break;
    elseif toc(updateTic) > updateInterval_sec
        updateTic = tic;
        % Check if the waitbar cancel button was pressed
        if getappdata(waitbarHandle,'canceling')
            break
        end
        % Get the number of records captured = triggers received
        [retCode, boardHandle, recordsCaptured] = AlazarGetParameter(boardHandle, 0, GET_RECORDS_CAPTURED, 0);
        if retCode ~= ApiSuccess
            fprintf('Error: AlazarGetParameter failed -- %s\n', errorToText(retCode));
            break;
        end
        if triggerCount ~= recordsCaptured
            % Update the waitbar progress
            waitbar(double(recordsCaptured) / double(recordsPerCapture), ...
                    waitbarHandle, ...
                    sprintf('Captured %u of %u records', recordsCaptured, recordsPerCapture));
            % Reset the trigger timeout counter
            triggerCount = recordsCaptured;
            triggerTic = tic;
        end
    else
        % Wait for triggers
        pause(0.01);
    end
end

% Close progress bar
delete(waitbarHandle);

if ~captureDone
    % Abort the acquisition
    retCode = AlazarAbortCapture(boardHandle);
    if retCode ~= ApiSuccess
        fprintf('Error: AlazarAbortCapture failed -- %s\n', errorToText(retCode));
    end
    return;
end

% The board captured all records to on-board memory
captureTime_sec = toc;
if captureTime_sec > 0.
    recordsPerSec = recordsPerCapture / captureTime_sec;
else
    recordsPerSec = 0.;
end
fprintf('Captured %u records in %g sec (%.4g records / sec)\n', recordsPerCapture, captureTime_sec, recordsPerSec);

% Create a buffer to store a record
pbuffer = AlazarAllocBuffer(boardHandle, bytesPerBuffer + 16);
if pbuffer == 0
    fprintf('Error: AlazarAllocBufferU16 %u bytes failed\n', bytesPerBuffer);
    return
end

% Create a data file if required
fid = -1;
if saveData
    fid = fopen('data.bin', 'w');
    if fid == -1
        fprintf('Error: Unable to create data file\n');
    end
end

% Create progress window
waitbarHandle = waitbar(0, ...
                        sprintf('Transferred 0 of %u records', recordsPerCapture), ...
                        'Name','Reading ...', ...
                        'CreateCancelBtn', 'setappdata(gcbf,''canceling'',1)');
setappdata(waitbarHandle, 'canceling', 0);

% Transfer the records from on-board memory to our buffer
fprintf('Transferring %u records ...\n', recordsPerCapture);

tic;
updateTic = tic;
bytesTransferred = 0;
success = true;

for record = 0 : recordsPerCapture - 1
    for channel = 0 : channelsPerBoard - 1
        % Find channel Id from channel index
        channelId = 2 ^ channel;

        % Skip this channel if it's not in channel mask
        if ~bitand(channelId,channelMask)
            continue;
        end

        % Transfer one full record from on-board memory to our buffer
        [retCode, boardHandle, bufferOut] = ...
            AlazarRead(...
                boardHandle,            ...	% HANDLE -- board handle
                channelId,              ...	% U32 -- channel Id
                pbuffer,                ...	% void* -- buffer
                bytesPerSample,         ...	% int -- bytes per sample
                record + 1,             ... % long -- record (1 indexed)
                -int32(preTriggerSamples),   ...	% long -- offset from trigger in samples
                samplesPerRecord		...	% U32 -- samples to transfer
                );
        if retCode ~= ApiSuccess
            fprintf('Error: AlazarRead record %u failed -- %s\n', record, errorToText(retCode));
            success = false;
        else
            bytesTransferred = bytesTransferred + bytesPerRecord;

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
            % Records are arranged in the buffer as follows: R0A, R1A, R2A ... RnA, R0B,
            % R1B, R2B ...
            % with RXY the record number X of channel Y
            %
            %
            % Sample codes are unsigned by default. As a result:
            % - a sample code of 0x0000 represents a negative full scale input signal.
            % - a sample code of 0x8000 represents a ~0V signal.
            % - a sample code of 0xFFFF represents a positive full scale input signal.

            if bytesPerSample == 1
                setdatatype(bufferOut, 'uint8Ptr', 1, samplesPerBuffer);
            else
                setdatatype(bufferOut, 'uint16Ptr', 1, samplesPerBuffer);
            end

            if fid ~= -1
                if bytesPerSample == 1
                    samplesWritten = fwrite(fid, bufferOut.Value(1: samplesPerRecord), 'uint8');
                else
                    samplesWritten = fwrite(fid, bufferOut.Value(1: samplesPerRecord), 'uint16');
                end
                if samplesWritten ~= samplesPerRecord
                    fprintf('Error: Write record %u failed\n', record);
                    success = false;
                end
            end

            if plotData
                plot(bufferOut.Value);
            end
        end

        if ~success
            break;
        end

    end % next channel

    if toc(updateTic) > updateInterval_sec
        % Check if waitbar cancel button was pressed
        if getappdata(waitbarHandle,'canceling')
            break
        end
        % Update progress
        waitbar(double(record) / double(recordsPerCapture), ...
                waitbarHandle, ...
                sprintf('Transferred %u of %u records', record, recordsPerCapture));
        updateTic = tic;
    end

end % next record

% Close progress bar
delete(waitbarHandle);

% Release the buffer
retCode = AlazarFreeBuffer(boardHandle, pbuffer);
if retCode ~= ApiSuccess
    fprintf('Error: AlazarFreeBuffer failed -- %s\n', errorToText(retCode));
end
clear pbuffer;

% Display results
transferTime_sec = toc;
if transferTime_sec > 0.
    bytesPerSec = bytesTransferred / transferTime_sec;
else
    bytesPerSec = 0.;
end
fprintf('Transferred %d bytes in %g sec (%.4g bytes per sec)\n', bytesTransferred, transferTime_sec, bytesPerSec);

% Close the data file
if fid ~= -1
    fclose(fid);
end

% set return code to indicate success
result = true;
end