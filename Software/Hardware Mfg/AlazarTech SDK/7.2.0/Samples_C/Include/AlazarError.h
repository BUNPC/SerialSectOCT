/**
 * @file
 *
 * @author Alazar Technologies Inc
 *
 * @copyright Copyright (c) 2016 Alazar Technologies Inc. All Rights
 * Reserved.  Unpublished - rights reserved under the Copyright laws
 * of the United States And Canada.
 * This product contains confidential information and trade secrets
 * of Alazar Technologies Inc. Use, disclosure, or reproduction is
 * prohibited without the prior express written permission of Alazar
 * Technologies Inc
 *
 * This file defines all the error codes for the AlazarTech SDK
 */
#ifndef __ALAZARERROR_H
#define __ALAZARERROR_H

#ifdef __cplusplus
extern "C" {
#endif

/**
 *  @cond INTERNAL_DECLARATIONS
 */
#define API_RETURN_CODE_STARTS 0x200 /* Starting return code */
/**
 *  @endcond
 */

/**
 *  @brief API functions return codes. Failure is #ApiSuccess
 */
enum RETURN_CODE
{
    ApiSuccess = API_RETURN_CODE_STARTS,    ///< 512 - The operation completed without error
    ApiFailed,                              ///< 513 - The operation failed
    ApiAccessDenied,                        ///< 514
    ApiDmaChannelUnavailable,               ///< 515
    ApiDmaChannelInvalid,                   ///< 516
    ApiDmaChannelTypeError,                 ///< 517
    ApiDmaInProgress,                       ///< 518
    ApiDmaDone,                             ///< 519
    ApiDmaPaused,                           ///< 520
    ApiDmaNotPaused,                        ///< 521
    ApiDmaCommandInvalid,                   ///< 522
    ApiDmaManReady,                         ///< 523
    ApiDmaManNotReady,                      ///< 524
    ApiDmaInvalidChannelPriority,           ///< 525
    ApiDmaManCorrupted,                     ///< 526
    ApiDmaInvalidElementIndex,              ///< 527
    ApiDmaNoMoreElements,                   ///< 528
    ApiDmaSglInvalid,                       ///< 529
    ApiDmaSglQueueFull,                     ///< 530
    ApiNullParam,                           ///< 531
    ApiInvalidBusIndex,                     ///< 532
    ApiUnsupportedFunction,                 ///< 533
    ApiInvalidPciSpace,                     ///< 534
    ApiInvalidIopSpace,                     ///< 535
    ApiInvalidSize,                         ///< 536
    ApiInvalidAddress,                      ///< 537
    ApiInvalidAccessType,                   ///< 538
    ApiInvalidIndex,                        ///< 539
    ApiMuNotReady,                          ///< 540
    ApiMuFifoEmpty,                         ///< 541
    ApiMuFifoFull,                          ///< 542
    ApiInvalidRegister,                     ///< 543
    ApiDoorbellClearFailed,                 ///< 544
    ApiInvalidUserPin,                      ///< 545
    ApiInvalidUserState,                    ///< 546
    ApiEepromNotPresent,                    ///< 547
    ApiEepromTypeNotSupported,              ///< 548
    ApiEepromBlank,                         ///< 549
    ApiConfigAccessFailed,                  ///< 550
    ApiInvalidDeviceInfo,                   ///< 551
    ApiNoActiveDriver,                      ///< 552
    ApiInsufficientResources,               ///< 553
    ApiObjectAlreadyAllocated,              ///< 554
    ApiAlreadyInitialized,                  ///< 555
    ApiNotInitialized,                      ///< 556
    ApiBadConfigRegEndianMode,              ///< 557
    ApiInvalidPowerState,                   ///< 558
    ApiPowerDown,                           ///< 559
    ApiFlybyNotSupported,                   ///< 560
    ApiNotSupportThisChannel,               ///< 561
    ApiNoAction,                            ///< 562
    ApiHSNotSupported,                      ///< 563
    ApiVPDNotSupported,                     ///< 564
    ApiVpdNotEnabled,                       ///< 565
    ApiNoMoreCap,                           ///< 566
    ApiInvalidOffset,                       ///< 567
    ApiBadPinDirection,                     ///< 568
    ApiPciTimeout,                          ///< 569
    ApiDmaChannelClosed,                    ///< 570
    ApiDmaChannelError,                     ///< 571
    ApiInvalidHandle,                       ///< 572
    ApiBufferNotReady,                      ///< 573
    ApiInvalidData,                         ///< 574
    ApiDoNothing,                           ///< 575
    ApiDmaSglBuildFailed,                   ///< 576
    ApiPMNotSupported,                      ///< 577
    ApiInvalidDriverVersion,                ///< 578

    /// 579 - The operation did not finish during the timeout interval. try the
    /// operation again, or abort the acquisition.
    ApiWaitTimeout,

    ApiWaitCanceled,                        ///< 580
    ApiBufferTooSmall,                      ///< 581

	/// 582 - The board overflowed its internal (on-board) memory.
    ApiBufferOverflow,

    ApiInvalidBuffer,                       ///< 583
    ApiInvalidRecordsPerBuffer,             ///< 584

	/// 585 - An asynchronous I/O operation was successfully started on the
	/// board. It will be completed when sufficient trigger events are supplied
	/// to the board to fill the buffer.
    ApiDmaPending,

    ApiLockAndProbePagesFailed,             ///< 586
    ApiWaitAbandoned,                       ///< 587
    ApiWaitFailed,                          ///< 588

	/// 589 - This buffer is the last in the current acquisition
    ApiTransferComplete,

	/// 590 - The on-board PLL circuit could not lock. If the acquisition used
	/// an internal sample clock, this might be a symptom of a hardware problem;
	/// contact AlazarTech. If the acquisition used an external 10 MHz PLL
	/// signal, please make sure that the signal is fed in properly.
    ApiPllNotLocked,

	/// 591 - The requested acquisition is not possible with two channels. This
	/// can be due to the sample rate being too fast for DES boards, or to the
	/// number of samples per record being too large.
    ApiNotSupportedInDualChannelMode,

	/// 591 - The requested acquisition is not possible with four channels. This
	/// can be due to the sample rate being too fast for DES boards, or to the
	/// number of samples per record being too large.
    ApiNotSupportedInQuadChannelMode,

	/// 593 - A file read or write error occured.
    ApiFileIoError,

	/// 594 - The requested ADC clock frequency is not supported.
    ApiInvalidClockFrequency,

    ApiInvalidSkipTable,                    ///< 595
    ApiInvalidDspModule,                    ///< 596
    ApiDESOnlySupportedInSingleChannelMode, ///< 597
    ApiInconsistentChannel,                 ///< 598
    ApiDspFiniteRecordsPerAcquisition,      ///< 599
    ApiNotEnoughNptFooters,                 ///< 600
    ApiInvalidNptFooter,                    ///< 601

	/// 602 - OCT ignore bad clock is not supported
    ApiOCTIgnoreBadClockNotSupported,

	/// 603 - The requested number of records in a single-port acquisition
	/// exceeds the maximum supported by the digitizer. Use dual-ported AutoDMA
	/// to acquire more records per acquisition.
    ApiError1,

	/// 604 - The requested number of records in a single-port acquisition
	/// exceeds the maximum supported by the digitizer.
    ApiError2,

	/// 605 - No trigger is detected as part of the OCT ignore bad clock
	/// feature.
    ApiOCTNoTriggerDetected,

	/// 606 - Trigger detected is too fast for the OCT ignore bad clock feature.
    ApiOCTTriggerTooFast,

	/// 607 - There was an isse related to network. Make sure that the network
	/// connection and settings are correct.
    ApiNetworkError,

	/// 608 - On-FPGA FFT cannot support FFT that large. Try reducing the FFT
	/// size, or querying the maximum FFT size with AlazarDSPGetInfo()
    ApiFftSizeTooLarge,

    /// 609 - CUDA returned an error. See log for more information
    ApiGPUError,

	/// @cond INTERNAL_DECLARATIONS
    ApiLastError                            // Do not add API errors below this line
	/// @endcond
};

/// @cond INTERNAL_DECLARATIONS
typedef enum RETURN_CODE RETURN_CODE;
/// @endcond

#ifdef __cplusplus
}
#endif

#endif //__ALAZARERROR_H
