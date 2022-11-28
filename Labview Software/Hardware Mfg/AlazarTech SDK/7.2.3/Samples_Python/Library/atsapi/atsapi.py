'''Python interface to the AlazarTech SDK.

This module provides a thin wrapper on top of the AlazarTech C
API. All the exported methods directly map to underlying C
functions. Please see the ATS-SDK Guide for detailed specification of
these functions. In addition, this module provides a few classes for
convenience.

Attributes:

  Board: Represents a digitizer. Provides methods for configuration
  and data acquisition

  DMABuffer: Holds a memory buffer suitable for data transfer with
  digitizers.
'''

from ctypes import *
import numpy as np
import os

from sys import version_info
if version_info.major == 2:
    import thread
elif version_info.major == 3:
    import _thread as thread

'''Types of clocks that a board can use for acquiring data.
Note: Available sources for a given board form a subset of this
class' members. Please see your board's specification as well as
the ATS-SDK manual for more information.
'''
INTERNAL_CLOCK = 0x1
EXTERNAL_CLOCK = 0x2
FAST_EXTERNAL_CLOCK = 0x2
MEDIUM_EXTERNAL_CLOCK = 0x3
SLOW_EXTERNAL_CLOCK = 0x4
EXTERNAL_CLOCK_AC = 0x5
EXTERNAL_CLOCK_DC = 0x6
EXTERNAL_CLOCK_10MHz_REF = 0x7
INTERNAL_CLOCK_10MHz_REF = 0x8
EXTERNAL_CLOCK_10MHz_PXI = 0xA
INTERNAL_CLOCK_DIV_4 = 0xF
INTERNAL_CLOCK_DIV_5 = 0x10
MASTER_CLOCK = 0x11
INTERNAL_CLOCK_SET_VCO = 0x12

'''Sample rates that the internal clock of a board can generate.

Note: Available sample rates for a given board form a subset of
this class' members. Please see your board's specification as well
as the ATS-SDK manual for more information.

'''
SAMPLE_RATE_1KSPS = 0x1
SAMPLE_RATE_2KSPS = 0x2
SAMPLE_RATE_5KSPS = 0x5
SAMPLE_RATE_10KSPS = 0x8
SAMPLE_RATE_20KSPS = 0xA
SAMPLE_RATE_50KSPS = 0xC
SAMPLE_RATE_100KSPS = 0xE
SAMPLE_RATE_200KSPS = 0x10
SAMPLE_RATE_500KSPS = 0x12
SAMPLE_RATE_1MSPS = 0x14
SAMPLE_RATE_2MSPS = 0x18
SAMPLE_RATE_5MSPS = 0x1A
SAMPLE_RATE_10MSPS = 0x1C
SAMPLE_RATE_20MSPS = 0x1E
SAMPLE_RATE_25MSPS = 0x21
SAMPLE_RATE_50MSPS = 0x22
SAMPLE_RATE_100MSPS = 0x24
SAMPLE_RATE_125MSPS = 0x25
SAMPLE_RATE_160MSPS = 0x26
SAMPLE_RATE_180MSPS = 0x27
SAMPLE_RATE_200MSPS = 0x28
SAMPLE_RATE_250MSPS = 0x2B
SAMPLE_RATE_400MSPS = 0x2D
SAMPLE_RATE_500MSPS = 0x30
SAMPLE_RATE_800MSPS = 0x32
SAMPLE_RATE_1000MSPS = 0x35
SAMPLE_RATE_1200MSPS = 0x37
SAMPLE_RATE_1500MSPS = 0x3A
SAMPLE_RATE_1600MSPS = 0x3B
SAMPLE_RATE_1800MSPS = 0x3D
SAMPLE_RATE_2000MSPS = 0x3F
SAMPLE_RATE_2400MSPS = 0x6A
SAMPLE_RATE_3000MSPS = 0x75
SAMPLE_RATE_3600MSPS = 0x7B
SAMPLE_RATE_4000MSPS = 0x80
SAMPLE_RATE_USER_DEF = 0x40

'''Direction of the edge from the external clock signal that the board
syncrhonises with.'''
CLOCK_EDGE_RISING = 0
CLOCK_EDGE_FALLING = 1

'''Board input channel identifiers

Note: The channels available for a given board form a subset of this
class' members. Please see your board's specification as well as
the ATS-SDK manual for more information.

'''
CHANNEL_A = 1
CHANNEL_B = 2
CHANNEL_C = 4
CHANNEL_D = 8
CHANNEL_E = 16
CHANNEL_F = 32
CHANNEL_G = 64
CHANNEL_H = 128
CHANNEL_I = 256
CHANNEL_J = 512
CHANNEL_K = 1024
CHANNEL_L = 2048
CHANNEL_M = 4096
CHANNEL_N = 8192
CHANNEL_O = 16384
CHANNEL_P = 32768

channels = [
    CHANNEL_A,
    CHANNEL_B,
    CHANNEL_C,
    CHANNEL_D,
    CHANNEL_E,
    CHANNEL_F,
    CHANNEL_G,
    CHANNEL_H,
    CHANNEL_I,
    CHANNEL_J,
    CHANNEL_K,
    CHANNEL_L,
    CHANNEL_M,
    CHANNEL_N,
    CHANNEL_O,
    CHANNEL_P
]

'''ADC modes'''
ADC_MODE_DEFAULT = 0
ADC_MODE_DES = 1

'''API trace states'''
API_ENABLE_TRACE = 1
API_DISABLE_TRACE = 0

'''AutoDMA acquisitions flags

Note: Not all AlazarTech devices are capable of dual-ported
acquisitions. Please see your board's specification for more
information.
'''
ADMA_TRADITIONAL_MODE = 0
ADMA_NPT = 0x200
ADMA_CONTINUOUS_MODE = 0x100
ADMA_TRIGGERED_STREAMING = 0x400
ADMA_EXTERNAL_STARTCAPTURE = 0x1
ADMA_ENABLE_RECORD_HEADERS = 0x8
ADMA_ALLOC_BUFFERS = 0x20
ADMA_FIFO_ONLY_STREAMING = 0x800
ADMA_INTERLEAVE_SAMPLES = 0x1000
ADMA_GET_PROCESSED_DATA = 0x2000
ADMA_DSP = 0x4000
ADMA_ENABLE_RECORD_FOOTERS = 0x10000

'''Aux input levels'''
AUX_INPUT_LOW = 0
AUX_INPUT_HIGH = 1

'''Boards'''
ATS850  = 1
ATS310  = 2
ATS330  = 3
ATS855  = 4
ATS315  = 5
ATS335  = 6
ATS460  = 7
ATS860  = 8
ATS660  = 9
ATS665  = 10
ATS9462 = 11
ATS9434 = 12
ATS9870 = 13
ATS9350 = 14
ATS9325 = 15
ATS9440 = 16
ATS9410 = 17
ATS9351 = 18
ATS9310 = 19
ATS9461 = 20
ATS9850 = 21
ATS9625 = 22
ATG6500 = 23
ATS9626 = 24
ATS9360 = 25
AXI9870 = 26
ATS9370 = 27
ATU7825 = 28
ATS9373 = 29
ATS9416 = 30

boardNames = {
    ATS850 : "ATS850" ,
    ATS310 : "ATS310" ,
    ATS330 : "ATS330" ,
    ATS855 : "ATS855" ,
    ATS315 : "ATS315" ,
    ATS335 : "ATS335" ,
    ATS460 : "ATS460" ,
    ATS860 : "ATS860" ,
    ATS660 : "ATS660" ,
    ATS665 : "ATS665" ,
    ATS9462: "ATS9462",
    ATS9434: "ATS9434",
    ATS9870: "ATS9870",
    ATS9350: "ATS9350",
    ATS9325: "ATS9325",
    ATS9440: "ATS9440",
    ATS9410: "ATS9410",
    ATS9351: "ATS9351",
    ATS9310: "ATS9310",
    ATS9461: "ATS9461",
    ATS9850: "ATS9850",
    ATS9625: "ATS9625",
    ATG6500: "ATG6500",
    ATS9626: "ATS9626",
    ATS9360: "ATS9360",
    AXI9870: "AXI9870",
    ATS9370: "ATS9370",
    ATU7825: "ATU7825",
    ATS9373: "ATS9373",
    ATS9416: "ATS9416"
};

'''Board options - low part'''
OPTION_STREAMING_DMA = (1 << 0)
OPTION_EXTERNAL_CLOCK = (1 << 1)
OPTION_DUAL_PORT_MEMORY = (1 << 2)
OPTION_180MHZ_OSCILLATOR = (1 << 3)
OPTION_LVTTL_EXT_CLOCK = (1 << 4)
OPTION_SW_SPI = (1 << 5)
OPTION_ALT_INPUT_RANGES = (1 << 6)
OPTION_VARIABLE_RATE_10MHZ_PLL = (1 << 7)
OPTION_MULTI_FREQ_VCO = (1 << 7)
OPTION_2GHZ_ADC = (1 << 8)
OPTION_DUAL_EDGE_SAMPLING = (1 << 9)
OPTION_DCLK_PHASE = (1 << 10)
OPTION_WIDEBAND = (1 << 11)

'''Board options - high part'''
OPTION_OEM_FPGA = (1 << 15)

'''Board input ranges (amplitudes) identifiers. PM stands for
plus/minus.

Note: Available input ranges for a given board _and_ a given
configuration form a subset of this class' members. Please see
your board's specification as well as the ATS-SDK manual for more
information.

'''
INPUT_RANGE_PM_20_MV = 0x1
INPUT_RANGE_PM_40_MV = 0x2
INPUT_RANGE_PM_50_MV = 0x3
INPUT_RANGE_PM_80_MV = 0x4
INPUT_RANGE_PM_100_MV = 0x5
INPUT_RANGE_PM_200_MV = 0x6
INPUT_RANGE_PM_400_MV = 0x7
INPUT_RANGE_PM_500_MV = 0x8
INPUT_RANGE_PM_800_MV = 0x9
INPUT_RANGE_PM_1_V = 0xA
INPUT_RANGE_PM_2_V = 0xB
INPUT_RANGE_PM_4_V = 0xC
INPUT_RANGE_PM_5_V = 0xD
INPUT_RANGE_PM_8_V = 0xE
INPUT_RANGE_PM_10_V = 0xF
INPUT_RANGE_PM_20_V = 0x10
INPUT_RANGE_PM_40_V = 0x11
INPUT_RANGE_PM_16_V = 0x12
INPUT_RANGE_HIFI = 0x20
INPUT_RANGE_PM_1_V_25 = 0x21
INPUT_RANGE_PM_2_V_5  = 0x25
INPUT_RANGE_PM_125_MV = 0x28
INPUT_RANGE_PM_250_MV = 0x30

'''Capabilities'''
GET_SERIAL_NUMBER = 0x10000024
GET_FIRST_CAL_DATE = 0x10000025
GET_LATEST_CAL_DATE = 0x10000026
GET_LATEST_TEST_DATE = 0x10000027
GET_LATEST_CAL_DATE_MONTH = 0x1000002D
GET_LATEST_CAL_DATE_DAY = 0x1000002E
GET_LATEST_CAL_DATE_YEAR = 0x1000002F
GET_BOARD_OPTIONS_LOW = 0x10000037
GET_BOARD_OPTIONS_HIGH = 0x10000038
MEMORY_SIZE = 0x1000002A
ASOPC_TYPE = 0x1000002C
BOARD_TYPE = 0x1000002B
GET_PCIE_LINK_SPEED = 0x10000030
GET_PCIE_LINK_WIDTH = 0x10000031
GET_MAX_PRETRIGGER_SAMPLES = 0x10000046
GET_CPF_DEVICE = 0x10000071
HAS_RECORD_FOOTERS_SUPPORT = 0x10000073

'''Coupling types identifiers for all boards input'''
AC_COUPLING = 1
DC_COUPLING = 2

'''ECC Modes'''
ECC_DISABLE = 0
ECC_ENABLE = 1

'''Master/Slave configuration'''
BOARD_IS_INDEPENDENT = 0x00000000
BOARD_IS_MASTER = 0x00000001
BOARD_IS_SLAVE = 0x00000002
BOARD_IS_LAST_SLAVE = 0x00000003

'''Trigger engine identifiers.'''
TRIG_ENGINE_J = 0
TRIG_ENGINE_K = 1

'''Trigger engine operation identifiers.'''
TRIG_ENGINE_OP_J = 0
TRIG_ENGINE_OP_K = 1
TRIG_ENGINE_OP_J_OR_K = 2
TRIG_ENGINE_OP_J_AND_K = 3
TRIG_ENGINE_OP_J_XOR_K = 4
TRIG_ENGINE_OP_J_AND_NOT_K = 5
TRIG_ENGINE_OP_NOT_J_AND_K = 6

'''Types of input that the board can trig on.'''
TRIG_CHAN_A = 0x0
TRIG_CHAN_B = 0x1
TRIG_EXTERNAL = 0x2
TRIG_DISABLE = 0x3
TRIG_CHAN_C = 0x4
TRIG_CHAN_D = 0x5
TRIG_CHAN_E = 0x6
TRIG_CHAN_F = 0x7
TRIG_CHAN_G = 0x8
TRIG_CHAN_H = 0x9
TRIG_CHAN_I = 0xA
TRIG_CHAN_J = 0xB
TRIG_CHAN_K = 0xC
TRIG_CHAN_L = 0xD
TRIG_CHAN_M = 0xE
TRIG_CHAN_N = 0xF
TRIG_CHAN_O = 0x10
TRIG_CHAN_P = 0x11
TRIG_PXI_STAR = 0x100

'''Edge of the external trigger signal that the board syncrhonises with.'''
TRIGGER_SLOPE_POSITIVE = 1
TRIGGER_SLOPE_NEGATIVE = 2

'''Impedance identifiers for the board inputs.

Note: Available parameters for a given board form a subset of this
class' members. Please see your board's specification as well as
the ATS-SDK manual for more information.

'''
IMPEDANCE_1M_OHM = 1
IMPEDANCE_50_OHM = 2
IMPEDANCE_75_OHM = 4
IMPEDANCE_300_OHM = 8

'''External trigger range identifiers.'''
ETR_5V = 0
ETR_1V = 1
ETR_TTL = 2
ETR_2V5 = 3

'''LED State'''
LED_OFF = 0
LED_ON = 1

'''LSB Values'''
LSB_DEFAULT = 0
LSB_EXT_TRIG = 1
LSB_AUX_IN_0 = 2 # deprecated
LSB_AUX_IN_1 = 3
LSB_AUX_IN_2 = 2

'''Operating modes for the auxiliary input/output port.'''
AUX_OUT_TRIGGER = 0
AUX_IN_TRIGGER_ENABLE = 1
AUX_OUT_PACER = 2
AUX_IN_AUXILIARY = 13
AUX_OUT_SERIAL_DATA = 14

'''Pack modes'''
PACK_DEFAULT = 0
PACK_8_BITS_PER_SAMPLE = 1
PACK_12_BITS_PER_SAMPLE = 2

'''Parameters for set/getParameter'''
SETGET_ASYNC_BUFFSIZE_BYTES = 0x10000039
SETGET_ASYNC_BUFFCOUNT = 0x10000040
GET_ASYNC_BUFFERS_PENDING = 0x10000050
GET_ASYNC_BUFFERS_PENDING_FULL = 0x10000051
GET_ASYNC_BUFFERS_PENDING_EMPTY = 0x10000052
SET_DATA_FORMAT = 0x10000041
GET_DATA_FORMAT = 0x10000042
GET_SAMPLES_PER_TIMESTAMP_CLOCK = 0x10000044
GET_RECORDS_CAPTURED = 0x10000045
ECC_MODE = 0x10000048
GET_AUX_INPUT_LEVEL = 0x10000049
GET_CHANNELS_PER_BOARD = 0x10000070
GET_FPGA_TEMPERATURE = 0x10000080
PACK_MODE = 0x10000072
SET_SINGLE_CHANNEL_MODE = 0x10000043
API_FLAGS = 0x10000090

'''Parameters for set/getParameterUL'''
SET_ADC_MODE = 0x10000047

'''Parameters that apply to some modes of the auxiliary input/output
port.'''
TRIGGER_SLOPE_POSITIVE = 1
TRIGGER_SLOPE_NEGATIVE = 2

'''Record average options'''
CRA_MODE_DISABLE = 0
CRA_MODE_ENABLE_FPGA_AVE = 1
CRA_OPTION_UNSIGNED = 0
CRA_OPTION_SIGNED = 1

'''Reset timestamp'''
TIMESTAMP_RESET_FIRSTTIME_ONLY = 0
TIMESTAMP_RESET_ALWAYS = 1

'''Sleep State'''
POWER_OFF = 0
POWER_ON = 1

'''DSP Window Items'''
DSP_WINDOW_NONE = 0
DSP_WINDOW_HANNING = 1
DSP_WINDOW_HAMMING = 2
DSP_WINDOW_BLACKMAN = 3
DSP_WINDOW_BLACKMAN_HARRIS = 4
DSP_WINDOW_BARTLETT = 5

'''DSP Module Type'''
DSP_MODULE_NONE = 0xFFFF
DSP_MODULE_FFT = 0x10000
DSP_MODULE_PCD = 0x10001

'''FFT Output Format'''
FFT_OUTPUT_FORMAT_U32 = 0x0
FFT_OUTPUT_FORMAT_U16_LOG = 0x1
FFT_OUTPUT_FORMAT_U16_AMP2 = 0x101
FFT_OUTPUT_FORMAT_U8_LOG = 0x2
FFT_OUTPUT_FORMAT_U8_AMP2 = 0x102
FFT_OUTPUT_FORMAT_REAL_S32 = 0x3
FFT_OUTPUT_FORMAT_IMAG_S32 = 0x4
FFT_OUTPUT_FORMAT_FLOAT_AMP2 = 0xA
FFT_OUTPUT_FORMAT_FLOAT_LOG = 0xB
FFT_OUTPUT_FORMAT_RAW_PLUS_FFT = 0x1000

'''FFT Footer'''
FFT_FOOTER_NONE = 0x0
FFT_FOOTER_NPT = 0x1

'''DSP Parameters'''
DSP_RAW_PLUS_FFT_SUPPORTED = 0
DSP_FFT_SUBTRACTOR_SUPPORTED = 1

def enter_pressed():
    try:
        from msvcrt import getch
        from msvcrt import kbhit
        while kbhit():
            c = getch()
            if c == b'\n' or c == b'\r':
                return True
        return False
    except ImportError:
        import sys, select
        if sys.stdin in select.select([sys.stdin], [], [], 0)[0]:
            return True
        return False

class NPTFooter(Structure):
    _fields_ = [("trigger_timestamp", c_uint64),
                ("record_number", c_uint32),
                ("frame_count", c_uint32),
                ("aux_in_state", c_uint32)]


# Load libraries
ats = None
if os.name == 'nt':
    ats = CDLL("ATSApi.dll")
elif os.name == 'posix':
    ats = CDLL("libATSApi.so")
else:
    raise Exception("Unsupported OS")

handle_t = c_void_p

ats.AlazarErrorToText.restype = c_char_p
ats.AlazarErrorToText.argtypes = [c_uint32]
def returnCodeCheck(result, func, arguments):
    '''Function used internally to check the return code of the C ATS-SDK
    functions.'''
    if (result != 512):
        raise Exception("Error calling function %s with arguments %s : %s" %
                        (func.__name__,
                         str(arguments),
                         str(ats.AlazarErrorToText(result))))


ats.AlazarAllocBufferU16.restype = c_void_p
ats.AlazarAllocBufferU16.argtypes = [c_void_p, c_uint32]
ats.AlazarAllocBufferU8.restype = c_void_p
ats.AlazarAllocBufferU8.argtypes = [c_void_p, c_uint32]
ats.AlazarFreeBufferU8.argtypes = [c_void_p, c_void_p]
ats.AlazarFreeBufferU8.errcheck = returnCodeCheck
ats.AlazarFreeBufferU16.argtypes = [c_void_p, c_void_p]
ats.AlazarFreeBufferU16.errcheck = returnCodeCheck

class DMABuffer:
    '''Buffer suitable for DMA transfers.

    AlazarTech digitizers use direct memory access (DMA) to transfer
    data from digitizers to the computer's main memory. This class
    abstracts a memory buffer on the host, and ensures that all the
    requirements for DMA transfers are met.

    DMABuffers export a 'buffer' member, which is a NumPy array view
    of the underlying memory buffer

    Args:

      c_sample_type (ctypes type): The datatype of the buffer to create.

      size_bytes (int): The size of the buffer to allocate, in bytes.

    '''

    def __init__(self, handle, c_sample_type, size_bytes):
        self.size_bytes = size_bytes
        self.c_sample_type = c_sample_type
        self.handle = handle
        npSampleType = {
            c_uint8: np.uint8,
            c_uint16: np.uint16,
            c_uint32: np.uint32,
            c_int32: np.int32,
            c_float: np.float32
        }.get(c_sample_type, 0)

        bytes_per_sample = {
            c_uint8:  1,
            c_uint16: 2,
            c_uint32: 4,
            c_int32:  4,
            c_float:  4
        }.get(c_sample_type, 0)

        self.addr = None
        if c_sample_type == c_uint8:
            self.addr = ats.AlazarAllocBufferU8(handle, size_bytes)
        elif c_sample_type == c_uint16:
            self.addr = ats.AlazarAllocBufferU16(handle, size_bytes)
        else:
            raise ValueError("Invalid DMABuffer Type")

        if self.addr is None:
            raise ValueError("DMABuffer: Address NULL")

        ctypes_array = (c_sample_type *
                        (size_bytes // bytes_per_sample)).from_address(self.addr)
        self.buffer = np.frombuffer(ctypes_array, dtype=npSampleType)
        self.ctypes_buffer = ctypes_array

    def __del__(self):
        if self.c_sample_type == c_uint8:
            ats.AlazarFreeBufferU8(self.handle, self.addr)
        elif self.c_sample_type == c_uint16:
            ats.AlazarFreeBufferU16(self.handle, self.addr)

def numOfSystems():
    ats.AlazarNumOfSystems.restype = c_uint32
    ats.AlazarNumOfSystems.argtypes = []
    return ats.AlazarNumOfSystems()

ats.AlazarBoardsFound.restype = c_uint32
ats.AlazarBoardsFound.argtypes = []
def boardsFound():
    return ats.AlazarBoardsFound()

def boardsInSystemBySystemID(sid):
    ats.AlazarBoardsInSystemBySystemID.restype = c_uint32
    ats.AlazarBoardsInSystemBySystemID.argtypes = [c_uint32]
    return ats.AlazarBoardsInSystemBySystemID(sid)

ats.AlazarDSPGenerateWindowFunction.restype = c_uint32
ats.AlazarDSPGenerateWindowFunction.argtypes = [c_uint32, POINTER(c_float), c_uint32, c_uint32]
def dspGenerateWindowFunction(windowType,
                              windowLength_samples,
                              paddingLength_samples):
    '''
    Fills an array with a generated window function and pads it with zeros
    '''
    window = np.zeros(windowLength_samples+paddingLength_samples, dtype=np.float32)
    ats.AlazarDSPGenerateWindowFunction(windowType,
                                        window.ctypes.data_as(POINTER(c_float)),
                                        windowLength_samples,
                                        paddingLength_samples)
    return window

ats.AlazarExtractFFTNPTFooters.restype = c_uint32
ats.AlazarExtractFFTNPTFooters.argtypes = [c_void_p,
                                           c_uint32,
                                           c_uint32,
                                           POINTER(NPTFooter),
                                           c_uint32]
ats.AlazarExtractFFTNPTFooters.errcheck = returnCodeCheck
def extractFFTNPTFooters(buffer,
                         recordSize_bytes,
                         bufferSize_bytes,
                         footersArray,
                         numFootersToExtract):
    ats.AlazarExtractFFTNPTFooters(buffer,
                                   recordSize_bytes,
                                   bufferSize_bytes,
                                   footersArray,
                                   numFootersToExtract)

ats.AlazarExtractTimeDomainNPTFooters.restype = c_uint32
ats.AlazarExtractTimeDomainNPTFooters.argtypes = [c_void_p,
                                                  c_uint32,
                                                  c_uint32,
                                                  POINTER(NPTFooter),
                                                  c_uint32]
ats.AlazarExtractTimeDomainNPTFooters.errcheck = returnCodeCheck
def extractTimeDomainNPTFooters(buffer,
                                recordSize_bytes,
                                bufferSize_bytes,
                                footersArray,
                                numFootersToExtract):
    ats.AlazarExtractTimeDomainNPTFooters(buffer,
                                          recordSize_bytes,
                                          bufferSize_bytes,
                                          footersArray,
                                          numFootersToExtract)

ats.AlazarGetSDKVersion.restype = c_uint32
ats.AlazarGetSDKVersion.argtypes = [POINTER(c_byte), POINTER(c_byte), POINTER(c_byte)]
ats.AlazarGetSDKVersion.errcheck = returnCodeCheck
def getSDKVersion():
    '''Get the ATSAPI library version'''
    major = c_byte(0)
    minor = c_byte(0)
    revision = c_byte(0)
    ats.AlazarGetSDKVersion(byref(major), byref(minor), byref(revision))
    return (major, minor, revision)

ats.AlazarGetDriverVersion.restype = c_uint32
ats.AlazarGetDriverVersion.argtypes = [POINTER(c_byte), POINTER(c_byte), POINTER(c_byte)]
ats.AlazarGetDriverVersion.errcheck = returnCodeCheck
def getDriverVersion():
    '''Get the device driver version of the most recently opened device'''
    major = c_byte(0)
    minor = c_byte(0)
    revision = c_byte(0)
    ats.AlazarGetDriverVersion(byref(major), byref(minor), byref(revision))
    return (major, minor, revision)

class DspModule:
    def __init__(self, dspHandle):
        self.handle = dspHandle

    ats.AlazarDSPGetInfo.restype = c_uint32
    ats.AlazarDSPGetInfo.argtypes = [handle_t, c_void_p, c_void_p, c_void_p,
                                     c_void_p, c_void_p, c_void_p]
    ats.AlazarDSPGetInfo.errcheck = returnCodeCheck
    def dspGetInfo(self):
        '''Get informations related to the DSP module:
         - Identifier
         - Major version number
         - Minor version number
         - Max length
        '''
        id = c_uint32(0)
        major = c_uint16(0)
        minor = c_uint16(0)
        maxLength = c_uint32(0)

        ats.AlazarDSPGetInfo(self.handle, byref(id), byref(major),
                             byref(minor), byref(maxLength), 0, 0)
        return (id.value, major.value, minor.value, maxLength.value)

    ats.AlazarFFTGetMaxTriggerRepeatRate.restype = c_uint32
    ats.AlazarFFTGetMaxTriggerRepeatRate.argtypes = [handle_t, c_uint32, POINTER(c_double)]
    ats.AlazarFFTGetMaxTriggerRepeatRate.errcheck = returnCodeCheck
    def fftGetMaxTriggerRepeatRate(self, fftSize):
        rate = c_double(0)
        ats.AlazarFFTGetMaxTriggerRepeatRate(self.handle, fftSize, rate)
        return rate

    ats.AlazarFFTSetWindowFunction.restype = c_uint32
    ats.AlazarFFTSetWindowFunction.argtypes = [handle_t, c_uint32, POINTER(c_float), POINTER(c_float)]
    ats.AlazarFFTSetWindowFunction.errcheck = returnCodeCheck
    def fftSetWindowFunction(self, samplesPerRecord, realWindowArray,
                             imagWindowArray):
        ats.AlazarFFTSetWindowFunction(self.handle, samplesPerRecord,
                                       realWindowArray, imagWindowArray)

    ats.AlazarFFTSetup.restype = c_uint32
    ats.AlazarFFTSetup.argtypes = [handle_t, c_uint16, c_uint32, c_uint32, c_uint32, c_uint32, c_uint32, POINTER(c_uint32)]
    ats.AlazarFFTSetup.errcheck = returnCodeCheck
    def fftSetup(self, inputChannelMask, recordLength_samples,
                 fftLength_samples, outputFormat, footer, reserved):
        '''
        Configures the on-FPGA FFT, and returns the size of each record
        output from the FFT module in bytes.
        '''
        bytesPerOutRecord = c_uint32(0)
        ats.AlazarFFTSetup(self.handle,
                           inputChannelMask,
                           recordLength_samples,
                           fftLength_samples,
                           outputFormat,
                           footer,
                           reserved,
                           byref(bytesPerOutRecord))
        return bytesPerOutRecord.value

    ats.AlazarFFTVerificationMode.restype = c_uint32
    ats.AlazarFFTVerificationMode.argtypes = [handle_t, c_uint32,
                                              POINTER(c_int16),
                                              POINTER(c_int16), c_size_t]
    ats.AlazarFFTVerificationMode.errcheck = returnCodeCheck
    def fftVerificationMode(self, enable, realArray, imagArray, recordLength):
        ats.AlazarFFTVerificationMode(self.handle,
                                      1 if enable else 0,
                                      realArray.ctypes.data_as(POINTER(c_int16)),
                                      imagArray.ctypes.data_as(POINTER(c_int16)),
                                      recordLength)


    ats.AlazarFFTSetScalingAndSlicing.restype = c_uint32
    ats.AlazarFFTSetScalingAndSlicing.argtypes = [handle_t, c_uint8, c_float]
    ats.AlazarFFTSetScalingAndSlicing.errcheck = returnCodeCheck
    def fftSetScalingAndSlicing(self, u52_slice_pos, loge_ampl_mult):
        '''
        Configure the scaling and slicing parameters of the on-FPGA FFT.
        '''
        ats.AlazarFFTSetScalingAndSlicing(self.handle,
                                          u52_slice_pos,
                                          loge_ampl_mult)

    ats.AlazarDSPOutputSnoopConfig.restype = c_uint32
    ats.AlazarDSPOutputSnoopConfig.argtypes = [handle_t, c_uint32, c_uint32, c_uint32]
    ats.AlazarDSPOutputSnoopConfig.errcheck = returnCodeCheck
    def dspOutputSnoopConfig(self, wraparound, oneShot, freeze):
        ats.AlazarDSPOutputSnoopConfig(self.handle,
                                       1 if wraparound else 0,
                                       1 if oneShot else 0,
                                       1 if freeze else 0)

    ats.AlazarDSPOutputSnoopStatus.restype = c_uint32
    ats.AlazarDSPOutputSnoopStatus.argtypes = [handle_t, c_void_p, c_void_p, c_void_p]
    ats.AlazarDSPOutputSnoopStatus.errcheck = returnCodeCheck
    def dspOutputSnoopStatus(self):
        outFrozen = c_uint32(0)
        outMaxRecSize_u32 = c_uint32(0)
        outLastRecSize_u32 = c_uint32(0)
        ats.AlazarDSPOutputSnoopStatus(self.handle,
                                       byref(outFrozen),
                                       byref(outMaxRecSize_u32),
                                       byref(outLastRecSize_u32))
        return (True if outFrozen else False,
                outMaxRecSize_u32,
                outLastRecSize_u32)

    restype = c_uint32
    argtypes = [handle_t, c_uint32, c_void_p, c_uint32, c_void_p]
    errcheck = returnCodeCheck
    def dspOutputSnoopRead(self, bytesPerSample,
                           outputArray, outputArraySize_samples):
        writtenSamples = c_uint32(0)
        ats.AlazarDSPOutputSnoopRead(self.handle, bytesPerSample,
                                     outputArray, outputArraySize_samples,
                                     byref(writtenSamples))
        return writtenSamples.value

    ats.AlazarDISSetup.restype = c_uint32
    ats.AlazarDISSetup.argtypes = [handle_t, c_uint32, c_uint16, POINTER(c_float), POINTER(c_int32), POINTER(c_int32)]
    ats.AlazarDISSetup.errcheck = returnCodeCheck
    def disSetup(self, options, inputChannelMask, gainArray, offsetArray, saturationArray):
        ''' Configures the on-FPGA deinterlacer and rescaling functionality. '''
        disGain = np.array(gainArray, dtype=np.float32)
        disOffset = np.array(offsetArray, dtype=np.int32)
        disSaturation = np.array(saturationArray, dtype=np.int32)
        ats.AlazarDISSetup(self.handle, options, inputChannelMask,
                           disGain.ctypes.data_as(POINTER(c_float)) if len(disGain) else POINTER(c_float)(),
                           disOffset.ctypes.data_as(POINTER(c_int32)) if len(disOffset) else POINTER(c_int32)(),
                           disSaturation.ctypes.data_as(POINTER(c_int32)) if len(disSaturation) else POINTER(c_int32)())

    ats.AlazarDSPGetParameterU32.restype = c_uint32
    ats.AlazarDSPGetParameterU32.argtypes = [handle_t, c_uint32, c_void_p]
    ats.AlazarDSPGetParameterU32.errcheck = returnCodeCheck
    def dspGetParameterU32(self, parameter):
        ''' Generic interface to retrieve U32-typed parameters '''
        result = c_uint32(0)
        ats.AlazarDSPGetParameterU32(self.handle, parameter, byref(result))
        return result.value

    ats.AlazarFFTBackgroundSubtractionSetEnabled.restype = c_uint32
    ats.AlazarFFTBackgroundSubtractionSetEnabled.argtypes = [handle_t, c_uint32]
    ats.AlazarFFTBackgroundSubtractionSetEnabled.errcheck = returnCodeCheck
    def fftBackgroundSubtractionSetEnabled(self, enabled):
        ''' Controls the activation of the background subtraction feature '''
        ats.AlazarFFTBackgroundSubtractionSetEnabled(self.handle, 1 if enabled else 0)

    ats.AlazarFFTBackgroundSubtractionGetRecordS16.restype = c_uint32
    ats.AlazarFFTBackgroundSubtractionGetRecordS16.argtypes = [handle_t, POINTER(c_int16), c_uint32]
    ats.AlazarFFTBackgroundSubtractionGetRecordS16.errcheck = returnCodeCheck
    def fftBackgroundSubtractionGetRecordS16(self, backgroundRecord, size_samples):
        ''' Reads the background subtraction record from a board '''
        ats.AlazarFFTBackgroundSubtractionGetRecordS16(self.handle, backgroundRecord, size_samples)

    ats.AlazarFFTBackgroundSubtractionSetRecordS16.restype = c_uint32
    ats.AlazarFFTBackgroundSubtractionSetRecordS16.argtypes = [handle_t, POINTER(c_int16), c_uint32]
    ats.AlazarFFTBackgroundSubtractionSetRecordS16.errcheck = returnCodeCheck
    def fftBackgroundSubtractionSetRecordS16(self, record, size_samples):
        ''' Download the record for the background subration feature to a board '''
        ats.AlazarFFTBackgroundSubtractionSetRecordS16(self.handle, record, size_samples)


class Board:
    '''Interface to an AlazarTech digitizer.

    The Board class represents an acquisition device on the local
    system. It can be used to control configuration parameters, to
    start acquisitions and to retrieve the acquired data.

    Args:

      systemId (int): The board system identifier of the target
      board. Defaults to 1, which is suitable when there is only one
      board in the system.

      boardId (int): The target's board identifier in it's
      system. Defaults to 1, which is suitable when there is only one
      board in the system.

    '''
    def __init__(self, systemId=1, boardId=1):
        ats.AlazarGetBoardBySystemID.restype = handle_t
        ats.AlazarGetBoardBySystemID.argtypes = [c_uint32, c_uint32]
        self.systemId = systemId
        self.boardId = boardId
        self.handle = ats.AlazarGetBoardBySystemID(systemId, boardId)
        if self.handle == 0:
            raise Exception("Board %d.%d not found" % (systemId, boardId))

    ats.AlazarAbortAsyncRead.restype = c_uint32
    ats.AlazarAbortAsyncRead.argtypes = [handle_t]
    ats.AlazarAbortAsyncRead.errcheck = returnCodeCheck
    def abortAsyncRead(self):
        '''Cancels any asynchronous acquisition running on a board.'''
        ats.AlazarAbortAsyncRead(self.handle)

    ats.AlazarAbortCapture.restype = c_uint32
    ats.AlazarAbortCapture.argtypes = [handle_t]
    ats.AlazarAbortCapture.errcheck = returnCodeCheck
    def abortCapture(self):
        '''Abort an acquisition to on-board memory.'''
        ats.AlazarAbortCapture(self.handle)

    ats.AlazarBeforeAsyncRead.restype = c_uint32
    ats.AlazarBeforeAsyncRead.argtypes = [handle_t, c_uint32, c_long, c_uint32, c_uint32, c_uint32, c_uint32]
    ats.AlazarBeforeAsyncRead.errcheck = returnCodeCheck
    def beforeAsyncRead(self, channels, transferOffset, samplesPerRecord,
                        recordsPerBuffer, recordsPerAcquisition, flags):
        '''Prepares the board for an asynchronous acquisition.'''
        ats.AlazarBeforeAsyncRead(self.handle, channels, transferOffset, samplesPerRecord,
                                  recordsPerBuffer, recordsPerAcquisition, flags)

    ats.AlazarBusy.restype = c_uint32
    ats.AlazarBusy.argtypes = [handle_t]
    def busy(self):
        '''Determine if an acquisition to on-board memory is in progress.'''
        return True if (ats.AlazarBusy(self.handle) > 0) else False

    ats.AlazarConfigureAuxIO.restype = c_uint32
    ats.AlazarConfigureAuxIO.argtypes = [handle_t, c_uint32, c_uint32]
    ats.AlazarConfigureAuxIO.errcheck = returnCodeCheck
    def configureAuxIO(self, mode, parameter):
        '''Configures the auxiliary output.'''
        ats.AlazarConfigureAuxIO(self.handle, mode, parameter)

    ats.AlazarConfigureLSB.restype = c_uint32
    ats.AlazarConfigureLSB.argtypes = [handle_t, c_uint32, c_uint32]
    ats.AlazarConfigureLSB.errcheck = returnCodeCheck
    def configureLSB(self, valueLSB0, valueLSB1):
        '''Change unused bits to digital outputs.'''
        ats.AlazarConfigureLSB(self.handle, valueLSB0, valueLSB1)

    ats.AlazarConfigureSampleSkipping.restype = c_uint32
    ats.AlazarConfigureSampleSkipping.argtypes = [handle_t, c_uint32, c_uint32, POINTER(c_uint16)]
    ats.AlazarConfigureSampleSkipping.errcheck = returnCodeCheck
    def configureSampleSkipping(self, mode, sampleClocksPerRecord,
                                sampleSkipMap):
        ats.AlazarConfigureSampleSkipping(self.handle, mode,
                                          sampleClocksPerRecord, sampleSkipMap)

    ats.AlazarConfigureRecordAverage.restype = c_uint32
    ats.AlazarConfigureRecordAverage.argtypes = [handle_t, c_uint32, c_uint32, c_uint32, c_uint32]
    ats.AlazarConfigureRecordAverage.errcheck = returnCodeCheck
    def configureRecordAverage(self, mode, samplesPerRecord, recordsPerAverage, options):
        '''Co-add ADC samples into accumulator record.'''
        ats.AlazarConfigureRecordAverage(self.handle, mode, samplesPerRecord,
                                         recordsPerAverage, options)

    ats.AlazarCoprocessorDownloadA.restype = c_uint32
    ats.AlazarCoprocessorDownloadA.argtypes = [handle_t, POINTER(c_char), c_uint32]
    ats.AlazarCoprocessorDownloadA.errcheck = returnCodeCheck
    def coprocessorDownloadA(self, fileName, options):
        ats.AlazarCoprocessorDownloadA(self.handle, fileName, options)

    ats.AlazarCoprocessorRegisterRead.restype = c_uint32
    ats.AlazarCoprocessorRegisterRead.argtypes = [handle_t, c_uint32, POINTER(c_uint32)]
    ats.AlazarCoprocessorRegisterRead.errcheck = returnCodeCheck
    def coprocessorRegisterRead(self, offset):
        value = c_uint32(0)
        ats.AlazarCoprocessorRegisterRead(self.handle, offset, byref(value))
        return value

    ats.AlazarCoprocessorRegisterWrite.restype = c_uint32
    ats.AlazarCoprocessorRegisterWrite.argtypes = [handle_t, c_uint32, c_uint32]
    ats.AlazarCoprocessorRegisterWrite.errcheck = returnCodeCheck
    def coprocessorRegisterWrite(self, offset, value):
        ats.AlazarCoprocessorRegisterWrite(self.handle, offset, value)

    ats.AlazarDSPAbortCapture.restype = c_uint32
    ats.AlazarDSPAbortCapture.argtypes = [handle_t]
    ats.AlazarDSPAbortCapture.errcheck = returnCodeCheck
    def dspAbortCapture(self):
        '''
        Aborts any in-progress DMA transfer, cancels any pending
        transfers and does DSP-related cleanup
        '''
        ats.AlazarDSPAbortCapture(self.handle)

    ats.AlazarDSPGetBuffer.restype = c_uint32
    ats.AlazarDSPGetBuffer.argtypes = [handle_t, c_void_p, c_uint32]
    ats.AlazarDSPGetBuffer.errcheck = returnCodeCheck
    def dspGetBuffer(self, buffer, timeout_ms):
        ''' Waits until a buffer becomes available or an error occurs '''
        ats.AlazarDSPGetBuffer(self.handle, buffer, timeout_ms)

    ats.AlazarDSPGetNextBuffer.restype = c_uint32
    ats.AlazarDSPGetNextBuffer.argtypes = [handle_t, c_void_p, c_uint32, c_uint32]
    ats.AlazarDSPGetNextBuffer.errcheck = returnCodeCheck
    def dspGetNextBuffer(self, buffer, bytesToCopy, timeout_ms):
        ''' Equivalent of AlazarDSPGetBuffer() to call with ADMA_ALLOC_BUFFERS '''
        ats.AlazarDSPGetNextBuffer(self.handle, buffer, bytesToCopy, timeout_ms)

    ats.AlazarDSPGetModules.restype = c_uint32
    ats.AlazarDSPGetModules.argtypes = [handle_t, c_uint32, POINTER(handle_t), c_void_p]
    ats.AlazarDSPGetModules.errcheck = returnCodeCheck
    def dspGetModules(self):
        '''Returns a list of DSP modules for this board'''
        numModules = c_uint32(0)
        ats.AlazarDSPGetModules(self.handle, 0, handle_t(0), byref(numModules))
        moduleHandlesArrayType = handle_t * numModules.value
        moduleHandlesArray = moduleHandlesArrayType()
        ats.AlazarDSPGetModules(self.handle,
                                numModules,
                                moduleHandlesArray,
                                c_void_p(0))
        modulesArray = []
        for i in moduleHandlesArray:
            modulesArray.append(DspModule(i))
        return modulesArray

    ats.AlazarGetParameter.restype = c_uint32
    ats.AlazarGetParameter.argtypes = [handle_t, c_byte, c_uint32, POINTER(c_long)]
    ats.AlazarGetParameter.errcheck = returnCodeCheck
    def getParameter(self, channel, parameter):
        '''Get a device parameter as a signed long value'''
        retval = c_long(0)
        ats.AlazarGetParameter(self.handle, channel, parameter, byref(retval))
        return retval

    ats.AlazarGetParameterUL.restype = c_uint32
    ats.AlazarGetParameterUL.argtypes = [handle_t, c_byte, c_uint32, POINTER(c_uint32)]
    ats.AlazarGetParameterUL.errcheck = returnCodeCheck
    def getParameterUL(self, channel, parameter):
        '''Get a device parameter as an unsigned long value'''
        retval = c_uint32(0)
        ats.AlazarGetParameterUL(self.handle, channel, parameter, byref(retval))
        return retval

    ats.AlazarForceTrigger.restype = c_uint32
    ats.AlazarForceTrigger.argtypes = [handle_t]
    ats.AlazarForceTrigger.errcheck = returnCodeCheck
    def forceTrigger(self):
        '''Generate a software trigger event.'''
        ats.AlazarForceTrigger(self.handle)

    ats.AlazarForceTriggerEnable.restype = c_uint32
    ats.AlazarForceTriggerEnable.argtypes = [handle_t]
    ats.AlazarForceTriggerEnable.errcheck = returnCodeCheck
    def forceTriggerEnable(self):
        '''Generate a software trigger enable event.'''
        ats.AlazarForceTriggerEnable(self.handle)

    ats.AlazarGetBoardKind.restype = c_uint32
    ats.AlazarGetBoardKind.argtypes = [handle_t]
    def getBoardKind(self):
        '''Get a board model identifier.'''
        return ats.AlazarGetBoardKind(self.handle)

    ats.AlazarGetBoardRevision.restype = c_uint32
    ats.AlazarGetBoardRevision.argtypes = [handle_t, POINTER(c_byte), POINTER(c_byte)]
    ats.AlazarGetBoardRevision.errcheck = returnCodeCheck
    def getBoardRevision(self):
        '''Get the PCB hardware revision level of a board.'''
        major = c_byte(0)
        minor = c_byte(0)
        ats.AlazarGetBoardRevision(self.handle, byref(major), byref(minor))
        return (major, minor)

    ats.AlazarGetChannelInfo.restype = c_uint32
    ats.AlazarGetChannelInfo.argtypes = [handle_t, c_void_p, c_void_p]
    def getChannelInfo(self):
        '''Get the on-board memory in samples per channe and sample size in bits per sample'''
        memorySize_samples = c_uint32(0)
        bitsPerSample = c_uint8(0)
        ats.AlazarGetChannelInfo(self.handle, byref(memorySize_samples), byref(bitsPerSample))
        return (memorySize_samples, bitsPerSample)

    ats.AlazarGetCPLDVersion.restype = c_uint32
    ats.AlazarGetCPLDVersion.argtypes = [handle_t, POINTER(c_byte), POINTER(c_byte)]
    ats.AlazarGetCPLDVersion.errcheck = returnCodeCheck
    def getCPLDVersion(self):
        major = c_byte(0)
        minor = c_byte(0)
        ats.AlazarGetCPLDVersion(self.handle, byref(major), byref(minor))
        return (major, minor)

    ats.AlazarGetMaxRecordsCapable.restype = c_uint32
    ats.AlazarGetMaxRecordsCapable.argtypes = [handle_t, c_uint32, POINTER(c_uint32)]
    ats.AlazarGetMaxRecordsCapable.errcheck = returnCodeCheck
    def getMaxRecordsCapable(self, samplesPerRecord):
        retval = c_uint32(0)
        ats.AlazarGetMaxRecordsCapable(self.handle, samplesPerRecord, byref(retval))
        return retval

    ats.AlazarGetStatus.restype = c_uint32
    ats.AlazarGetStatus.argtypes = [c_uint32]
    def getStatus(self):
        return ats.AlazarGetStatus(self.handle)

    ats.AlazarGetTriggerAddress.restype = c_uint32
    ats.AlazarGetTriggerAddress.argtypes = [handle_t, c_uint32, POINTER(c_uint32), POINTER(c_uint32), POINTER(c_uint32)]
    ats.AlazarGetTriggerAddress.errcheck = returnCodeCheck
    def getTriggerAddress(self, record):
        address = c_uint32(0)
        timestamp_high = c_uint32(0)
        timestamp_low = c_uint32(0)
        ats.AlazarGetTriggerAddress(self.handle, record, byref(address),
                                    byref(timestamp_high), byref(timestamp_low))
        return (address, timestamp_high, timestamp_low)

    ats.AlazarGetTriggerTimestamp.restype = c_uint32
    ats.AlazarGetTriggerTimestamp.argtypes = [handle_t, c_uint32, POINTER(c_uint64)]
    ats.AlazarGetTriggerTimestamp.errcheck = returnCodeCheck
    def getTriggerTimestamp(self, record):
        timestamp = c_uint64(0)
        ats.AlazarGetTriggerTimestamp(self.handle, record, timestamp)
        return timestamp

    ats.AlazarHyperDisp.retype = c_uint32
    ats.AlazarHyperDisp.argtypes = [handle_t, c_void_p, c_uint32, POINTER(c_byte), c_uint32,
                                    c_uint32, c_uint32, c_uint32, c_uint32, c_long, POINTER(c_uint32)]
    ats.AlazarHyperDisp.errcheck = returnCodeCheck
    def hyperDisp(self, buffer, bufferSize, viewBuffer, viewBufferSize,
                  numOfPixels, option, channelSelect, record, transferOffset):
        error = c_uint32(0)
        ats.AlazarHyperDisp(self.handle, buffer, bufferSize, viewBuffer,
                            viewBufferSize, numOfPixels, option, channelSelect,
                            record, transferOffset, byref(error))
        return error

    ats.AlazarInputControl.restype = c_uint32
    ats.AlazarInputControl.argtypes = [handle_t, c_uint8, c_uint32, c_uint32, c_uint32]
    ats.AlazarInputControl.errcheck = returnCodeCheck
    def inputControl(self, channel, coupling, inputRange, impedance):
        '''Configures one input channel on a board.'''
        ats.AlazarInputControl(self.handle, channel, coupling, inputRange, impedance)

    ats.AlazarInputControlEx.restype = c_uint32
    ats.AlazarInputControlEx.argtypes = [handle_t, c_uint32, c_uint32, c_uint32, c_uint32]
    ats.AlazarInputControlEx.errcheck = returnCodeCheck
    def inputControlEx(self, channel, coupling, inputRange, impedance):
        '''Configures one input channel on a board.'''
        ats.AlazarInputControlEx(self.handle, channel, coupling, inputRange, impedance)

    ats.AlazarNumOfSystems.restype = c_uint32
    ats.AlazarNumOfSystems.argtypes = []
    def numOfSystems():
        '''Returns the number of board systems installed.'''
        ats.AlazarNumOfSystems()

    ats.AlazarPostAsyncBuffer.restype = c_uint32
    ats.AlazarPostAsyncBuffer.argtypes = [handle_t, c_void_p, c_uint32]
    ats.AlazarPostAsyncBuffer.errcheck = returnCodeCheck
    def postAsyncBuffer(self, buffer, bufferLength):
        '''Posts a DMA buffer to a board.'''
        ats.AlazarPostAsyncBuffer(self.handle, buffer, bufferLength)

    ats.AlazarQueryCapability.restype = c_uint32
    ats.AlazarQueryCapability.argtypes = [handle_t, c_uint32, c_uint32, POINTER(c_uint32)]
    ats.AlazarQueryCapability.errcheck = returnCodeCheck
    def queryCapability(self, capability, reserved = c_uint32(0)):
        '''Get a device attribute as an unsigned 32-bit integer'''
        retval = c_uint32(0)
        ats.AlazarQueryCapability(self.handle, capability, reserved, byref(retval))
        return retval

    ats.AlazarRead.restype = c_uint32
    ats.AlazarRead.argtypes = [handle_t, c_uint32, c_void_p, c_int, c_long, c_int32, c_uint32]
    ats.AlazarRead.errcheck = returnCodeCheck
    def read(self, channelId, buffer, elementSize, record, transferOffset, transferLength):
        '''Read all or part of a record from on-board memory.'''
        ats.AlazarRead(self.handle, channelId, buffer, elementSize, record, transferOffset, transferLength)

    ats.AlazarReadEx.restype = c_uint32
    ats.AlazarReadEx.argtypes = [handle_t, c_uint32, c_void_p, c_int, c_long, c_int64, c_uint32]
    ats.AlazarReadEx.errcheck = returnCodeCheck
    def readEx(self, channelId, buffer, elementSize, record, transferOffset, transferLength):
        '''Read all or part of a record from on-board memory.'''
        ats.AlazarReadEx(self.handle, channelId, buffer, elementSize, record, transferOffset, transferLength)

    ats.AlazarResetTimeStamp.restype = c_uint32
    ats.AlazarResetTimeStamp.argtypes = [handle_t, c_uint32]
    ats.AlazarResetTimeStamp.errcheck = returnCodeCheck
    def resetTimeStamp(self, option):
        '''Control record timestamp counter reset.'''
        ats.AlazarResetTimeStamp(self.handle, option)

    ats.AlazarSetBWLimit.restype = c_uint32
    ats.AlazarSetBWLimit.argtypes = [handle_t, c_uint32, c_uint32]
    ats.AlazarSetBWLimit.errcheck = returnCodeCheck
    def setBWLimit(self, channel, enable):
        '''Activates or deactivates the low-pass filter on a given channel.'''
        ats.AlazarSetBWLimit(self.handle, channel, enable)

    ats.AlazarSetCaptureClock.restype = c_uint32
    ats.AlazarSetCaptureClock.argtypes = [handle_t, c_uint32, c_uint32, c_uint32, c_uint32]
    ats.AlazarSetCaptureClock.errcheck = returnCodeCheck
    def setCaptureClock(self, source, rate, edge, decimation):
        '''Configures the board's acquisition clock.'''
        ats.AlazarSetCaptureClock(self.handle,
                                  int(source),
                                  int(rate),
                                  int(edge),
                                  decimation)

    ats.AlazarSetExternalClockLevel.restype = c_uint32
    ats.AlazarSetExternalClockLevel.argtypes = [handle_t, c_float]
    ats.AlazarSetExternalClockLevel.errcheck = returnCodeCheck
    def setExternalClockLevel(self, level_percent):
        '''Set the external clock comparator level'''
        ats.AlazarSetExternalClockLevel(self.handle, level_percent)

    ats.AlazarSetExternalTrigger.restype = c_uint32
    ats.AlazarSetExternalTrigger.argtypes = [handle_t, c_uint32, c_uint32]
    ats.AlazarSetExternalTrigger.errcheck = returnCodeCheck
    def setExternalTrigger(self, coupling, range):
        '''Configure the external trigger.'''
        ats.AlazarSetExternalTrigger(self.handle, coupling, range)

    ats.AlazarSetLED.restype = c_uint32
    ats.AlazarSetLED.argtypes = [handle_t, c_uint32]
    ats.AlazarSetLED.errcheck = returnCodeCheck
    def setLED(self, ledState):
        '''Control LED on a board's mounting bracket.'''
        ats.AlazarSetLED(self.handle, ledState)

    ats.AlazarSetParameter.restype = c_uint32
    ats.AlazarSetParameter.argtypes = [handle_t, c_uint8, c_uint32, c_long]
    ats.AlazarSetParameter.errcheck = returnCodeCheck
    def setParameter(self, channelId, parameterId, value):
        '''Set a device parameter as a signed long value.'''
        ats.AlazarSetParameter(self.handle, channelId, parameterId, value)

    ats.AlazarSetParameterUL.restype = c_uint32
    ats.AlazarSetParameterUL.argtypes = [handle_t, c_uint8, c_uint32, c_long]
    ats.AlazarSetParameterUL.errcheck = returnCodeCheck
    def setParameterUL(self, channelId, parameterId, value):
        '''Set a device parameter as a signed long value.'''
        ats.AlazarSetParameterUL(self.handle, channelId, parameterId, value)

    ats.AlazarSetRecordCount.restype = c_uint32
    ats.AlazarSetRecordCount.argtypes = [handle_t, c_uint32]
    ats.AlazarSetRecordCount.errcheck = returnCodeCheck
    def setRecordCount(self, count):
        '''Configure the record count for single ported acquisitions.'''
        ats.AlazarSetRecordCount(self.handle, count)

    ats.AlazarSetRecordSize.restype = c_uint32
    ats.AlazarSetRecordSize.argtypes = [handle_t, c_uint32, c_uint32]
    ats.AlazarSetRecordSize.errcheck = returnCodeCheck
    def setRecordSize(self, preTriggerSamples, postTriggerSamples):
        '''Configures the acquisition records size.'''
        ats.AlazarSetRecordSize(self.handle, preTriggerSamples, postTriggerSamples)

    ats.AlazarSetTriggerDelay.restype = c_uint32
    ats.AlazarSetTriggerDelay.argtypes = [handle_t, c_uint32]
    ats.AlazarSetTriggerDelay.errcheck = returnCodeCheck
    def setTriggerDelay(self, delay_samples):
        '''Configures the trigger delay.'''
        ats.AlazarSetTriggerDelay(self.handle, delay_samples)

    ats.AlazarSetTriggerOperation.restype = c_uint32
    ats.AlazarSetTriggerOperation.argtypes = [handle_t, c_uint32, c_uint32,
                                              c_uint32, c_uint32, c_uint32,
                                              c_uint32, c_uint32, c_uint32,
                                              c_uint32]
    ats.AlazarSetTriggerOperation.errcheck = returnCodeCheck
    def setTriggerOperation(self, operation,
                            engine1, source1, slope1, level1,
                            engine2, source2, slope2, level2):
        '''Set trigger operation.'''
        ats.AlazarSetTriggerOperation(
            self.handle, operation,
            engine1, source1, slope1, level1,
            engine2,
            source2,
            slope2,
            level2)

    ats.AlazarSetTriggerOperationForScanning.restype = c_uint32
    ats.AlazarSetTriggerOperationForScanning.argtypes = [handle_t, c_uint32, c_uint32, c_uint32]
    ats.AlazarSetTriggerOperationForScanning.errcheck = returnCodeCheck
    def setTriggerOperationForScanning(self, slopeId, level, options):
        '''Configure the trigger engines of a board to use and external trigger input
        and, optionally, synchronize the start of an acquisition with the next
        event after the acquisition starts.'''
        ats.AlazarSetTriggerOperationForScanning(self.handle, slopeId, level, options)

    ats.AlazarSetTriggerTimeOut.restype = c_uint32
    ats.AlazarSetTriggerTimeOut.argtypes = [handle_t, c_uint32]
    ats.AlazarSetTriggerTimeOut.errcheck = returnCodeCheck
    def setTriggerTimeOut(self, timeout_clocks):

        '''Configures the trigger timeout.'''
        ats.AlazarSetTriggerTimeOut(self.handle, timeout_clocks)

    ats.AlazarSleepDevice.restype = c_uint32
    ats.AlazarSleepDevice.argtypes = [handle_t, c_uint32]
    ats.AlazarSleepDevice.errcheck = returnCodeCheck
    def sleepDevice(self, sleepState):
        '''Control poewr to ADC devices'''
        ats.AlazarSleepDevice(self.handle, sleepState)

    ats.AlazarStartCapture.restype = c_uint32
    ats.AlazarStartCapture.argtypes = [handle_t]
    ats.AlazarStartCapture.errcheck = returnCodeCheck
    def startCapture(self):
        '''Starts the acquisition.'''
        ats.AlazarStartCapture(self.handle)

    ats.AlazarTriggered.restype = c_uint32
    ats.AlazarTriggered.argtypes = [handle_t]
    def triggered(self):
        '''Determine if a board has triggered during the current acquisition.'''
        return ats.AlazarTriggered(self.handle)

    ats.AlazarWaitAsyncBufferComplete.restype = c_uint32
    ats.AlazarWaitAsyncBufferComplete.argtypes = [handle_t, c_void_p, c_uint32]
    ats.AlazarWaitAsyncBufferComplete.errcheck = returnCodeCheck
    def waitAsyncBufferComplete(self, buffer, timeout_ms):
        '''Blocks until the board confirms that buffer is filled with data.'''
        ats.AlazarWaitAsyncBufferComplete(self.handle, buffer, timeout_ms)

    ats.AlazarOCTIgnoreBadClock.restype = c_uint32
    ats.AlazarOCTIgnoreBadClock.argtypes = [handle_t, c_uint32, c_double, c_double, POINTER(c_double), POINTER(c_double)]
    ats.AlazarOCTIgnoreBadClock.errcheck = returnCodeCheck
    def octIgnoreBadClock(self, enable, goodClockDuration, badClockDuration, triggerCycleTime, triggerPulseWidth):
        '''Configure OCT Ignore Bad Clock.'''
        ats.AlazarOCTIgnoreBadClock(self.handle, enable, goodClockDuration, badClockDuration, triggerCycleTime, triggerPulseWidth)

    ats.AlazarEnableFFT.restype = c_uint32
    ats.AlazarEnableFFT.argtypes = [handle_t, c_int]
    ats.AlazarEnableFFT.errcheck = returnCodeCheck
    def enableFFT(self, enable):
        ats.AlazarEnableFFT(self.handle, 1 if enable else 0)
