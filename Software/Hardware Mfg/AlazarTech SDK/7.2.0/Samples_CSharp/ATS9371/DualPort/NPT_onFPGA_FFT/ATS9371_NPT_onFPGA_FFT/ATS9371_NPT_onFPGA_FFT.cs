//---------------------------------------------------------------------------
//
// Copyright (c) 2008-2016 AlazarTech, Inc.
//
// AlazarTech, Inc. licenses this software under specific terms and
// conditions. Use of any of the software or derviatives thereof in any
// product without an AlazarTech digitizer board is strictly prohibited.
//
// AlazarTech, Inc. provides this software AS IS, WITHOUT ANY WARRANTY,
// EXPRESS OR IMPLIED, INCLUDING, WITHOUT LIMITATION, ANY WARRANTY OF
// MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. AlazarTech makes no
// guarantee or representations regarding the use of, or the results of the
// use of, the software and documentation in terms of correctness, accuracy,
// reliability, currentness, or otherwise; and you rely on the software,
// documentation and results solely at your own risk.
//
// IN NO EVENT SHALL ALAZARTECH BE LIABLE FOR ANY LOSS OF USE, LOSS OF
// BUSINESS, LOSS OF PROFITS, INDIRECT, INCIDENTAL, SPECIAL OR CONSEQUENTIAL
// DAMAGES OF ANY KIND. IN NO EVENT SHALL ALAZARTECH'S TOTAL LIABILITY EXCEED
// THE SUM PAID TO ALAZARTECH FOR THE PRODUCT LICENSED HEREUNDER.
//
//---------------------------------------------------------------------------

using System;
using System.IO;
using System.Runtime.InteropServices;
using System.Collections.Generic;
using AlazarTech;

namespace NPT_WaitNextBuffer
{
    // This console program demonstrates how to configure an ATS9371
    // to make a NPT_onFPGA_FFT acquisition.

    class AcqToDiskApp
    {

        private static double samplesPerSec = 0;

        static unsafe void Main(string[] args)
        {
            // TODO: Select a board
            UInt32 systemId = 1;
            UInt32 boardId = 1;

            // Get a handle to the board
            IntPtr boardHandle = AlazarAPI.AlazarGetBoardBySystemID(systemId, boardId);
            if (boardHandle == IntPtr.Zero)
            {
                Console.WriteLine("Error: Open board {0}:{1} failed.", systemId, boardId);
                return;
            }

            // Get a handle to the FFT module
            UInt32 retCode;
            UInt32 numModules;
            IntPtr fftHandle = IntPtr.Zero;
            retCode = AlazarAPI.AlazarDSPGetModules(boardHandle, 0, &fftHandle, &numModules);
            if (numModules < 1)
            {
                Console.WriteLine("This board does any DSP modules");
                return;
            }
            retCode = AlazarAPI.AlazarDSPGetModules(boardHandle, 1, &fftHandle, &numModules);

            // TODO: Select the record length
            UInt32 recordLength_samples = 2048;

            // Configure sample rate, input, and trigger parameters
            if (!ConfigureBoard(boardHandle, fftHandle, recordLength_samples))
            {
                Console.WriteLine("Error: Configure board {0}:{1} failed", systemId, boardId);
                return;
            }

            // Acquire data from the board to an application buffer,
            // optionally saving the data to file
            if (!AcquireData(boardHandle, fftHandle, recordLength_samples))
            {
                Console.WriteLine("Error: Acquire from board {0}:{1} failed", systemId, boardId);
                return;
            }
        }

        //----------------------------------------------------------------------------
        //
        // Function    :  ConfigureBoard
        //
        // Description :  Configure sample rate, input, and trigger settings
        //
        //----------------------------------------------------------------------------

        static public unsafe bool ConfigureBoard(IntPtr boardHandle, IntPtr fftHandle, UInt32 recordLength_samples)
        {
            UInt32 retCode;

            // TODO: Specify the sample rate (in samples per second),
            //       and appropriate sample rate identifier
            samplesPerSec = 1000000000.0;
            UInt32 sampleRateId = AlazarAPI.SAMPLE_RATE_1000MSPS;

            // TODO: Select clock parameters as required.
            retCode =
                AlazarAPI.AlazarSetCaptureClock(
                    boardHandle,
                    AlazarAPI.INTERNAL_CLOCK,
                    sampleRateId,
                    AlazarAPI.CLOCK_EDGE_RISING,
                    0
                    );
            if (retCode != AlazarAPI.ApiSuccess)
            {
                Console.WriteLine("Error: AlazarSetCaptureClock failed -- " +
                    AlazarAPI.AlazarErrorToText(retCode));
                return false;
            }
            
            
            // TODO: Select channel A input parameters as required
            retCode =
                AlazarAPI.AlazarInputControlEx(
                    boardHandle,
                    AlazarAPI.CHANNEL_A,
                    AlazarAPI.DC_COUPLING,
                    AlazarAPI.INPUT_RANGE_PM_400_MV,
                    AlazarAPI.IMPEDANCE_50_OHM
                    );
            if (retCode != AlazarAPI.ApiSuccess)
            {
                Console.WriteLine("Error: AlazarInputControlEx failed -- " +
                    AlazarAPI.AlazarErrorToText(retCode));
                return false;
            }
            
            
            // TODO: Select channel B input parameters as required
            retCode =
                AlazarAPI.AlazarInputControlEx(
                    boardHandle,
                    AlazarAPI.CHANNEL_B,
                    AlazarAPI.DC_COUPLING,
                    AlazarAPI.INPUT_RANGE_PM_400_MV,
                    AlazarAPI.IMPEDANCE_50_OHM
                    );
            if (retCode != AlazarAPI.ApiSuccess)
            {
                Console.WriteLine("Error: AlazarInputControlEx failed -- " +
                    AlazarAPI.AlazarErrorToText(retCode));
                return false;
            }
            
                        
            
            // TODO: Select trigger inputs and levels as required
            retCode =
                AlazarAPI.AlazarSetTriggerOperation(
                    boardHandle,
                    AlazarAPI.TRIG_ENGINE_OP_J,
                    AlazarAPI.TRIG_ENGINE_J,
                    AlazarAPI.TRIG_CHAN_A,
                    AlazarAPI.TRIGGER_SLOPE_POSITIVE,
                    150,
                    AlazarAPI.TRIG_ENGINE_K,
                    AlazarAPI.TRIG_DISABLE,
                    AlazarAPI.TRIGGER_SLOPE_POSITIVE,
                    128
                    );
            if (retCode != AlazarAPI.ApiSuccess)
            {
                Console.WriteLine("Error: AlazarSetTriggerOperation failed -- " +
                    AlazarAPI.AlazarErrorToText(retCode));
                return false;
            }

            // TODO: Select external trigger parameters as required
            retCode =
                AlazarAPI.AlazarSetExternalTrigger(
                    boardHandle,
                    AlazarAPI.DC_COUPLING,
                    AlazarAPI.ETR_TTL
                    );

            if (retCode != AlazarAPI.ApiSuccess)
            {
                Console.WriteLine("Error: AlazarSetExternalTrigger failed -- " +
                    AlazarAPI.AlazarErrorToText(retCode));
                return false;
            }

            // TODO: Set trigger delay as required.
            double triggerDelay_sec = 0;
            UInt32 triggerDelay_samples = (UInt32)(triggerDelay_sec * samplesPerSec + 0.5);
            retCode =
                AlazarAPI.AlazarSetTriggerDelay(
                    boardHandle,
                    triggerDelay_samples
                    );
            if (retCode != AlazarAPI.ApiSuccess)
            {
                Console.WriteLine("Error: AlazarSetTriggerDelay failed -- " +
                    AlazarAPI.AlazarErrorToText(retCode));
                return false;
            }

            // TODO: Set trigger timeout as required.

            // NOTE:
            // The board will wait for a for this amount of time for a trigger event.
            // If a trigger event does not arrive, then the board will automatically
            // trigger. Set the trigger timeout value to 0 to force the board to wait
            // forever for a trigger event.
            //
            // IMPORTANT:
            // The trigger timeout value should be set to zero after appropriate
            // trigger parameters have been determined, otherwise the
            // board may trigger if the timeout interval expires before a
            // hardware trigger event arrives.

            double triggerTimeout_sec = 0;
            UInt32 triggerTimeout_clocks = (UInt32)(triggerTimeout_sec / 10E-6 + 0.5);

            retCode =
                AlazarAPI.AlazarSetTriggerTimeOut(
                    boardHandle,
                    triggerTimeout_clocks
                    );
            if (retCode != AlazarAPI.ApiSuccess)
            {
                Console.WriteLine("Error: AlazarSetTriggerTimeOut failed -- " +
                    AlazarAPI.AlazarErrorToText(retCode));
                return false;
            }

            // TODO: Configure AUX I/O connector as required
            retCode =
                AlazarAPI.AlazarConfigureAuxIO(
                   boardHandle, 
                   AlazarAPI.AUX_OUT_TRIGGER, 
                   0
                   );
            if (retCode != AlazarAPI.ApiSuccess)
            {
                Console.WriteLine("Error: AlazarConfigureAuxIO failed -- " +
                    AlazarAPI.AlazarErrorToText(retCode));
                return false;
            }

            // FFT Configuration
            UInt32 dspModuleId;
            UInt16 versionMajor;
            UInt16 versionMinor;
            UInt32 maxLength;
            UInt32 reserved0;
            UInt32 reserved1;
            retCode = AlazarAPI.AlazarDSPGetInfo(
                        fftHandle, 
                        &dspModuleId, 
                        &versionMajor, 
                        &versionMinor, 
                        &maxLength, 
                        &reserved0, 
                        &reserved1
                        );
            if((AlazarAPI.DSP_MODULE_TYPE)dspModuleId != AlazarAPI.DSP_MODULE_TYPE.DSP_MODULE_FFT)
            {
                Console.WriteLine("Error: DSP module is not FFT");
                return false;
            }

            UInt32 fftLength_samples = 1;
            while (fftLength_samples < recordLength_samples)
                fftLength_samples *= 2;

            // TODO: Select the window function type
            AlazarAPI.DSP_WINDOW_ITEMS windowType = AlazarAPI.DSP_WINDOW_ITEMS.DSP_WINDOW_HANNING;

            // Create and fill the window function
            float[] window = new float[fftLength_samples];
            fixed (float* pWindow = &window[0])
            {
                retCode = AlazarAPI.AlazarDSPGenerateWindowFunction(
                             (UInt32)windowType,
                             pWindow,
                             recordLength_samples,
                             fftLength_samples - recordLength_samples
                             );
                if (retCode != AlazarAPI.ApiSuccess)
                {
                    Console.WriteLine("Error: AlazarDSPGenerateWindowFunction failed -- " +
                        AlazarAPI.AlazarErrorToText(retCode));
                    return false;
                }

                // Set the window function
                retCode = AlazarAPI.AlazarFFTSetWindowFunction(
                             fftHandle,
                             fftLength_samples,
                             pWindow,
                             (float *)0
                             );
                if (retCode != AlazarAPI.ApiSuccess)
                {
                    Console.WriteLine("Error: AlazarFFTSetWindowFunction failed -- " +
                        AlazarAPI.AlazarErrorToText(retCode));
                    return false;
                }
            }

            // TODO: Select the background subtraction record
            Int16[] backgroundSubtractionRecord = new Int16[recordLength_samples];

            // Background subtraction
            fixed (Int16* pBackgroundSubtractionRecord = &backgroundSubtractionRecord[0])
            {
                retCode = AlazarAPI.AlazarFFTBackgroundSubtractionSetRecordS16(
                             fftHandle,
                             pBackgroundSubtractionRecord,
                             recordLength_samples
                             );
                if (retCode != AlazarAPI.ApiSuccess)
                {
                    Console.WriteLine("Error: AlazarFFTBackgroundSubtractionSetRecordS16 failed -- " +
                        AlazarAPI.AlazarErrorToText(retCode));
                    return false;
                }
            }

            retCode = AlazarAPI.AlazarFFTBackgroundSubtractionSetEnabled(
                         fftHandle,
                         true
                         );
            if (retCode != AlazarAPI.ApiSuccess)
            {
                Console.WriteLine("Error: AlazarFFTBackgroundSubtractionSetEnabled failed -- " +
                    AlazarAPI.AlazarErrorToText(retCode));
                return false;
            }

            return true;
        }

        // Use this structure to access a byte array as a short array,
        // without making an intermediate copy in memory.
        [StructLayout(LayoutKind.Explicit)]
        struct ByteToShortArray
        {
            [FieldOffset(0)]
            public byte[] bytes;

            [FieldOffset(0)]
            public short[] shorts;
        }

        //----------------------------------------------------------------------------
        //
        // Function    :  Acquire data
        //
        // Description :  Acquire data from board, optionally saving data to file.
        //
        //----------------------------------------------------------------------------

        static public unsafe bool AcquireData(IntPtr boardHandle, IntPtr fftHandle, UInt32 recordLength_samples)
        {
            UInt32 retCode;
            
            // TODO: Specify the number of records per DMA buffer
            UInt32 recordsPerBuffer = 10;

            // TODO: Specify the total number of buffers to capture
            UInt32 buffersPerAcquisition = 10;

            // Acquiring from a single channel
            UInt32 channelMask = AlazarAPI.CHANNEL_A;

            // TODO: Select if you wish to save the sample data to a file
            bool saveData = false;

            // TODO: Select the FFT output format
            AlazarAPI.FFT_OUTPUT_FORMAT outputFormat = AlazarAPI.FFT_OUTPUT_FORMAT.FFT_OUTPUT_FORMAT_U16_LOG;

            // TODO: Select the presence of NPT footers
            AlazarAPI.FFT_FOOTER footer = AlazarAPI.FFT_FOOTER.FFT_FOOTER_NONE;

            // Get the sample size in bits, and the on-board memory size in samples per channel
            Byte bitsPerSample;
            UInt32 maxSamplesPerChannel;
            retCode = AlazarAPI.AlazarGetChannelInfo(
                         boardHandle,
                         &maxSamplesPerChannel,
                         &bitsPerSample
                         );
            if (retCode != AlazarAPI.ApiSuccess)
            {
                Console.WriteLine("Error: AlazarGetChannelInfo failed -- " +
                    AlazarAPI.AlazarErrorToText(retCode));
                return false;
            }

            FileStream fileStream = null;
            bool success = true;
            try
            {
                // Create a data file if required
                if (saveData)
                {
                    fileStream = File.Create(@"data.bin");
                }

                // Configure the FFT
                UInt32 fftLength_samples = 1;
                while (fftLength_samples < recordLength_samples)
                    fftLength_samples *= 2;

                UInt32 bytesPerOutputRecord;
                retCode = AlazarAPI.AlazarFFTSetup(
                             fftHandle,
                             (UInt16)channelMask,
                             recordLength_samples,
                             fftLength_samples,
                             (UInt32)outputFormat,
                             (UInt32)footer,
                             0,
                             &bytesPerOutputRecord
                             );
                if (retCode != AlazarAPI.ApiSuccess)
                {
                    throw new System.Exception("Error: AlazarFFTSetup failed -- " +
                        AlazarAPI.AlazarErrorToText(retCode));
                }

                UInt32 bytesPerBuffer = bytesPerOutputRecord * recordsPerBuffer;

                // Allocate memory for sample buffer
                byte[] buffer = new byte[bytesPerBuffer];

                // Cast byte array to short array
                ByteToShortArray byteToShortArray = new ByteToShortArray();
                byteToShortArray.bytes = buffer;

                fixed (short* pBuffer = byteToShortArray.shorts)
                {
                    // Configure the board to make an NPT_onFPGA_FFT acquisition
                    UInt32 recordsPerAcquisition = recordsPerBuffer * buffersPerAcquisition;

                    UInt32 admaFlags = AlazarAPI.ADMA_EXTERNAL_STARTCAPTURE | AlazarAPI.ADMA_NPT | AlazarAPI.ADMA_DSP | AlazarAPI.ADMA_FIFO_ONLY_STREAMING | AlazarAPI.ADMA_ALLOC_BUFFERS;

                    retCode = AlazarAPI.AlazarBeforeAsyncRead(
                                 boardHandle,
                                 channelMask,
                                 0,
                                 bytesPerOutputRecord,
                                 recordsPerBuffer,
                                 0x7FFFFFFF,
                                 admaFlags
                                 );
                    if (retCode != AlazarAPI.ApiSuccess)
                    {
                        throw new System.Exception("Error: AlazarBeforeAsyncRead failed -- " +
                            AlazarAPI.AlazarErrorToText(retCode));
                    }

                    // Arm the board to begin the acquisition
                    retCode = AlazarAPI.AlazarStartCapture(boardHandle);
                    if (retCode != AlazarAPI.ApiSuccess)
                    {
                        throw new System.Exception("Error: AlazarStartCapture failed -- " +
                            AlazarAPI.AlazarErrorToText(retCode));
                    }

                    // Wait for each buffer to be filled, then process the buffer

                    Console.WriteLine("Capturing {0} buffers ... press any key to abort",
                        buffersPerAcquisition);

                    int startTickCount = System.Environment.TickCount;

                    UInt32 buffersCompleted = 0;
                    Int64 bytesTransferred = 0;

                    bool done = false;
                    while (!done)
                    {
                        // TODO: Set a buffer timeout that is longer than the time
                        //       required to capture all the records in one buffer.
                        UInt32 timeout_ms = 5000;

                        // Wait for a buffer to be filled by the board.
                        retCode = AlazarAPI.AlazarWaitNextAsyncBufferComplete(
                                     boardHandle,
                                     pBuffer,
                                     bytesPerBuffer,
                                     timeout_ms
                                     );
                        if (retCode == AlazarAPI.ApiSuccess)
                        {
                            // This buffer is full, but there are more buffers in the acquisition.
                        }
                        else if (retCode == AlazarAPI.ApiTransferComplete)
                        {
                            // This buffer is full, and it's the last buffer of the acqusition.
                            done = true;
                        }
                        else
                        {
                            throw new System.Exception("Error: AlazarWaitNextAsyncBufferComplete failed -- " +
                                AlazarAPI.AlazarErrorToText(retCode));
                        }

                        buffersCompleted++;
                        bytesTransferred += bytesPerBuffer;

                        // TODO: Process sample data in this buffer.

                        // NOTE:
                        //
                        // While you are processing this buffer, the board is already
                        // filling the next available buffer(s).
                        //

                        if (saveData)
                        {
                            // Write record to file
                            fileStream.Write(buffer, 0, (int)bytesPerBuffer);
                        }

                        // If a key was pressed, exit the acquisition loop
                        if (Console.KeyAvailable == true)
                        {
                            Console.WriteLine("Aborted...");
                            done = true;
                        }

                        if (buffersCompleted >= buffersPerAcquisition)
                        {
                            done = true;
                        }

                        // Display progress
                        Console.Write("Completed {0} buffers\r", buffersCompleted);
                    }

                    // Display results
                    double transferTime_sec = ((double)(System.Environment.TickCount - startTickCount)) / 1000;
                    Console.WriteLine("Capture completed in {0:N3} sec", transferTime_sec);

                    UInt32 recordsTransferred = recordsPerBuffer * buffersCompleted;

                    double buffersPerSec;
                    double bytesPerSec;
                    double recordsPerSec;

                    if (transferTime_sec > 0)
                    {
                        buffersPerSec = buffersCompleted / transferTime_sec;
                        bytesPerSec = bytesTransferred / transferTime_sec;
                        recordsPerSec = recordsTransferred / transferTime_sec;
                    }
                    else
                    {
                        buffersPerSec = 0;
                        bytesPerSec = 0;
                        recordsPerSec = 0;
                    }

                    Console.WriteLine("Captured {0} buffers ({1:G4} buffers per sec)", buffersCompleted, buffersPerSec);
                    Console.WriteLine("Captured {0} records ({1:G4} records per sec)", recordsTransferred, recordsPerSec);
                    Console.WriteLine("Transferred {0} bytes ({1:G4} bytes per sec)", bytesTransferred, bytesPerSec);
                }
            }
            catch (Exception exception)
            {
                Console.WriteLine(exception.ToString());
                success = false;
            }
            finally
            {
                // Close the data file
                if (fileStream != null)
                    fileStream.Close();

                // Abort the acquisition
                retCode = AlazarAPI.AlazarAbortAsyncRead(boardHandle);
                if (retCode != AlazarAPI.ApiSuccess)
                {
                    Console.WriteLine("Error: AlazarAbortAsyncRead failed -- " +
                        AlazarAPI.AlazarErrorToText(retCode));
                }
            }

            return success;
        }
    }
}