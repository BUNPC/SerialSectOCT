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
// This program demonstrates how to configure a ATS9120 to make a streamtomemory
// CS acquisition. In this scheme, a buffer large enough to contain the large
// acquisition is allocated, and segments of this buffer are posted in turn to the board as DMA
// buffers.
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

// TODO: Select the number of DMA buffers that are posted to the board at any time. The default
// value should be good for all applications, and therefore should not need to be changed.

#define POSTED_BUFFER_COUNT 4

double samplesPerSec = 0.;

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

    samplesPerSec = 20000000.0;

    // TODO: Select clock parameters as required to generate this sample rate.
    //
    // For example: if samplesPerSec is 100.e6 (100 MS/s), then:
    // - select clock source INTERNAL_CLOCK and sample rate SAMPLE_RATE_100MSPS
    // - select clock source FAST_EXTERNAL_CLOCK, sample rate SAMPLE_RATE_USER_DEF, and connect a
    //   100 MHz signal to the EXT CLK BNC connector.

    retCode = AlazarSetCaptureClock(boardHandle,
                                    INTERNAL_CLOCK,
                                    SAMPLE_RATE_20MSPS,
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
                                   DC_COUPLING,
                                   INPUT_RANGE_PM_400_MV,
                                   IMPEDANCE_50_OHM);
    if (retCode != ApiSuccess)
    {
        printf("Error: AlazarInputControlEx failed -- %s\n", AlazarErrorToText(retCode));
        return FALSE;
    }
    
    // TODO: Select channel B input parameters as required

    retCode = AlazarInputControlEx(boardHandle,
                                   CHANNEL_B,
                                   DC_COUPLING,
                                   INPUT_RANGE_PM_400_MV,
                                   IMPEDANCE_50_OHM);
    if (retCode != ApiSuccess)
    {
        printf("Error: AlazarInputControlEx failed -- %s\n", AlazarErrorToText(retCode));
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
    // TODO: Select the transfer length, i.e. the number of samples per DMA buffers (i.e. samples
    // per transfer). This value, together with the number of DMA buffers per record will determine
    // the total acquisition length.
    //
    // NOTE: This value *must* be a multiple of 4096, this is because DMA buffers must be
    // page-aligned.
    U32 samplesPerTransfer = 4096 * 100;

    // TODO: Select the number of DMA buffers (i.e. transfers) per record.
    U32 transfersPerAcquisition = 100;

    // TODO: Select which channels to capture (A, B, or both)
    U32 channelMask = CHANNEL_A | CHANNEL_B;

    // TODO: Select if you wish to save the sample data to a file
    BOOL saveData = false;

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

    // Calculate the size of each record in bytes
    float bytesPerSample = (float) ((bitsPerSample + 7) / 8);

    // 0.5 compensates for double to integer conversion
    U32 bytesPerTransfer = (U32) (bytesPerSample * samplesPerTransfer * channelCount + 0.5);
    U64 bytesPerAcquisition = bytesPerTransfer * transfersPerAcquisition;

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

    // Allocate memory for the acquisition
    BOOL success = TRUE;



    // Allocate page aligned memory
    U16 *data = (U16*)AlazarAllocBufferU16(boardHandle, (U32)bytesPerAcquisition);

    if (data == NULL)
    {
        printf("Error: Alloc %llu bytes failed\n", bytesPerAcquisition);
        success = FALSE;
    }

    // Configure the board to make an AutoDMA acquisition
    if (success)
    {
        U32 admaFlags = ADMA_EXTERNAL_STARTCAPTURE | ADMA_CONTINUOUS_MODE | ADMA_FIFO_ONLY_STREAMING | ADMA_ALLOC_BUFFERS;

        retCode = AlazarBeforeAsyncRead(boardHandle, channelMask, 0, samplesPerTransfer, 1,
                                        transfersPerAcquisition, admaFlags);
        if (retCode != ApiSuccess)
        {
            printf("Error: AlazarBeforeAsyncRead failed -- %s\n", AlazarErrorToText(retCode));
            success = FALSE;
        }
    }

    // Add the buffers to a list of buffers available to be filled by the board
    U64 totalBuffersPosted = 0;
    while (totalBuffersPosted < POSTED_BUFFER_COUNT && totalBuffersPosted < transfersPerAcquisition) {
        U16 *pBuffer = data + bytesPerTransfer * totalBuffersPosted / 2;

        retCode = AlazarPostAsyncBuffer(boardHandle, pBuffer, bytesPerTransfer);
        if (retCode != ApiSuccess)
        {
            printf("Error: AlazarPostAsyncBuffer %llu failed -- %s\n", totalBuffersPosted,
                   AlazarErrorToText(retCode));
            success = FALSE;
            break;
        }
        totalBuffersPosted++;
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
        printf("Capturing %d transfers ... press any key to abort\n", transfersPerAcquisition);

        U32 startTickCount = GetTickCount();
        U32 transfersCompleted = 0;
        INT64 bytesTransferred = 0;

        while (transfersCompleted < transfersPerAcquisition)
        {
            // TODO: Set a buffer timeout that is longer than the time
            //       required to capture all the records in one buffer.
            U32 timeout_ms = 5000;
            U16 *pBuffer = data + transfersCompleted * bytesPerTransfer / 2;
            retCode = AlazarWaitAsyncBufferComplete(boardHandle, pBuffer, timeout_ms);
            if (retCode != ApiSuccess)
            {
                printf("Error: AlazarWaitAsyncBufferComplete failed -- %s\n",
                       AlazarErrorToText(retCode));
                success = FALSE;
                break;
            }

            if (totalBuffersPosted < transfersPerAcquisition) {
                pBuffer = data + totalBuffersPosted * bytesPerTransfer / 2;
                retCode = AlazarPostAsyncBuffer(boardHandle, pBuffer, bytesPerTransfer);
                if (retCode != ApiSuccess)
                {
                    printf("Error: AlazarPostAsyncBuffer failed -- %s", AlazarErrorToText(retCode));
                    success = FALSE;
                    break;
                }
                totalBuffersPosted++;
            }

            if (success)
            {
                transfersCompleted++;
                bytesTransferred += bytesPerTransfer;
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
            printf("Completed %u transfers\r", transfersCompleted);
        }

        // Display results
        double transferTime_sec = (GetTickCount() - startTickCount) / 1000.;
        printf("Capture completed in %.2lf sec\n", transferTime_sec);

        double transfersPerSec;
        double bytesPerSec;

        if (transferTime_sec > 0.)
        {
            transfersPerSec = transfersCompleted / transferTime_sec;
            bytesPerSec = bytesTransferred / transferTime_sec;
        }
        else
        {
            transfersPerSec = 0.;
            bytesPerSec = 0.;
        }

        printf("Captured %u transfers (%.4g transfers per sec)\n", transfersCompleted, transfersPerSec);
        printf("Transferred %I64d bytes (%.4g bytes per sec)\n", bytesTransferred, bytesPerSec);
    }

    // Abort the acquisition
    retCode = AlazarAbortAsyncRead(boardHandle);
    if (retCode != ApiSuccess)
    {
        printf("Error: AlazarAbortAsyncRead failed -- %s\n", AlazarErrorToText(retCode));
        success = FALSE;
    }

    // TODO: Process sample data in this record.
    // Samples are arranged in the buffer as follows: S0A, S0B, ..., S1A, S1B, ...
    // with SXY the sample number X of channel Y.
    //
    // A 12-bit sample code is stored in the most significant bits of in each 16-bit
    // sample value.
    // Sample codes are unsigned by default. As a result:
    // - a sample code of 0x0000 represents a negative full scale input signal.
    // - a sample code of 0x8000 represents a ~0V signal.
    // - a sample code of 0xFFFF represents a positive full scale input signal.

    if (saveData)
    {
        // Write record to file
        size_t bytesWritten = fwrite(data, sizeof(BYTE), bytesPerAcquisition, fpData);
        if (bytesWritten != bytesPerAcquisition)
        {
            printf("Error: Write data failed -- %u\n", GetLastError());
        }
    }

    // Free all memory allocated
    if (data != NULL)
    {
        AlazarFreeBufferU16(data, boardHandle);
    }

    // Close the data file
    if (fpData != NULL)
        fclose(fpData);

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