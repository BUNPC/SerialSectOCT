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
% This sample configures an ATS9350 to make a continuous mode
% AutoDMA acqusition, optionally saving the data to file and displaying it
% on screen.
%
% In continuous mode, the digitizer captures a continuous stream of samples
% from each enabled channel. The data can span multiple AutoDMA buffers,
% where each buffer contains a segment of the continuous data stream.

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

% TODO: Select a board system
systemId = int32(1);

% Find the number of boards in the board system
boardCount = AlazarBoardsInSystemBySystemID(systemId);
if boardCount < 1
    fprintf('Error: No boards found in system Id %d\n', systemId);
    return
end
fprintf('System Id %u has %u boards\n', systemId, boardCount);

% Get a handle to each board in the board system
for boardId = 1:boardCount
    boardHandle = AlazarGetBoardBySystemID(systemId, boardId);
    setdatatype(boardHandle, 'voidPtr', 1, 1);
    if boardHandle.Value == 0
        fprintf('Error: Unable to open board system ID %u board ID %u\n', systemId, boardId);
        return
    end
    boardHandleArray(1, boardId) = { boardHandle };
end

% Configure the sample rate, input, and trigger settings of each board
for boardId = 1:boardCount
    boardHandle = boardHandleArray{ 1, boardId };
    if ~configureBoard(boardId, boardHandle)
        fprintf('Error: Configure sytstemId %d board Id %d failed\n', systemId, boardId);
        return
    end
end

% Make an acquisition, optionally saving sample data to a file
fprintf('Acquire from system Id %u\n', systemId);
if ~acquireData(boardCount, boardHandleArray)
    fprintf('Error: Acquisition failed\n');
    return
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Configure board function %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [result] = configureBoard(boardId, boardHandle)
% Configure sample rate, input, and trigger settings

% Call mfile with library definitions
AlazarDefs

% declare global variable used in FnAcquireData.m
global SamplesPerSec

% TODO: Configure board by board Id
fprintf('Configure board Id %u\n', boardId);

% set default return code to indicate failure
result = false;

% TODO: Specify the sample rate (see sample rate id below)
SamplesPerSec = 1000000000.0;

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
        SAMPLE_RATE_1GSPS,... % U32 -- sample rate id
        CLOCK_EDGE_RISING,  ... % U32 -- clock edge id
        0                   ... % U32 -- clock decimation
        );
if retCode ~= ApiSuccess
    fprintf('Error: AlazarSetCaptureClock failed -- %s\n', errorToText(retCode));
    return
end
% TODO: Select channel A input parameters as required
retCode = ...
    AlazarInputControlEx(             ...
        boardHandle,                  ... % HANDLE -- board handle
        CHANNEL_A,     ... % U32 -- input channel
        DC_COUPLING,    ... % U32 -- input coupling id
        INPUT_RANGE_PM_400_MV, ... % U32 -- input range id
        IMPEDANCE_50_OHM    ... % U32 -- input impedance id
        );
if retCode ~= ApiSuccess
    fprintf('Error: AlazarInputControlEx failed -- %s\n', errorToText(retCode));
    return
end

% TODO: Select channel A bandwidth limit as required
retCode = ...
    AlazarSetBWLimit(       ...
        boardHandle,        ... % HANDLE -- board handle
        CHANNEL_A,          ... % U8 -- channel identifier
        0                   ... % U32 -- 0 = disable, 1 = enable
        );
if retCode ~= ApiSuccess
    fprintf('Error: AlazarSetBWLimit failed -- %s\n', errorToText(retCode));
    return
end
% TODO: Select channel B input parameters as required
retCode = ...
    AlazarInputControlEx(             ...
        boardHandle,                  ... % HANDLE -- board handle
        CHANNEL_B,     ... % U32 -- input channel
        DC_COUPLING,    ... % U32 -- input coupling id
        INPUT_RANGE_PM_400_MV, ... % U32 -- input range id
        IMPEDANCE_50_OHM    ... % U32 -- input impedance id
        );
if retCode ~= ApiSuccess
    fprintf('Error: AlazarInputControlEx failed -- %s\n', errorToText(retCode));
    return
end

% TODO: Select channel B bandwidth limit as required
retCode = ...
    AlazarSetBWLimit(       ...
        boardHandle,        ... % HANDLE -- board handle
        CHANNEL_B,          ... % U8 -- channel identifier
        0                   ... % U32 -- 0 = disable, 1 = enable
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
        ETR_5V              ... % U32 -- external trigger range id
        );
if retCode ~= ApiSuccess
    fprintf('Error: AlazarSetExternalTrigger failed -- %s\n', errorToText(retCode));
    return
end

% TODO: Set trigger delay as required.
triggerDelay_sec = 0;
triggerDelay_samples = uint32(floor(triggerDelay_sec * SamplesPerSec + 0.5));
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

result = true;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Acquire data function %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [result] = acquireData(boardCount, boardHandleArray)
% Make an AutoDMA acquisition from dual-ported memory

% global variable set in FnConfigureBoard.m
global SamplesPerSec

% set default return code to indicate failure
result = false;

% Call mfile with library definitions
AlazarDefs
% TODO: Select the total acquisition length in seconds (or 0 to acquire until aborted)
acquisitionLength_sec = 1.;

% TODO: Select the number of samples per channel in each buffer
samplesPerBufferPerChannel = 204800;

% TODO: Select if you wish to save the sample data to a binary file
saveData = false;

% TODO: Select if you wish to plot the data to a chart
drawData = false;

% TODO: Select which channels in each board to acquire data from
% the board system.
channelMask = CHANNEL_A + CHANNEL_B;

% Find the total number of enabled channels in this board system
channelsPerBoard = 2;
channelCount = 0; % Number of enabled channels for *one* board
for channel = 0 : channelsPerBoard - 1
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
systemHandle = boardHandleArray{1, 1};
[retCode, systemHandle, maxSamplesPerRecord, bitsPerSample] = AlazarGetChannelInfo(systemHandle, 0, 0);
if retCode ~= ApiSuccess
    fprintf('Error: AlazarGetChannelInfo failed -- %s\n', errorToText(retCode));
    return
end

bytesPerSample = floor((double(bitsPerSample) + 7) / double(8));
samplesPerBuffer = samplesPerBufferPerChannel * channelCount
bytesPerBuffer = bytesPerSample * samplesPerBuffer;

% Find the number of buffers per channel in the acquisition
samplesPerAcquisition = double(floor((SamplesPerSec * acquisitionLength_sec + 0.5)));
buffersPerAcquisition = uint32(floor((samplesPerAcquisition + samplesPerBufferPerChannel - 1) / samplesPerBufferPerChannel));

% TODO: Select the number of DMA buffers per board to allocate.
% The number of DMA buffers must be greater than 2 to allow a board to DMA into
% one buffer while, at the same time, your application processes another buffer.
buffersPerBoard = uint32(4);

% Create an array of DMA buffers for each board
bufferArray = cell(boardCount, buffersPerBoard);
for boardId = 1 : boardCount
    boardHandle = boardHandleArray{1, boardId};
    for bufferId = 1 : buffersPerBoard
        pbuffer = AlazarAllocBuffer(boardHandle, bytesPerBuffer);
        if pbuffer == 0
            fprintf('Error: AlazarAllocBuffer %u bytes failed\n', bytesPerBuffern);
            return
        end
        bufferArray(boardId, bufferId) = { pbuffer };
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

% TODO: Select AutoDMA flags as required
admaFlags = ADMA_EXTERNAL_STARTCAPTURE + ADMA_CONTINUOUS_MODE;
% Configure each board to make an AutoDMA acquisition
for boardId = 1 : boardCount
    boardHandle = boardHandleArray{1, boardId};
    retCode = AlazarBeforeAsyncRead(boardHandle, ...
                                    channelMask, ...
                                    0, ...                  % Must be 0
                                    samplesPerBufferPerChannel, ...
                                    1, ...                  % Must be 1
                                    hex2dec('7FFFFFFF'), ...  % Ignored. Behaves as if infinite
                                    admaFlags);
    if retCode ~= ApiSuccess
        fprintf('Error: AlazarBeforeAsyncRead failed -- %s\n', errorToText(retCode));
        return
    end
end

% Post buffers to each board
for boardId = 1 : boardCount
    for bufferId = 1 : buffersPerBoard
        boardHandle = boardHandleArray{1, boardId};
        pbuffer = bufferArray{boardId, bufferId};
        retCode = AlazarPostAsyncBuffer(boardHandle, pbuffer, bytesPerBuffer);
        if retCode ~= ApiSuccess
            fprintf('Error: AlazarPostAsyncBuffer failed -- %s\n', errorToText(retCode));
            return
        end
    end
end

% Update status
if buffersPerAcquisition == hex2dec('7FFFFFFF')
    fprintf('Capturing buffers until aborted...\n');
else
    fprintf('Capturing %u buffers ...\n', boardCount * buffersPerAcquisition);
end

% Arm the board system to begin the acquisition
retCode = AlazarStartCapture(systemHandle);
if retCode ~= ApiSuccess
    fprintf('Error: AlazarStartCapture failed -- %s\n', errorToText(retCode));
    return;
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
buffersPerBoardCompleted = 0;
captureDone = false;
success = false;

while ~captureDone

	% Wait for the buffer at the head of list of availalble buffers
	% for each board to be filled.
    bufferId = mod(buffersPerBoardCompleted, buffersPerBoard) + 1;

    for boardId = 1 : boardCount

        % Wait for the buffer at the head of list of availalble buffers
        % for this board to be filled.

        boardHandle = boardHandleArray{1, boardId};
        pbuffer = bufferArray{boardId, bufferId};

        [retCode, boardHandle, bufferOut] = ...
            AlazarWaitAsyncBufferComplete(boardHandle, pbuffer, 5000);
        if retCode == ApiSuccess
            % This buffer is full
            bufferFull = true;
            captureDone = false;
        elseif retCode == ApiWaitTimeout
            % The wait timeout expired before this buffer was filled.
            % The timeout period may be too short.
            fprintf('Error: AlazarWaitAsyncBufferComplete timeout!\n');
            bufferFull = false;
            captureDone = true;
        else
            % The acquisition failed
            fprintf('Error: AlazarWaitAsyncBufferComplete failed -- %s\n', errorToText(retCode));
            bufferFull = false;
            captureDone = true;
        end

        if bufferFull

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
            % Sample code are stored as 8-bit values.
            %
            % Sample codes are unsigned by default. As a result:
            % - a sample code of 0x00 represents a negative full scale input signal.
            % - a sample code of 0x80 represents a ~0V signal.
            % - a sample code of 0xFF represents a positive full scale input signal.

            if bytesPerSample == 1
                setdatatype(bufferOut, 'uint8Ptr', 1, samplesPerBuffer);
            else
                setdatatype(bufferOut, 'uint16Ptr', 1, samplesPerBuffer);
            end

            % Save the buffer to file
            if fid ~= -1
                if bytesPerSample == 1
                    samplesWritten = fwrite(fid, bufferOut.Value, 'uint8');
                else
                    samplesWritten = fwrite(fid, bufferOut.Value, 'uint16');
                end
                if samplesWritten ~= samplesPerBuffer
                    fprintf('Error: Write buffer %u failed\n', buffersCompleted);
                end
            end

            % Display the buffer on screen
            if drawData
                subplot(boardCount, 1, boardId);
                plot(bufferOut.Value);
                title(['Board ', num2str(boardId)]);
            end

            % Make the buffer available to be re-filled by the board
            retCode = AlazarPostAsyncBuffer(boardHandle, pbuffer, bytesPerBuffer);
            if retCode ~= ApiSuccess
                fprintf('Error: AlazarPostAsyncBuffer failed -- %s\n', errorToText(retCode));
                captureDone = true;
                success = false;
            end

        end % if bufferFull

    end % for boardId = 1 : boardCount

    % Update progress
    buffersPerBoardCompleted = buffersPerBoardCompleted + 1;
    if buffersPerBoardCompleted >= buffersPerAcquisition
        captureDone = true;
        success = true;
    elseif toc(updateTickCount) > updateInterval_sec
        updateTickCount = tic;

        % Update waitbar progress
        waitbar(double(buffersPerBoardCompleted) / double(buffersPerAcquisition), ...
                waitbarHandle, ...
                sprintf('Completed %u buffers', buffersPerBoardCompleted * boardCount));

        % Check if waitbar cancel button was pressed
        if getappdata(waitbarHandle,'canceling')
            break
        end
    end
end % while ~captureDone

% Save the transfer time
transferTime_sec = toc(startTickCount);

% Close progress window
delete(waitbarHandle);

% Abort the acquisition
for boardId = 1 : boardCount
    boardHandle = boardHandleArray{1, boardId};
    retCode = AlazarAbortAsyncRead(boardHandle);
    if retCode ~= ApiSuccess
        fprintf('Error: AlazarAbortAsyncRead failed -- %s\n', errorToText(retCode));
    end
end

% Close the data file
if fid ~= -1
    fclose(fid);
end

% Release buffers
for boardId = 1:boardCount
    for bufferId = 1:buffersPerBoard
        boardHandle = boardHandleArray{1, boardId};
        pbuffer = bufferArray{boardId, bufferId};
        retCode = AlazarFreeBuffer(boardHandle, pbuffer);
        if retCode ~= ApiSuccess
            fprintf('Error: AlazarFreeBuffer failed -- %s\n', errorToText(retCode));
        end
        clear pbuffer;
    end
end

% Display results
if buffersPerBoardCompleted > 0
    bytesTransferred = double(buffersPerBoardCompleted) * bytesPerSample * double(samplesPerBuffer) * channelCount * boardCount;
    if transferTime_sec > 0
        buffersPerSec = boardCount * buffersPerBoardCompleted / transferTime_sec;
        bytesPerSec = bytesTransferred / transferTime_sec;
    else
        buffersPerSec = 0;
        bytesPerSec = 0;
    end

    fprintf('Captured %u buffers from %u boards in %g sec (%g buffers per sec)\n', ...
        buffersPerBoardCompleted, boardCount, transferTime_sec, buffersPerSec);
    fprintf('Transferred %u bytes (%.4g bytes per sec)\n', bytesTransferred, bytesPerSec);
end

% set return code to indicate success
result = success;
end