//-------------------------------------------------------------------------------------------------
//
// Copyright (c) 2008-2016 AlazarTech, Inc.
//
// AlazarTech, Inc. licenses this software under specific terms and conditions. Use of any of the
// software or derivatives thereof in any product without an AlazarTech digitizer board is strictly
// prohibited.
//
// AlazarTech, Inc. provides this software AS IS, WITHOUT ANY WARRANTY, EXPRESS OR IMPLIED,
// INCLUDING, WITHOUT LIMITATION, ANY WARRANTY OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR
// PURPOSE. AlazarTech makes no guarantee or representations regarding the use of, or the results of
// the use of, the software and documentation in terms of correctness, accuracy, reliability,
// currentness, or otherwise; and you rely on the software, documentation and results solely at your
// own risk.
//
// IN NO EVENT SHALL ALAZARTECH BE LIABLE FOR ANY LOSS OF USE, LOSS OF BUSINESS, LOSS OF PROFITS,
// INDIRECT, INCIDENTAL, SPECIAL OR CONSEQUENTIAL DAMAGES OF ANY KIND. IN NO EVENT SHALL
// ALAZARTECH'S TOTAL LIABILITY EXCEED THE SUM PAID TO ALAZARTECH FOR THE PRODUCT LICENSED
// HEREUNDER.
//
//-------------------------------------------------------------------------------------------------

// AcqToDisk.cpp :
//
// This program demonstrates how to configure a ATS9625 to make a average
// CS acquisition.
//

#include <stdio.h>
#include <string.h>

#include "AlazarError.h"
#include "AlazarApi.h"
#include "AlazarCmd.h"

#ifdef _WIN32
#include <conio.h>
#else // ifndef _WIN32
#include <errno.h>
#include <math.h>
#include <signal.h>
#include <stdint.h>
#include <stdlib.h>
#include <sys/time.h>
#include <time.h>
#include <unistd.h>

#define TRUE  1
#define FALSE 0

#define _snprintf snprintf

inline U32 GetTickCount(void);
inline void Sleep(U32 dwTime_ms);
inline int _kbhit (void);
inline int GetLastError();
#endif // ifndef _WIN32

// TODO: Select the number of DMA buffers to allocate.

#define BUFFER_COUNT 4

// Globals variables
U16 *BufferArray[BUFFER_COUNT] = { NULL };
double samplesPerSec = 0.0; 


// Forward declarations

BOOL ConfigureBoard(HANDLE boardHandle);
BOOL AcquireData(HANDLE boardHandle);

//-------------------------------------------------------------------------------------------------
//
// Function    :  main
//
// Description :  Program entry point
//
//-------------------------------------------------------------------------------------------------

int main(int argc, char *argv[])
{
    // TODO: Select a board

    U32 systemId = 1;
    U32 boardId = 1;

    // Get a handle to the board

    HANDLE boardHandle = AlazarGetBoardBySystemID(systemId, boardId);
    if (boardHandle == NULL)
    {
        printf("Error: Unable to open board system Id %u board Id %u\n", systemId, boardId);
        return 1;
    }

    // Configure the board's sample rate, input, and trigger settings

    if (!ConfigureBoard(boardHandle))
    {
        printf("Error: Configure board failed\n");
        return 1;
    }

    // Make an acquisition, optionally saving sample data to a file

    if (!AcquireData(boardHandle))
    {
        printf("Error: Acquisition failed\n");
        return 1;
    }

    return 0;
}

//-------------------------------------------------------------------------------------------------
//
// Function    :  ConfigureBoard
//
// Description :  Configure sample rate, input, and trigger settings
//
//-------------------------------------------------------------------------------------------------

BOOL ConfigureBoard(HANDLE boardHandle)
{
    RETURN_CODE retCode;

    // TODO: Specify the sample rate (see sample rate id below)

    samplesPerSec = 250000000.0;

    // TODO: Select clock parameters as required to generate this sample rate.
    //
    // For example: if samplesPerSec is 100.e6 (100 MS/s), then:
    // - select clock source INTERNAL_CLOCK and sample rate SAMPLE_RATE_100MSPS
    // - select clock source FAST_EXTERNAL_CLOCK, sample rate SAMPLE_RATE_USER_DEF, and connect a
    //   100 MHz signal to the EXT CLK BNC connector.

    retCode = AlazarSetCaptureClock(boardHandle,
                                    INTERNAL_CLOCK,
                                    SAMPLE_RATE_250MSPS,
                                    CLOCK_EDGE_RISING,
                                    0);
    if (retCode != ApiSuccess)
    {
        printf("Error: AlazarSetCaptureClock failed -- %s\n", AlazarErrorToText(retCode));
        return FALSE;
    }
     
    
    // TODO: Select channel A input parameters as required

    retCode = AlazarInputControlEx(boardHandle,
                                   CHANNEL_A,
                                   AC_COUPLING,
                                   INPUT_RANGE_PM_1_V_25,
                                   IMPEDANCE_50_OHM);
    if (retCode != ApiSuccess)
    {
        printf("Error: AlazarInputControlEx failed -- %s\n", AlazarErrorToText(retCode));
        return FALSE;
    }
    
    // TODO: Select channel A bandwidth limit as required

    retCode = AlazarSetBWLimit(boardHandle,
                               CHANNEL_A,
                               0);
    if (retCode != ApiSuccess)
    {
        printf("Error: AlazarSetBWLimit failed -- %s\n", AlazarErrorToText(retCode));
        return FALSE;
    }
    
    // TODO: Select channel B input parameters as required

    retCode = AlazarInputControlEx(boardHandle,
                                   CHANNEL_B,
                                   AC_COUPLING,
                                   INPUT_RANGE_PM_1_V_25,
                                   IMPEDANCE_50_OHM);
    if (retCode != ApiSuccess)
    {
        printf("Error: AlazarInputControlEx failed -- %s\n", AlazarErrorToText(retCode));
        return FALSE;
    }
    
    // TODO: Select channel B bandwidth limit as required

    retCode = AlazarSetBWLimit(boardHandle,
                               CHANNEL_B,
                               0);
    if (retCode != ApiSuccess)
    {
        printf("Error: AlazarSetBWLimit failed -- %s\n", AlazarErrorToText(retCode));
        return FALSE;
    }
     
    // TODO: Select trigger inputs and levels as required

    retCode = AlazarSetTriggerOperation(boardHandle,
                                        TRIG_ENGINE_OP_J,
                                        TRIG_ENGINE_J,
                                        TRIG_CHAN_A,
                                        TRIGGER_SLOPE_POSITIVE,
                                        150,
                                        TRIG_ENGINE_K,
                                        TRIG_DISABLE,
                                        TRIGGER_SLOPE_POSITIVE,
                                        128);
    if (retCode != ApiSuccess)
    {
        printf("Error: AlazarSetTriggerOperation failed -- %s\n", AlazarErrorToText(retCode));
        return FALSE;
    }

    // TODO: Select external trigger parameters as required

    retCode = AlazarSetExternalTrigger(boardHandle,
                                       DC_COUPLING,
                                       ETR_TTL);

    // TODO: Set trigger delay as required.

    double triggerDelay_sec = 0;
    U32 triggerDelay_samples = (U32)(triggerDelay_sec * samplesPerSec + 0.5);
    retCode = AlazarSetTriggerDelay(boardHandle, triggerDelay_samples);
    if (retCode != ApiSuccess)
    {
        printf("Error: AlazarSetTriggerDelay failed -- %s\n", AlazarErrorToText(retCode));
        return FALSE;
    }

    // TODO: Set trigger timeout as required.

    // NOTE:
    // The board will wait for a for this amount of time for a trigger event.  If a trigger event
    // does not arrive, then
    // the board will automatically trigger. Set the trigger timeout value to 0 to force the board
    // to wait forever for a
    // trigger event.
    //
    // IMPORTANT:
    // The trigger timeout value should be set to zero after appropriate trigger parameters have
    // been determined,
    // otherwise the board may trigger if the timeout interval expires before a hardware trigger
    // event arrives.

    double triggerTimeout_sec = 0;
    U32 triggerTimeout_clocks = (U32)(triggerTimeout_sec / 10.e-6 + 0.5);

    retCode = AlazarSetTriggerTimeOut(boardHandle, triggerTimeout_clocks);
    if (retCode != ApiSuccess)
    {
        printf("Error: AlazarSetTriggerTimeOut failed -- %s\n", AlazarErrorToText(retCode));
        return FALSE;
    }

    // TODO: Configure AUX I/O connector as required

    retCode = AlazarConfigureAuxIO(boardHandle, AUX_OUT_TRIGGER, 0);
    if (retCode != ApiSuccess)
    {
        printf("Error: AlazarConfigureAuxIO failed -- %s\n", AlazarErrorToText(retCode));
        return FALSE;
    }
    
    return TRUE;
}

//-------------------------------------------------------------------------------------------------
//
// Function    :  AcquireData
//
// Description :  Perform an acquisition, optionally saving data to file.
//
//-------------------------------------------------------------------------------------------------

BOOL AcquireData(HANDLE boardHandle)
{

    // TODO: Select the total acquisition length in seconds
    double acquisitionLength_sec = 1.;
    // TODO: Select the number of samples to average into a point
    U32 samplesPerPoint = 10000;

    // TODO: Select the number of points in each buffer
    U32 pointsPerBufferPerChannel = 64;
    
    // TODO: Select which channels to capture (A, B, or both)
    U32 channelMask = CHANNEL_A | CHANNEL_B;

    // TODO: Select if you wish to save the sample data to a file
    BOOL saveData = false;
    // TODO: Select if you wish to save the averaged points to a file

    BOOL saveAverage = true;

    // Calculate the number of enabled channels from the channel mask
    int channelCount = 0;
    int channelsPerBoard = 2;
    for (int channel = 0; channel < channelsPerBoard; channel++)
    {
        U32 channelId = 1U << channel;
        if (channelMask & channelId)
            channelCount++;
    }

    // Get the sample size in bits, and the on-board memory size in samples per channel
    U8 bitsPerSample;
    U32 maxSamplesPerChannel;
    RETURN_CODE retCode = AlazarGetChannelInfo(boardHandle, &maxSamplesPerChannel, &bitsPerSample);
    if (retCode != ApiSuccess)
    {
        printf("Error: AlazarGetChannelInfo failed -- %s\n", AlazarErrorToText(retCode));
        return FALSE;
    }

    // Calculate the size of each DMA buffer in bytes
    float bytesPerSample = (float) ((bitsPerSample + 7) / 8);
    U32 samplesPerBufferPerChannel = samplesPerPoint * pointsPerBufferPerChannel;
    U32 samplesPerBuffer = samplesPerBufferPerChannel * channelCount;
    U32 bytesPerBuffer = (U32)(bytesPerSample * samplesPerBuffer + 0.5);

    // Calculate the number of buffers in the acquisition
    INT64 samplesPerAcquisitionPerChannel = (INT64)(samplesPerSec * acquisitionLength_sec + 0.5);
    U32 buffersPerAcquisition =
        (U32)((samplesPerAcquisitionPerChannel + samplesPerBufferPerChannel - 1)
              / samplesPerBufferPerChannel);
    
    // Create a data file if required
    FILE *fpData = NULL;

    if (saveData)
    {
        fpData = fopen("data.bin", "wb");
        if (fpData == NULL)
        {
            printf("Error: Unable to create data file -- %u\n", GetLastError());
            return FALSE;
        }
    }
    
    // Create a processed data file if required
    FILE *fpAverage = NULL;

    if (saveAverage)
    {
        fpAverage = fopen("data_ave.bin", "wb");
        if (fpAverage == NULL)
        {
            printf("Error: Unable to create data file -- %u\n", GetLastError());
            return FALSE;
        }
    }

    // Allocate memory for DMA buffers
    BOOL success = TRUE;

    U32 bufferIndex;
    for (bufferIndex = 0; (bufferIndex < BUFFER_COUNT) && success; bufferIndex++)
    {
        // Allocate page aligned memory
        BufferArray[bufferIndex] =
            (U16 *)AlazarAllocBufferU16(boardHandle, bytesPerBuffer);
        if (BufferArray[bufferIndex] == NULL)
        {
            printf("Error: Alloc %u bytes failed\n", bytesPerBuffer);
            success = FALSE;
        }
    }
    // Allocate a buffer to store averaged data
    U32 bytesPerAverageBuffer = (U32)(bytesPerSample * pointsPerBufferPerChannel * channelCount + 0.5);
    U16 *pAveBuffer = (U16*) malloc(bytesPerAverageBuffer);
    if (pAveBuffer == NULL)
    {
        printf("Error: Alloc %u bytes failed\n", bytesPerAverageBuffer);
        success = FALSE;
    } 

    
    if (success)
    {
        U32 admaFlags = ADMA_EXTERNAL_STARTCAPTURE | ADMA_CONTINUOUS_MODE;
        if (channelCount > 1)
            admaFlags |= ADMA_INTERLEAVE_SAMPLES; // Interleave samples for highest transfer rate
        retCode = AlazarBeforeAsyncRead(boardHandle, channelMask,
                                        0, // Must be 0
                                        samplesPerBufferPerChannel,
                                        1,          // Must be 1
                                        0x7FFFFFFF, // Ignored. Behave as if infinite
                                        admaFlags);
        if (retCode != ApiSuccess)
        {
            printf("Error: AlazarBeforeAsyncRead failed -- %s\n", AlazarErrorToText(retCode));
            success = FALSE;
        }
    }
    
    // Add the buffers to a list of buffers available to be filled by the board
    
    for (bufferIndex = 0; (bufferIndex < BUFFER_COUNT) && success; bufferIndex++)
    {
        U16 *pBuffer = BufferArray[bufferIndex];
        retCode = AlazarPostAsyncBuffer(boardHandle, pBuffer, bytesPerBuffer);
        if (retCode != ApiSuccess)
        {
            printf("Error: AlazarPostAsyncBuffer %u failed -- %s\n", bufferIndex,
                   AlazarErrorToText(retCode));
            success = FALSE;
        }
    }
    

    // Arm the board system to wait for a trigger event to begin the acquisition
    if (success)
    {
        retCode = AlazarStartCapture(boardHandle);
        if (retCode != ApiSuccess)
        {
            printf("Error: AlazarStartCapture failed -- %s\n", AlazarErrorToText(retCode));
            success = FALSE;
        }
    }

    // Wait for each buffer to be filled, process the buffer, and re-post it to
    // the board.
    if (success)
    {
        printf("Capturing %d buffers ... press any key to abort\n", buffersPerAcquisition);

        U32 startTickCount = GetTickCount();
        U32 buffersCompleted = 0;
        INT64 bytesTransferred = 0;
        while (buffersCompleted < buffersPerAcquisition)
        {
            // TODO: Set a buffer timeout that is longer than the time
            //       required to capture all the records in one buffer.
            U32 timeout_ms = 5000;

            // Wait for the buffer at the head of the list of available buffers
            // to be filled by the board.
            bufferIndex = buffersCompleted % BUFFER_COUNT; 
            U16 *pBuffer = BufferArray[bufferIndex];
             
            retCode = AlazarWaitAsyncBufferComplete(boardHandle, pBuffer, timeout_ms);
            if (retCode != ApiSuccess)
            {
                printf("Error: AlazarWaitAsyncBufferComplete failed -- %s\n",
                       AlazarErrorToText(retCode));
                success = FALSE;
            }  

            if (success)
            {
                // The buffer is full and has been removed from the list
                // of buffers available for the board

                buffersCompleted++;
                bytesTransferred += bytesPerBuffer;

                // TODO: Process sample data in this buffer.

                // NOTE:
                //
                // While you are processing this buffer, the board is already filling the next
                // available buffer(s).
                //
                // You MUST finish processing this buffer and post it back to the board before
                // the board fills all of its available DMA buffers and on-board memory.
                //
                // Samples are arranged in the buffer as follows: S0A, S0B, ..., S1A, S1B, ...
                // with SXY the sample number X of channel Y.
                // 
                // Sample codes are unsigned by default. As a result:
                // - a sample code of 0x0000 represents a negative full scale input signal.
                // - a sample code of 0x8000 represents a ~0V signal.
                // - a sample code of 0xFFFF represents a positive full scale input signal.  
                if (saveData)
                {
                    // Write record to file
                    size_t bytesWritten = fwrite(pBuffer, sizeof(BYTE), bytesPerBuffer, fpData);
                    if (bytesWritten != bytesPerBuffer)
                    {
                        printf("Error: Write buffer %u failed -- %u\n", buffersCompleted,
                               GetLastError());
                        success = FALSE;
                    }
                } 
                // Calculate the average of "samples per point" samples from the DMA buffer and
                // place the result in the average buffer.
                U16 *pSample = pBuffer;
                for (U32 point = 0; point < pointsPerBufferPerChannel; point++)
                {
                    U64 sums[2] = {0};
                    for (U32 sample = 0; sample < samplesPerPoint; sample++)
                    {
                        for (int i = 0; i < channelCount; i++)
                        {
                            sums[i] += *pSample++;
                        }
                    }

                    for (int i = 0; i < channelCount; i++)
                    {
                        pAveBuffer[point + i * pointsPerBufferPerChannel] =
                            (U16)(sums[i] / samplesPerPoint);
                    }
                }

                // Write processed buffer to file
                if (saveAverage)
                {
                    size_t bytesWritten =
                        fwrite(pAveBuffer, sizeof(BYTE), bytesPerAverageBuffer, fpAverage);
                    if (bytesWritten != bytesPerAverageBuffer)
                    {
                        printf("Error: Write ave buffer %d failed -- %u\n", buffersCompleted,
                               GetLastError());
                        success = FALSE;
                    }
                }
            }

            // Add the buffer to the end of the list of available buffers.
            if (success)
            {
                retCode = AlazarPostAsyncBuffer(boardHandle, pBuffer, bytesPerBuffer);
                if (retCode != ApiSuccess)
                {
                    printf("Error: AlazarPostAsyncBuffer failed -- %s\n",
                           AlazarErrorToText(retCode));
                    success = FALSE;
                }
            }

            // If the acquisition failed, exit the acquisition loop
            if (!success)
                break;

            // If a key was pressed, exit the acquisition loop
            if (_kbhit())
            {
                printf("Aborted...\n");
                break;
            }

            // Display progress
            printf("Completed %u buffers\r", buffersCompleted);
        }

        // Display results
        double transferTime_sec = (GetTickCount() - startTickCount) / 1000.;
        printf("Capture completed in %.2lf sec\n", transferTime_sec);

        double buffersPerSec;
        double bytesPerSec;

        if (transferTime_sec > 0.)
        {
            buffersPerSec = buffersCompleted / transferTime_sec;
            bytesPerSec = bytesTransferred / transferTime_sec;
        }
        else
        {
            buffersPerSec = 0.;
            bytesPerSec = 0.;
        }

        printf("Captured %u buffers (%.4g buffers per sec)\n", buffersCompleted, buffersPerSec);
        printf("Transferred %I64d bytes (%.4g bytes per sec)\n", bytesTransferred, bytesPerSec);
    }

    // Abort the acquisition
    retCode = AlazarAbortAsyncRead(boardHandle);
    if (retCode != ApiSuccess)
    {
        printf("Error: AlazarAbortAsyncRead failed -- %s\n", AlazarErrorToText(retCode));
        success = FALSE;
    }

    // Free all memory allocated
    for (bufferIndex = 0; bufferIndex < BUFFER_COUNT; bufferIndex++)
    {
        if (BufferArray[bufferIndex] != NULL)
        {
			AlazarFreeBufferU16(boardHandle, BufferArray[bufferIndex]);
			
        }
    }
    if (pAveBuffer != NULL)
        free(pAveBuffer);
    

    // Close the data file
    
    if (fpData != NULL)
        fclose(fpData);
    
    if (fpAverage != NULL)
        fclose(fpAverage);

    return success;
} 


#ifndef WIN32
inline U32 GetTickCount(void)
{
	struct timeval tv;
	if (gettimeofday(&tv, NULL) != 0)
		return 0;
	return (tv.tv_sec * 1000) + (tv.tv_usec / 1000);
}

inline void Sleep(U32 dwTime_ms)
{
	usleep(dwTime_ms * 1000);
}

inline int _kbhit (void)
{
  struct timeval tv;
  fd_set rdfs;

  tv.tv_sec = 0;
  tv.tv_usec = 0;

  FD_ZERO(&rdfs);
  FD_SET (STDIN_FILENO, &rdfs);

  select(STDIN_FILENO+1, &rdfs, NULL, NULL, &tv);
  return FD_ISSET(STDIN_FILENO, &rdfs);
}

inline int GetLastError()
{
	return errno;
}
#endif