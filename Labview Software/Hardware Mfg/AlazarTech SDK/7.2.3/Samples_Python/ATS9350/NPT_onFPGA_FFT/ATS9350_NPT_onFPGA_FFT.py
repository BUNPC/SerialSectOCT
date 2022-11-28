from __future__ import division
import ctypes
from ctypes import *
import numpy as np
import os
import signal
import sys
import time

sys.path.append(os.path.join(os.path.dirname(__file__), '../..', 'Library'))
import atsapi as ats

# Configures a board for acquisition
def ConfigureBoard(board, fft_module, recordLength_samples):
    # TODO: Select clock parameters as required to generate this
    # sample rate
    #
    # For example: if samplesPerSec is 100e6 (100 MS/s), then you can
    # either:
    #  - select clock source INTERNAL_CLOCK and sample rate
    #    SAMPLE_RATE_100MSPS
    #  - or select clock source FAST_EXTERNAL_CLOCK, sample rate
    #    SAMPLE_RATE_USER_DEF, and connect a 100MHz signal to the
    #    EXT CLK BNC connector
    samplesPerSec = 500000000.0
    board.setCaptureClock(ats.INTERNAL_CLOCK,
                          ats.SAMPLE_RATE_500MSPS,
                          ats.CLOCK_EDGE_RISING,
                          0)
    
    
    # TODO: Select channel A input parameters as required.
    board.inputControlEx(ats.CHANNEL_A,
                         ats.DC_COUPLING,
                         ats.INPUT_RANGE_PM_400_MV,
                         ats.IMPEDANCE_50_OHM)
    
    # TODO: Select channel A bandwidth limit as required.
    board.setBWLimit(ats.CHANNEL_A, 0)
    
    
    # TODO: Select channel B input parameters as required.
    board.inputControlEx(ats.CHANNEL_B,
                         ats.DC_COUPLING,
                         ats.INPUT_RANGE_PM_400_MV,
                         ats.IMPEDANCE_50_OHM)
    
    # TODO: Select channel B bandwidth limit as required.
    board.setBWLimit(ats.CHANNEL_B, 0)
    
    # TODO: Select trigger inputs and levels as required.
    board.setTriggerOperation(ats.TRIG_ENGINE_OP_J,
                              ats.TRIG_ENGINE_J,
                              ats.TRIG_CHAN_A,
                              ats.TRIGGER_SLOPE_POSITIVE,
                              150,
                              ats.TRIG_ENGINE_K,
                              ats.TRIG_DISABLE,
                              ats.TRIGGER_SLOPE_POSITIVE,
                              128)

    # TODO: Select external trigger parameters as required.
    board.setExternalTrigger(ats.DC_COUPLING,
                             ats.ETR_5V)

    # TODO: Set trigger delay as required.
    triggerDelay_sec = 0
    triggerDelay_samples = int(triggerDelay_sec * samplesPerSec + 0.5)
    board.setTriggerDelay(triggerDelay_samples)

    # TODO: Set trigger timeout as required.
    #
    # NOTE: The board will wait for a for this amount of time for a
    # trigger event.  If a trigger event does not arrive, then the
    # board will automatically trigger. Set the trigger timeout value
    # to 0 to force the board to wait forever for a trigger event.
    #
    # IMPORTANT: The trigger timeout value should be set to zero after
    # appropriate trigger parameters have been determined, otherwise
    # the board may trigger if the timeout interval expires before a
    # hardware trigger event arrives.
    triggerTimeout_sec = 0
    triggerTimeout_clocks = int(triggerTimeout_sec / 10e-6 + 0.5)
    board.setTriggerTimeOut(triggerTimeout_clocks)

    # Configure AUX I/O connector as required
    board.configureAuxIO(ats.AUX_OUT_TRIGGER,
                         0)
                         
    # FFT Configuration
    
    # TODO: Select the window function type
    windowType = ats.DSP_WINDOW_HANNING;

    id,major,minor,maxLength = fft_module.dspGetInfo()
    if id != ats.DSP_MODULE_FFT:
        print("Error: DSP module is not FFT")
        return

    fftLength_samples = 1;
    while fftLength_samples < recordLength_samples:
        fftLength_samples *= 2;

    # Create and fill the window function
    window = ats.dspGenerateWindowFunction(windowType,
                                           recordLength_samples,
                                           fftLength_samples - recordLength_samples)
    # Set the window function
    fft_module.fftSetWindowFunction(fftLength_samples, 
                                    window.ctypes.data_as(POINTER(c_float)), 
                                    None)

    # TODO: Select the background subtraction record
    backgroundSubtractionRecord = np.zeros((recordLength_samples), dtype=np.int16)
    
    # Background subtraction
    fft_module.fftBackgroundSubtractionSetRecordS16(
                    backgroundSubtractionRecord.ctypes.data_as(POINTER(c_int16)),
                    recordLength_samples)
    
    fft_module.fftBackgroundSubtractionSetEnabled(True);

def AcquireData(board, fft_module, recordLength_samples):
    # TODO: Specify the number of records per DMA buffer
    recordsPerBuffer = 10

    # TODO: Specify the total number of buffers to capture
    buffersPerAcquisition = 10

    # TODO: Select the active channels.
    channels = ats.CHANNEL_A
    channelCount = 0
    for c in ats.channels:
        channelCount += (c & channels == c)

    # TODO: Select the FFT output format
    outputFormat = ats.FFT_OUTPUT_FORMAT_U16_LOG

    # TODO: Select the presence of NPT footers
    footer = ats.FFT_FOOTER_NONE

    # Compute the number of bytes per record and per buffer
    memorySize_samples, bitsPerSample = board.getChannelInfo()

    # TODO: Should data be saved to file?
    saveData = False
    dataFile = None
    if saveData:
        dataFile = open(os.path.join(os.path.dirname(__file__),
                                     "data.bin"), 'wb')

    # Configure the FFT
    fftLength_samples = 1;
    while fftLength_samples < recordLength_samples:
        fftLength_samples *= 2

    bytesPerOutputRecord = fft_module.fftSetup(channels,
                                               recordLength_samples,
                                               fftLength_samples,
                                               outputFormat,
                                               footer,
                                               0)

    bytesPerBuffer = bytesPerOutputRecord * recordsPerBuffer

    # TODO: Select number of DMA buffers to allocate
    bufferCount = 4

    # Allocate DMA buffers
    if ((outputFormat == ats.FFT_OUTPUT_FORMAT_U8_LOG) or
       (outputFormat == ats.FFT_OUTPUT_FORMAT_U8_AMP2)):
        sample_type = ctypes.c_uint8
    elif ((outputFormat == ats.FFT_OUTPUT_FORMAT_U16_LOG) or
         (outputFormat == ats.FFT_OUTPUT_FORMAT_U16_AMP2)):
        sample_type = ctypes.c_uint16
    elif (outputFormat == ats.FFT_OUTPUT_FORMAT_U32):
        sample_type = ctypes.c_uint32
    elif ((outputFormat == ats.FFT_OUTPUT_FORMAT_REAL_S32) or
         (outputFormat == ats.FFT_OUTPUT_FORMAT_IMAG_S32)):
        sample_type = ctypes.c_int32
    else:
        sample_type = ctypes.c_float
       
    buffers = []
    for i in range(bufferCount):
        buffers.append(ats.DMABuffer(board.handle, sample_type, bytesPerBuffer))

    # Configure the board to make an NPT AutoDMA acquisition
    board.beforeAsyncRead(channels,
                          0,
                          bytesPerOutputRecord,
                          recordsPerBuffer,
                          0x7FFFFFFF,
                          ats.ADMA_EXTERNAL_STARTCAPTURE | ats.ADMA_NPT | ats.ADMA_DSP)

    # Post DMA buffers to board
    for buffer in buffers:
        board.postAsyncBuffer(buffer.addr, buffer.size_bytes)

    start = time.clock() # Keep track of when acquisition started
    try:
        board.startCapture() # Start the acquisition
        print("Capturing %d buffers. Press <enter> to abort" %
              buffersPerAcquisition)
        buffersCompleted = 0
        bytesTransferred = 0
        while (buffersCompleted < buffersPerAcquisition and not
               ats.enter_pressed()):
            # Wait for the buffer at the head of the list of available
            # buffers to be filled by the board.
            timeout_ms = 5000
            buffer = buffers[buffersCompleted % len(buffers)]
            board.dspGetBuffer(buffer.addr, timeout_ms)
            buffersCompleted += 1
            bytesTransferred += buffer.size_bytes

            # TODO: Process sample data in this buffer. Data is available
            # as a NumPy array at buffer.buffer

            # NOTE:
            #
            # While you are processing this buffer, the board is already
            # filling the next available buffer(s).
            #
            # You MUST finish processing this buffer and post it back to the
            # board before the board fills all of its available DMA buffers
            # and on-board memory.
            #
            # Samples are arranged in the buffer as follows:
            # S0A, S0B, ..., S1A, S1B, ...
            # with SXY the sample number X of channel Y.
            #
            # A 12-bit sample code is stored in the most significant bits of
            # each 16-bit sample value.
            #
            # Sample codes are unsigned by default. As a result:
            # - 0x0000 represents a negative full scale input signal.
            # - 0x8000 represents a ~0V signal.
            # - 0xFFFF represents a positive full scale input signal.

            # Optionaly save data to file
            if dataFile:
                buffer.buffer.tofile(dataFile)

            # Add the buffer to the end of the list of available buffers.
            board.postAsyncBuffer(buffer.addr, buffer.size_bytes)

    finally:
        board.dspAbortCapture()
        if dataFile:
            dataFile.close()

    # Compute the total transfer time, and display performance information.
    transferTime_sec = time.clock() - start
    print("Capture completed in %f sec" % transferTime_sec)
    buffersPerSec = 0
    bytesPerSec = 0
    recordsPerSec = 0
    if transferTime_sec > 0:
        buffersPerSec = buffersCompleted / transferTime_sec
        bytesPerSec = bytesTransferred / transferTime_sec
        recordsPerSec = recordsPerBuffer * buffersCompleted / transferTime_sec
    print("Captured %d buffers (%f buffers per sec)" %
          (buffersCompleted, buffersPerSec))
    print("Captured %d records (%f records per sec)" %
          (recordsPerBuffer * buffersCompleted, recordsPerSec))
    print("Transferred %d bytes (%f bytes per sec)" %
          (bytesTransferred, bytesPerSec))

if __name__ == "__main__":
    board = ats.Board(systemId = 1, boardId = 1)
    dsp_modules = board.dspGetModules()
    num_modules = len(dsp_modules)
    if num_modules > 0:
        fft_module = dsp_modules[0]
        recordLength_samples = 2048
        ConfigureBoard(board, fft_module, recordLength_samples)
        AcquireData(board, fft_module, recordLength_samples)
    else:
        print("This board does any DSP modules");
    