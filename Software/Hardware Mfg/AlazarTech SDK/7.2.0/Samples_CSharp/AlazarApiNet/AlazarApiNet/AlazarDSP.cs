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

// -------------------------------------------------------------------------
// Title:   AlazarDSP.cs
// Version: 7.1.5
// --------------------------------------------------------------------------

using System;
using System.Runtime.InteropServices;

namespace AlazarTech
{
    public partial class AlazarAPI
    {
        #region - Constants -------------------------------------------------
        public enum DSP_WINDOW_ITEMS
        {
            DSP_WINDOW_NONE = 0,
            DSP_WINDOW_HANNING,
            DSP_WINDOW_HAMMING,
            DSP_WINDOW_BLACKMAN,
            DSP_WINDOW_BLACKMAN_HARRIS,
            DSP_WINDOW_BARTLETT,
            NUM_DSP_WINDOW_ITEMS
        }

        public enum DSP_MODULE_TYPE
        {
            DSP_MODULE_NONE = 0xFFFF, // avoids confusion with internal register.
            DSP_MODULE_FFT,
            DSP_MODULE_PCD
        }

        public enum DSP_PARAMETERS
        {
            DSP_RAW_PLUS_FFT_SUPPORTED = 0,
            DSP_FFT_SUBTRACTOR_SUPPORTED
        }

        public enum FFT_OUTPUT_FORMAT
        {
            FFT_OUTPUT_FORMAT_U32 = 0x0,            // 32-bit unsigned integer amplitude squared
            FFT_OUTPUT_FORMAT_U16_LOG = 0x1,        // 16-bit unsigned integer logarithmic amplitude
            FFT_OUTPUT_FORMAT_U16_AMP2 = 0x101,     // 8-bit unsigned integer amplitude squared
            FFT_OUTPUT_FORMAT_U8_LOG = 0x2,         // 8-bit unsigned integer logarithmic amplitude
            FFT_OUTPUT_FORMAT_U8_AMP2 = 0x102,      // 8-bit unsigned integer amplitude squared
            FFT_OUTPUT_FORMAT_REAL_S32 = 0x3,       // 32-bit signed integer real part of FFT
            FFT_OUTPUT_FORMAT_IMAG_S32 = 0x4,       // 32-bit signed integer imaginary part of FFT
            FFT_OUTPUT_FORMAT_FLOAT_AMP2 = 0xA,     // 32-bit floating point amplitude squared
            FFT_OUTPUT_FORMAT_FLOAT_LOG = 0xB,      // 32-bit floating point logarithmic
            FFT_OUTPUT_FORMAT_RAW_PLUS_FFT = 0x1000 // Prepend each FFT output record with a
                                                    // signed 16-bit version of the time-domain data
        }

        public enum FFT_FOOTER
        {
            FFT_FOOTER_NONE = 0x0,
            FFT_FOOTER_NPT = 0x1
        }
        #endregion

        #region - Functions -------------------------------------------------

        [DllImport("ATSApi.dll")]
        public static extern unsafe UInt32 AlazarDSPGetModules(IntPtr boardHandle,
                                                               UInt32 numEntries,
                                                               IntPtr *modules,
                                                               UInt32 *numModules);

        [DllImport("ATSApi.dll")]
        public static extern unsafe UInt32 AlazarDSPGetInfo(IntPtr dspHandle,
                                                            UInt32 *dspModuleId,
                                                            UInt16 *versionMajor,
                                                            UInt16 *versionMinor,
                                                            UInt32 *maxLength,
                                                            UInt32 *reserved0,
                                                            UInt32 *reserved1);

        [DllImport("ATSApi.dll")]
        public static extern unsafe UInt32 AlazarDSPGenerateWindowFunction(UInt32 windowType,
                                                                           Single *window,
                                                                           UInt32 windowLength_samples,
                                                                           UInt32 paddingLength_samples);

        [DllImport("ATSApi.dll")]
        public static extern unsafe UInt32 AlazarFFTGetMaxTriggerRepeatRate(IntPtr dspHandle,
                                                                            UInt32 fft_size,
                                                                            Double *maxTriggerRepeatRate);

        [DllImport("ATSApi.dll")]
        public static extern unsafe UInt32 AlazarFFTBackgroundSubtractionSetRecordS16(IntPtr dspHandle,
                                                                                      Int16  *record,
                                                                                      UInt32 size_samples);

        [DllImport("ATSApi.dll")]
        public static extern unsafe UInt32 AlazarFFTBackgroundSubtractionGetRecordS16(IntPtr dspHandle,
                                                                                      Int16  *backgroundRecord,
                                                                                      UInt32 size_samples);

        [DllImport("ATSApi.dll")]
        public static extern UInt32 AlazarFFTBackgroundSubtractionSetEnabled(IntPtr  dspHandle,
                                                                             Boolean enabled);

        [DllImport("ATSApi.dll")]
        public static extern unsafe UInt32 AlazarFFTSetWindowFunction(IntPtr dspHandle,
                                                                      UInt32 samplesPerRecord,
                                                                      Single *realWindowArray,
                                                                      Single *imagWindowArray);

        [DllImport("ATSApi.dll")]
        public static extern unsafe UInt32 AlazarFFTGetWindowFunction(IntPtr dspHandle,
                                                      U32 samplesPerRecord,
                                                      Single *realWindowArray,
                                                      Single *imagWindowArray);

        [DllImport("ATSApi.dll")]
        public static extern unsafe UInt32 AlazarFFTVerificationMode(IntPtr  dspHandle,
                                                                     Boolean enable,
                                                                     Int16   *realArray,
                                                                     Int16   *imagArray,
                                                                     UInt64  recordLength_samples);

        [DllImport("ATSApi.dll")]
        public static extern unsafe UInt32 AlazarFFTSetup(IntPtr dspHandle,
                                                          UInt16 inputChannelMask,
                                                          UInt32 recordLength_samples,
                                                          UInt32 fftLength_samples,
                                                          UInt32 outputFormat,
                                                          UInt32 footer,
                                                          UInt32 reserved,
                                                          UInt32 *bytesPerOutputRecord);

        [DllImport("ATSApi.dll")]
        public static extern UInt32 AlazarFFTSetScalingAndSlicing(IntPtr dspHandle,
                                                                  Byte   slice_pos,
                                                                  Single loge_ampl_mult);

        [DllImport("ATSApi.dll")]
        public static extern unsafe UInt32 AlazarDSPGetBuffer(IntPtr boardHandle,
                                                              void   *buffer,
                                                              UInt32 timeout_ms);

        [DllImport("ATSApi.dll")]
        public static extern unsafe UInt32 AlazarDSPGetNextBuffer(IntPtr boardHandle,
                                                                  void   *buffer,
                                                                  UInt32 bytesToCopy,
                                                                  UInt32 timeout_ms);

        [DllImport("ATSApi.dll")]
        public static extern unsafe UInt32 AlazarDSPGetParameterU32(IntPtr dspHandle,
                                                                    UInt32 parameter,
                                                                    UInt32 *result);

        [DllImport("ATSApi.dll")]
        public static extern unsafe UInt32 AlazarDSPGetParameterU32(IntPtr dspHandle,
                                                                    UInt32 parameter,
                                                                    UInt32 value);

        [DllImport("ATSApi.dll")]
        public static extern UInt32 AlazarDSPAbortCapture(IntPtr boardHandle);

        #endregion
    }
}
