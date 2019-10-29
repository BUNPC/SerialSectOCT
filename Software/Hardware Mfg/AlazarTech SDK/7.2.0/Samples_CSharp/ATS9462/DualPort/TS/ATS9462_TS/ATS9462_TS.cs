//---------------------------------------------------------------------------
//
// Copyright (c) 2008-2015 AlazarTech, Inc.
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
using AlazarTech;

namespace NPT_WaitNextBuffer
{
    // This console program demonstrates how to configure an ATS9462
    // to make a TS AutoDMA acquisition.

    class AcqToDiskApp
    {

        private static double samplesPerSec = 0; 

        static void Main(string[] args)
        {
            // TODO: Select a board
            UInt32 systemId = 1;
            UInt32 boardId = 1;

            // Get a handle to the board
            IntPtr handle = AlazarAPI.AlazarGetBoardBySystemID(systemId, boardId);
            if (handle == IntPtr.Zero)
            {
                Console.WriteLine("Error: Open board {0}:{1} failed.", systemId, boardId);
                return;
            }

            // Configure sample rate, input, and trigger parameters
            if (!ConfigureBoard(handle))
            {
                Console.WriteLine("Error: Configure board {0}:{1} failed", systemId, boardId);
                return;
            }

            // Acquire data from the board to an application buffer,
            // optionally saving the data to file
            if (!AcquireData(handle))
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

        static public bool ConfigureBoard(IntPtr boardHandle)
        {
            UInt32 retCode;
            // TODO: Specify the sample rate (in samples per second),
            //       and appropriate sample rate identifier

            samplesPerSec = 180000000.0;
            UInt32 sampleRateId = AlazarAPI.SAMPLE_RATE_180MSPS;

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

            retCode = AlazarAPI.AlazarInputControlEx(boardHandle,
                                           AlazarAPI.CHANNEL_A,
                                           AlazarAPI.DC_COUPLING,
                                           AlazarAPI.INPUT_RANGE_PM_400_MV,
                                           AlazarAPI.IMPEDANCE_50_OHM);


            if (retCode != AlazarAPI.ApiSuccess)
            {
                Console.WriteLine("Error: AlazarInputControlEx failed -- " + AlazarAPI.AlazarErrorToText(retCode));
                return false;
            }
            
            // TODO: Select channel A bandwidth limit as required

            retCode = AlazarAPI.AlazarSetBWLimit(boardHandle,
                                       AlazarAPI.CHANNEL_A,
                                       0);
            if (retCode != AlazarAPI.ApiSuccess)
            {
                Console.WriteLine("Error: AlazarSetBWLimit failed -- ", AlazarAPI.AlazarErrorToText(retCode));
                return false;
            }

            
            // TODO: Select channel B input parameters as required

            retCode = AlazarAPI.AlazarInputControlEx(boardHandle,
                                           AlazarAPI.CHANNEL_B,
                                           AlazarAPI.DC_COUPLING,
                                           AlazarAPI.INPUT_RANGE_PM_400_MV,
                                           AlazarAPI.IMPEDANCE_50_OHM);


            if (retCode != AlazarAPI.ApiSuccess)
            {
                Console.WriteLine("Error: AlazarInputControlEx failed -- " + AlazarAPI.AlazarErrorToText(retCode));
                return false;
            }
            
            // TODO: Select channel B bandwidth limit as required

            retCode = AlazarAPI.AlazarSetBWLimit(boardHandle,
                                       AlazarAPI.CHANNEL_B,
                                       0);
            if (retCode != AlazarAPI.ApiSuccess)
            {
                Console.WriteLine("Error: AlazarSetBWLimit failed -- ", AlazarAPI.AlazarErrorToText(retCode));
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
                    128);
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
                    AlazarAPI.ETR_5V);

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
                   boardHandle, AlazarAPI.AUX_OUT_TRIGGER, 0);
            if (retCode != AlazarAPI.ApiSuccess)
            {
                Console.WriteLine("Error: AlazarConfigureAuxIO failed -- " +
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

        static public unsafe bool AcquireData(IntPtr boardHandle)
        {

            // TODO: Select the total acquisition length in seconds

            double acquisitionLength_sec = 1;

            UInt32 samplesPerBuffer = 204800;
            
            UInt32 channelMask = AlazarAPI.CHANNEL_A | AlazarAPI.CHANNEL_B;

            // TODO: Select if you wish to save the sample data to a file
            bool saveData = false;

            // Calculate the number of enabled channels from the channel mask
            UInt32 channelCount = 0;
            switch (channelMask)
            {
                case AlazarAPI.CHANNEL_A:
                case AlazarAPI.CHANNEL_B:
                    channelCount = 1;
                    break;
                case AlazarAPI.CHANNEL_A | AlazarAPI.CHANNEL_B:
                    channelCount = 2;
                    break;
                default:
                    Console.WriteLine("Error: Invalid channel mask -- {0}", channelMask);
                    return false;
            }

            // Get the sample size in bits, and the on-board memory size in samples per channel

            Byte bitsPerSample;
            UInt32 maxSamplesPerChannel;
            UInt32 retCode = AlazarAPI.AlazarGetChannelInfo(boardHandle, &maxSamplesPerChannel, &bitsPerSample);
            if (retCode != AlazarAPI.ApiSuccess)
            {
                Console.WriteLine("Error: AlazarGetChannelInfo failed -- " +
                    AlazarAPI.AlazarErrorToText(retCode));
                return false;
            }

            // Calculate the size of each DMA buffer in bytes

            UInt32 bytesPerSample = ((UInt32)bitsPerSample + 7) / 8;
            UInt32 bytesPerBuffer = bytesPerSample * samplesPerBuffer * channelCount;

            // Calculate the number of buffers in the acquisition

            Int64 samplesPerAcquisition =
              (Int64)(samplesPerSec * acquisitionLength_sec + 0.5);
            UInt32 buffersPerAcquisition = (UInt32)(
              (samplesPerAcquisition + samplesPerBuffer - 1) / samplesPerBuffer);

            FileStream fileStream = null;
            bool success = true;

            try
            {
                // Create a data file if required

                if (saveData)
                {
                    fileStream = File.Create(@"data.bin");
                }

                // Allocate memory for sample buffer

                byte[] buffer = new byte[bytesPerBuffer];

                // Cast byte array to short array

                ByteToShortArray byteToShortArray = new ByteToShortArray();
                byteToShortArray.bytes = buffer;

                fixed (short* pBuffer = byteToShortArray.shorts)
                {
                    
                    retCode =
                        AlazarAPI.AlazarBeforeAsyncRead(boardHandle,
                                              channelMask,
                                              0,                     // Must be 0
                                              samplesPerBuffer,
                                              1,                     // Must be 1
                                              0x7FFFFFFF,            // Ignored. Behave as if infinite
                                              AlazarAPI.ADMA_EXTERNAL_STARTCAPTURE | AlazarAPI.ADMA_TRIGGERED_STREAMING | AlazarAPI.ADMA_ALLOC_BUFFERS);
                    if (retCode != AlazarAPI.ApiSuccess)
                    {
                        throw new System.Exception("Error: AlazarBeforeAsyncRead failed -- " + AlazarAPI.AlazarErrorToText(retCode));
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

                        retCode = AlazarAPI.AlazarWaitNextAsyncBufferComplete(boardHandle, pBuffer, bytesPerBuffer, timeout_ms);
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
                        // You MUST finish processing this buffer and post it back to the
                        // board before the board fills all of the available DMA buffers,
                        // and its on-board memory.
                        //
                        // Samples are arranged in the buffer as follows: S0A, S0B, ..., S1A, S1B, ...
                        // with SXY the sample number X of channel Y.
                        //
                        //
                        // Sample codes are unsigned by default. As a result:
                        // - a sample code of 0x0000 represents a negative full scale
                        // input signal.
                        // - a sample code of 0x8000 represents a ~0V signal.
                        // - a sample code of 0xFFFF represents a positive full scale
                        // input signal.
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
                    
                    double buffersPerSec;
                    double bytesPerSec;

                    if (transferTime_sec > 0)
                    {
                        buffersPerSec = buffersCompleted / transferTime_sec;
                        bytesPerSec = bytesTransferred / transferTime_sec;
                    }
                    else
                    {
                        buffersPerSec = 0;
                        bytesPerSec = 0;
                    }

                    Console.WriteLine("Captured {0} buffers ({1:G4} buffers per sec)", buffersCompleted, buffersPerSec);
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