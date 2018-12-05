// AxsunOCTCapture.h 
// Copyright 2017 Axsun Technologies
/** \file AxsunOCTCapture.h
* \brief Header file containing exported function prototypes and enums for integrating AxsunOCTCapture.dll into a parent application.

Updates in version 2.2.0.0:
 - added ability to retrieve a subset of A-scans within an image during call to axRequestImage (and other request functions). Configure the subset region with axImageRequestSize().

Updates in version 2.3.0.0:
 - added analog waveform generation control (e.g. for X-Y galvo scanners) via National Instruments USB-6211 multifunction DAQ.  See axScanCmd().

 Updates in version 2.3.1.0:
 - standardized search path for PCIe library

 Updates in version 2.4.0.0:
 - added axWriteFPGAregBIT() function to write individual bits in FPGA registers (via PCIe interface only)
 - added axPipelineMode() function to select output data type and location from processing pipeline (via PCIe interface only)

 Updates in version 2.5.0.0:
 - added more informative warning messages for axGetImageInfo, axRequestImage, and related Advanced and Frame-specific functions.
 - misc bug fixes to PCIe interface

 Updates in version 2.5.1.0
 - code maintenance update
 - added cache sync/flush for PCIe DMA transfers
 - fixed bug where "trig_too_fast" indicator was set on image widths of 256 pixels instead of 255
*/

#ifndef AXSUNOCTCAPTURE_H
#define AXSUNOCTCAPTURE_H

// defines
#ifdef _WINDOWS
#define EXPORT __declspec(dllexport)
#endif // _WINDOWS
#ifdef __GNUC__
#define EXPORT __attribute__((visibility("default")))
#endif // __GNUC__


// includes
#include <stdint.h>			// for integer typedefs
#ifdef __GNUC__
#include <stddef.h>			// for size_t on linux
#endif // __GNUC__


// enumerated data types
typedef enum data_type {
	u8,
	u16,
	u32,
	cmplx			// (16 bit Imaginary, 16 bit Real)
} data_type;

typedef enum colormap {
	sepia,
	greyscale,
	inv_grayscale,
	user
} colormap;

typedef enum request_mode {
	retrieve_to_caller,
	display_only,
	retrieve_and_display
} request_mode;

typedef enum scan_cmd_t {	// for analog waveform generation control
	/** Initialize & allocate scanner control resources */
	init_scan,
	/** Destroy & deallocate scanner control resources */
	destroy_scan,		
	/** Configure a rectangular raster scan pattern */
	set_rect_pattern,			
	/** Load an externally generated scan pattern */
	load_ext_pattern,			
	/** Start continuous line scanning based on configured scan pattern */
	continuous_line_scan,	 
	/** Start continuous raster scanning based on configured scan pattern */
	continuous_raster_scan,	
	/** Move to a configured position and stop scanning */
	stop_at_position,			
	/** Prepare burst raster scan by pre-loading buffers and waiting at start position */
	setup_burst_raster,	
	/** Start burst raster scan with minimum latency */
	start_burst_raster,
	/** Wait for burst raster to complete */
	wait_burst,
	/** Change between external and internal sample clock */
	set_sample_clock
} scan_cmd_t;

typedef struct scan_params_t {	// for analog waveform generation control
	/** The number of increments in the X dimension (i.e. number of A-scans per B-scan). Must be an even value between 2 and 10000. (Note values less than 256 will exceed the max Image_sync pulse frequency for a system running at 100kHz A-line rate.) */
	uint32_t X_increments;
	/** The number of increments in the Y dimension (i.e. number of B-scans per volume scan). Must be an even value between 2 and 10000. */
	uint32_t Y_increments;
	/** The peak output voltage in the X dimension (impacts lateral length of each B-scan). Negate this value to flip the B-scan orientation. Generated voltages will span -X_range to +X_range, centered at the origin defined by X_shift.*/
	double X_range;
	/** The peak output voltage in the Y dimension (impacts lateral length across all B-scans). Negate this value to flip the volume scan orientation. Generated voltages will span -Y_range to +Y_range, centered at the origin defined by Y_shift.*/
	double Y_range;
	/** The voltage to shift the origin in the X dimension (can be positive or negative, 0 = centered). */
	double X_shift;
	/** The voltage to shift the origin in the Y dimension (can be positive or negative, 0 = centered). */
	double Y_shift;
	/** The static voltage generated in the Y dimension during 1D/linear scanning (can be positive or negative, relative to the origin defined by Y_shift). */
	double Y_idle;
	/** A phase shift applied to the X dimension waveform to control the relative delay between the analog output sawtooth waveform and the Image_sync pulse. Expressed as a percentage on the interval of 0 to 100; values outside this range will be coerced. */
	double X_phase;
	/** RFU - FUNCTIONALITY NOT YET IMPLEMENTED */
	double rotate;
} scan_params_t;

typedef struct ext_pattern_t {	// for analog waveform generation control
	/** The number of increments in the X dimension (i.e. number of A-scans per B-scan). Must be an even value between 2 and 10000. This field also defines the Image_sync pulse frequency which is constant for the entire raster scan. (Note values less than 256 will exceed the max Image_sync pulse frequency for a system running at 100kHz A-line rate.)*/
	uint32_t ext_X_increments;
	/** The number of increments in the Y dimension (i.e. number of B-scans per volume scan). Must be an even value between 2 and 10000. */
	uint32_t ext_Y_increments;
	/** Pointer to array definining the linear (1D) scan pattern. Length of array must be 2 * ext_X_increments (X and Y voltages interleaved for each output sample).*/
	double * linear_pattern;
	/** Pointer to array definining the raster (2D) scan pattern. Length of array must be 2 * ext_X_increments * ext_Y_increments (X and Y voltages interleaved for each output sample).*/
	double * raster_pattern;
} ext_pattern_t;

// public function declarations and descriptions

#ifdef __cplusplus
extern "C" {
#endif

	/**
	\brief Start an Axsun Ethernet DAQ imaging session by initializing packet capture and allocating memory for the main image buffer.
	\param capacity The desired size (in number of packets; 1 packet = 1024 bytes) to allocate for the main image buffer.
	\return = 0 for failed session start.  Call axGetMessage for more information.
	\return = 1 for successful session start.
	\return = 2 if session started but without capture capabilities (review pre-captured data only).
	\details axStartSession is the first method called in a typical implementation of the AxsunOCTCapture API when using the Ethernet interface.  
	Sessions started with axStartSession must be closed with axStopSession before the parent application exits.
	Note that an incomplete session start may still allocate resources, therefore axStopSession should always be called even if axStartSession returns 0.
	*/
	EXPORT int32_t axStartSession(uint32_t capacity);

	/**
	\brief Stop an Axsun Ethernet DAQ imaging session by deallocating resources.
	\return = 1 for successful deallocation.  
	\return = 0 for failed or incomplete deallocation.  Call axGetMessage for more information.
	\details axStopSession is the last method called in a typical implementation of the AxsunOCTCapture API.
	Sessions started with axStartSession must be closed with axStopSession before the parent application exits.
	Note that an incomplete session start may still allocate resources, therefore axStopSession should always be called even if axStartSession returns 0.
	*/
	EXPORT int32_t axStopSession(void);

	/**
	\brief Get explanation for errors or other status messages.
	\param message_out A pointer to a pre-allocated buffer of characters with size = 256 bytes.
	\return The number of characters (bytes) written into the message_out buffer.
	\details axGetMessage can be called immediately after an ax function returns an error code or if additional status information is desired.
	axGetMessage will populate the contents of the pre-allocated 256-byte output buffer passed to it.
	It is unsafe to pass an output buffer allocated with fewer than 256 bytes.
	*/
	EXPORT size_t axGetMessage(char* message_out);

	/**
	\brief Get status regarding imaging mode and main buffer statistics.
	\param imaging Will be populated with 0 if imaging is off, 1 if imaging is on but not recording, or 3 if imaging is on and recording is active. A value of 2 indicates imaging is off, but that the most recent image data in the buffer was captured during a record operation (whether just captured or loaded from a file).
	\param last_packet_in Will be populated with the unique packet number most recently enqueued into the main image buffer.
	\param last_frame_in Will be populated with the unique frame number most recently enqueued into the main image buffer.
	\param last_image_in Will be populated with the unique image number most recently enqueued into the main image buffer.
	\param dropped_packets Will be populated with the number of packets dropped since the last imaging mode reset.
	\param frames_since_sync Will be populated with the number of frames enqueued since the last Image_sync pulse was received.  When this number reaches the configured trigger timeout, the driver will transition to Force Trigger mode.
	\return = 1 for successful return of status information.
	\return = 0 if Axsun OCT Capture session not setup (call axStartSession first).
	\details
	*/
	EXPORT int32_t axGetStatus(uint32_t * imaging, uint32_t * last_packet_in, uint32_t * last_frame_in, uint32_t *last_image_in, uint32_t * dropped_packets, uint32_t *frames_since_sync);

	/**
	\brief Get instantaneous data transfer rate (Ethernet transfers only)
	\return = positive value: the estimated data transfer rate in megabits/second for the most recently enqueued frame.
	\return = negative value: error (call axGetMessage for more information).
	*/	
	EXPORT float axGetDataRate(void);

	/**
	\brief Get information on an image in the main image buffer.
	\param requested_image_number The image number for which information is desired. This can be a unique image number or it can be set to -1 to get info on the most recently enqueued image in the buffer.
	\param returned_image_number Will be populated with the unique image number. This will be equal to the "requested_image_number" parameter unless that parameter is set to -1 to get info on the most recent image.
	\param required_buffer_size Will be populated with the required size (in bytes) of a user buffer that must be allocated before image retrieval using axRequestImageAdv or axRequestImage.
	\return = 1 for successful retrieval of requested image information.
	\return = 0 if Axsun OCT Capture session not setup (call axStartSession first).
	\return = 9999 if requested image is not found in the main image buffer.
	\return = 9997 if requested image is "stale" - that is, the same as the previously requested image. This indicates that a subsequent image request can be skipped, avoiding computational load associated with fetching an image already in user memory.
	\return = other error codes:  call axGetMessage for more information.
	\details axGetImageInfo gets information on an image in the main image buffer before a more computationally expensive request is made to retrieve or display the image.
	A call to axGetImageInfo is intended to precede a call to axRequestImage or axRequestImageAdv and provides several arguments to these functions (output_buf_len, requested_image_number) and identifies "stale" images (for avoiding the wasted computation resources incurred by calling axRequestImage using the same requested image number on consecutive calls).
	See axGetImageInfoAdv for an advanced version of this function.*/
	EXPORT int32_t axGetImageInfo(int64_t requested_image_number, uint32_t * returned_image_number, uint32_t * required_buffer_size);

	/**
	\brief Advanced function for getting information on an image in the main image buffer.
	\param requested_image_number The image number for which information is desired. This can be a unique image number or it can be set to -1 to get info on the most recently enqueued image in the buffer.
	\param returned_image_number Will be populated with the unique image number. This will be equal to the "requested_image_number" parameter unless that parameter is set to -1 to get info on the most recent image.
	\param height Will be populated with the height of the requested image (in pixels).
	\param width Will be populated with the width of the requested image (in pixels).
	\param data_type_out Will be populated with the data type of the requested image (see data_type enum definition)
	\param required_buffer_size Will be populated with the required size (in bytes) of a user buffer that must be allocated before image retrieval using axRequestImageAdv or axRequestImage.
	\param force_trig Will be populated with 1 if requested image was acquired in Force Trigger mode, or 0 otherwise.  See description associated with axSetTrigTimeout function.
	\param trig_too_fast Will be populated with 1 if Image_sync trigger period is too short, or 0 otherwise.
	\return = 1 for successful retrieval of requested image information.
	\return = 0 if Axsun OCT Capture session not setup (call axStartSession first).
	\return = 9999 if requested image is not found in the main image buffer.
	\return = 9997 if requested image is "stale" - that is, the same as the previously requested image. This indicates that a subsequent image request can be skipped, avoiding computational load associated with fetching an image already in user memory.
	\return = other error codes:  call axGetMessage for more information.
	\details axGetImageInfoAdv gets information on an image in the main image buffer before a more computationally expensive request is made to retrieve or display the image.
	A call to axGetImageInfoAdv is intended to precede a call to axRequestImageAdv and provides several arguments to axRequestImageAdv (output_buf_len, requested_image_number) and identifies "stale" images (for avoiding the wasted computation resources incurred by calling axRequestImageAdv using the same requested image number on consecutive calls).
	See axGetImageInfo for a simplified version of this function.*/
	EXPORT int32_t axGetImageInfoAdv(int64_t requested_image_number, uint32_t * returned_image_number, int32_t * height, int32_t * width, data_type *data_type_out, uint32_t * required_buffer_size, uint8_t * force_trig, uint8_t * trig_too_fast);

	/**
	\brief Retrieve an image from the main image buffer into a user buffer.
	\param requested_image_number The image number requested for retrieval. This can be a unique image number or it can be set to -1 to request the most recently enqueued image in the buffer.
	\param returned_image_number Will be populated with the unique image number retrieved. This will be equal to the "requested_image_number" parameter unless that parameter is set to -1 to request the most recent image.
	\param height Will be populated with the height of the requested image (in pixels).
	\param width Will be populated with the width of the requested image (in pixels).
	\param data_type_out Will be populated with the data type of the requested image (see data_type enum definition)
	\param image_data_out A pre-allocated buffer into which the retrieved image is copied for subsequent user interaction. Buffer size must be at least as large as indicated by a preceding call to axGetImageInfo or axGetImageInfoAdv ("required_buffer_size").
	\param output_buf_len The pre-allocated size in bytes of the image_data_out buffer.
	\return = 1 for successful retrieval of requested image.
	\return = 0 if Axsun OCT Capture session not setup (call axStartSession first).
	\return = 9999 if requested image is not found in the main image buffer.
	\return = 9994 if pre-allocated buffer size is too small to retrieve requested image.
	\return = other error codes:  call axGetMessage for more information.
	\details axRequestImage requests the retrieval (into a pre-allocated buffer defined by the user) of an image from the main image buffer.
	See axRequestImageAdv for an advanced version of this function.*/
	EXPORT int32_t axRequestImage(int64_t requested_image_number, uint32_t * returned_image_number, int32_t * height, int32_t * width, data_type *data_type_out, uint8_t * image_data_out, uint32_t output_buf_len);

	/**
	\brief Advanced function for retrieving and/or displaying an image from the main image buffer.
	\param requested_image_number The image number requested for retrieval and/or display. This can be a unique image number or it can be set to -1 to request the most recently enqueued image in the buffer.
	\param image_data_out A pre-allocated buffer into which the retrieved image is copied for subsequent user interaction. Buffer size must be at least as large as indicated by a preceding call to axGetImageInfo or axGetImageInfoAdv ("required_buffer_size"). Can be NULL if req_mode parameter is set to display_only.
	\param metadata_out A pre-allocated buffer of 34 bytes into which pertinent image metadata is copied.
	\param height Will be populated with the height of the requested image (in pixels).
	\param width Will be populated with the width of the requested image (in pixels).
	\param data_type_out Will be populated with the data type of the requested image (see data_type enum definition)
	\param output_buf_len The pre-allocated length in bytes of the image_data_out buffer. Can be 0 if req_mode parameter is set to display_only.
	\param average_number Select the number of consecutive images to be averaged (mean) up to maximum of 10. Set to 1 for no image averaging.  Image width must be <= 5000 A-scans.
	\param req_mode Indicate if requested image is to be retrieved to the caller (via image_data_out buffer), displayed directly via OpenGL, or both.
	\param force_trig Will be populated with 1 if requested image was acquired in Force Trigger mode, or 0 otherwise.  See description associated with axSetTrigTimeout function.
	\param trig_too_fast Will be populated with 1 if Image_sync trigger period is too short, or 0 otherwise.
	\return = 1 for successful retrieval and/or display of requested image.
	\return = 0 if Axsun OCT Capture session not setup (call axStartSession first) or if OpenGL window not setup (call axSetupDisplay).
	\return = 9999 if requested image is not found in the main image buffer.
	\return = 9994 if pre-allocated buffer size is too small to retrieve requested image.
	\return = other error codes:  call axGetMessage for more information.
	\details axRequestImageAdv requests the retrieval (into a pre-allocated buffer defined by the user) and/or display (directly rendered into OpenGL window) of an image from the main image buffer.  OpenGL display works only for 8-bit image data.
	A call to axRequestImageAdv is intended to follow a call to axGetImageInfoAdv, which provides several arguments to axRequestImageAdv (output_buf_len, requested_image_number) and identifies "stale" images (for avoiding the wasted computation resources incurred by calling axRequestImageAdv using the same requested image number on consecutive calls).
	See axRequestImage for a simplified version of this function.*/
	EXPORT int32_t axRequestImageAdv(int64_t requested_image_number, uint8_t * image_data_out, uint8_t * metadata_out, int32_t * height, int32_t * width, data_type *data_type_out, uint32_t output_buf_len, uint8_t average_number, request_mode req_mode, uint8_t * force_trig, uint8_t * trig_too_fast);

	/**
	\brief Configure the cropped subset of A-scans to retrieve or display in subsequent calls to axRequestImage (and other retrieve or display calls).
	\param start_Ascan The first A-scan to be retrieved, a positive-valued offset from the Image_sync pulse defining the start of an image.
	\param total_Ascans The total number of A-scans to be retrieved.  Set to 0 to retrieve the full image.
	\return = 1 for successful configuration of image start A-scan and total size.
	\return = 0 if Axsun OCT Capture session not setup (call axStartSession first).
	\details This function sets the parameters used for cropping of a full image along the A-scan dimension (defined by two Image_sync pulses) within subsequent axRequestImage calls, avoiding inefficiency associated with copying unwanted A-scans which would subsequently be discarded by the calling application.
	If the start_Ascan offset value exceeds the available A-scans in an image, the requested image will be retrieved/displayed starting at offset = 0.
	If total_Ascans exceeds the remaining A-scans available following start_Ascan, the remaining available A-scans in the image will be retrieved/displayed.
	Image subsetting/cropping is not available in Force Trigger mode (i.e. when no Image_sync is detected).
	Note that the image width cropping behavior based on these settings is applied prior to the OpenGL display window cropping behavior configured using axCropRect.  
	*/
	EXPORT int32_t axImageRequestSize(uint32_t start_Ascan, uint32_t total_Ascans);

	/**
	\brief Get information on a frame in the main image buffer (A frame is 256 A-scans, unsynchronized with Image_sync signal).
	\param requested_frame_number The frame number for which information is desired. This can be a unique frame number or it can be set to -1 to get info on the most recently enqueued frame in the buffer.
	\param returned_frame_number Will be populated with the unique frame number. This will be equal to the "requested_frame_number" parameter unless that parameter is set to -1 to get info on the most recent frame.
	\param height Will be populated with the height of the requested frame (in pixels).
	\param width Will be populated with the width of the requested frame (in pixels).
	\param data_type_out Will be populated with the data type of the requested frame (see data_type enum definition)
	\param required_buffer_size Will be populated with the required size (in bytes) of a user buffer that must be allocated before frame retrieval using axRequestFrameAdv.
	\return = 1 for successful retrieval of requested frame information.
	\return = 0 if Axsun OCT Capture session not setup (call axStartSession first).
	\return = 9999 if requested frame is not found in the main image buffer.
	\return = 9997 if requested frame is "stale" - that is, the same as the previously requested frame. This indicates that a subsequent frame request can be skipped, avoiding computational load associated with fetching a frame already in user memory.
	\return = other error codes:  call axGetMessage for more information.
	\details axGetFrameInfoAdv gets information on a frame in the main image buffer before a more computationally expensive request is made to retrieve the frame data.
	A call to axGetFrameInfoAdv is intended to precede a call to axRequestFrameAdv and provides several arguments to axRequestFrameAdv (output_buf_len, requested_frame_number) and identifies "stale" images (for avoiding the wasted computation resources incurred by calling axRequestFrameAdv using the same requested frame number on consecutive calls).
	*/
	EXPORT int32_t axGetFrameInfoAdv(int64_t requested_frame_number, uint32_t * returned_frame_number, int32_t * height, int32_t * width, data_type *data_type_out, uint32_t * required_buffer_size);

	/**
	\brief Retrieve a frame from the main image buffer (A frame is 256 A-scans, unsynchronized with Image_sync signal).
	\param requested_frame_number The frame number requested for retrieval. This can be a unique image number or it can be set to -1 to request the most recently enqueued frame in the buffer.
	\param frame_data_out A pre-allocated buffer into which the retrieved frame is copied for subsequent user interaction. Buffer size must be at least as large as indicated by a preceding call to axGetFrameInfoAdv ("required_buffer_size").
	\param metadata_out A pre-allocated buffer of 34 bytes into which frame metadata is copied.
	\param height Will be populated with the height of the requested frame (in pixels).
	\param width Will be populated with the width of the requested frame (in pixels).
	\param data_type_out Will be populated with the data type of the requested frame (see data_type enum definition)
	\param output_buf_len The pre-allocated length in bytes of the frame_data_out buffer.
	\return = 1 for successful retrieval of requested frame.
	\return = 0 if Axsun OCT Capture session not setup (call axStartSession first).
	\return = 9999 if requested frame is not found in the main image buffer.
	\return = 9994 if pre-allocated buffer size is too small to retrieve requested frame.
	\return = other error codes:  call axGetMessage for more information.
	\details axRequestFrameAdv requests the retrieval (into a pre-allocated buffer defined by the user) of a frame from the main image buffer.
	A call to axRequestFrameAdv is intended to follow a call to axGetFrameInfoAdv, which provides several arguments to axRequestFrameAdv (output_buf_len, requested_frame_number) and identifies "stale" images (for avoiding the wasted computation resources incurred by calling axRequestFrameAdv using the same requested frame number on consecutive calls).
	OpenGL display of frames is currently unsupported.*/
	EXPORT int32_t axRequestFrameAdv(int64_t requested_frame_number, uint8_t * frame_data_out, uint8_t * metadata_out, int32_t * height, int32_t * width, data_type *data_type_out, uint32_t output_buf_len);

	/**
	\brief Get un-decompressed size information on a compressed JPEG frame in the main image buffer (A frame is 256 A-scans, unsynchronized with Image_sync signal).
	\param requested_frame_number The frame number for which information is desired. This can be a unique frame number or it can be set to -1 to get info on the most recently enqueued frame in the buffer.
	\param returned_frame_number Will be populated with the unique frame number. This will be equal to the "requested_frame_number" parameter unless that parameter is set to -1 to get info on the most recent frame.
	\param required_buffer_size Will be populated with the required size (in bytes) of a user buffer that must be allocated before JPEG retrieval using axRequestCompressedJPEG.
	\return = 1 for successful retrieval of requested frame information.
	\return = 0 if Axsun OCT Capture session not setup (call axStartSession first).
	\return = 9999 if requested frame is not found in the main image buffer.
	\return = 9997 if requested frame is "stale" - that is, the same as the previously requested frame. This indicates that a subsequent frame request can be skipped, avoiding computational load associated with fetching a frame already in user memory.
	\return = other error codes:  call axGetMessage for more information.
	\details axGetCompressedJPEGInfo gets information on a JPEG compressed frame in the main image buffer before a request is made to retrieve the JPEG data into a user buffer.
	A call to axGetCompressedJPEGInfo is intended to precede a call to axRequestCompressedJPEG and provides several arguments to axRequestCompressedJPEG (output_buf_len, requested_frame_number)
	and identifies "stale" images (for avoiding redundant memory copies if calling axRequestCompressedJPEG using the same requested frame number on consecutive calls).
	*/
	EXPORT int32_t axGetCompressedJPEGInfo(int64_t requested_frame_number, uint32_t * returned_frame_number, uint32_t * required_buffer_size);

	/**
	\brief Retrieve an un-decompressed JPEG frame from the main image buffer (A frame is 256 A-scans, unsynchronized with Image_sync signal).
	\param requested_frame_number The frame number requested for retrieval. This can be a unique image number or it can be set to -1 to request the most recently enqueued frame in the buffer.
	\param JPEG_data_out A pre-allocated buffer into which the retrieved JPEG frame is copied for subsequent user interaction. Buffer size must be at least as large as indicated by a preceding call to axGetCompressedJPEGInfo ("required_buffer_size").
	\param metadata_out A pre-allocated buffer of 34 bytes into which frame metadata is copied.
	\param output_buf_len The pre-allocated length in bytes of the JPEG_data_out buffer.
	\return = 1 for successful retrieval of requested JPEG frame.
	\return = 0 if Axsun OCT Capture session not setup (call axStartSession first).
	\return = 9999 if requested frame is not found in the main image buffer.
	\return = 9994 if pre-allocated buffer size is too small to retrieve requested frame.
	\return = other error codes:  call axGetMessage for more information.
	\details axRequestCompressedJPEG requests the retrieval (into a pre-allocated buffer defined by the user) of un-decompressed JPEG information.
	This JPEG can subsequently be saved as a file and/or decompressed by the user's preferred JPEG decompression library or utility.
	A call to axRequestCompressedJPEG is intended to follow a call to axGetCompressedJPEGInfo, which provides several arguments to axRequestCompressedJPEG (output_buf_len, requested_frame_number)
	and identifies "stale" images (for avoiding redundant memory copies if calling axRequestCompressedJPEG using the same requested frame number on consecutive calls).
	*/
	EXPORT int32_t axRequestCompressedJPEG(int64_t requested_frame_number, uint8_t * JPEG_data_out, uint8_t * metadata_out, uint32_t output_buf_len);

	/**
	\brief Setup an OpenGL display window for direct rendering of image data.
	\param window_mode_in The window mode: either a floating window with border (=0) or a fixed borderless window (=1).  This mode cannot be changed once the window is created.
	\param w_left The initial left edge of the window in display coordinates. Also see axUpdateView.
	\param w_top The initial top edge of the window in display coordinates. Also see axUpdateView.
	\param w_width The initial width of the window. Also see axUpdateView.
	\param w_height The initial height of the window. Also see axUpdateView.
	\param parent_window_handle The window handle (HWND) of an existing window of which the OpenGL window is created as a child window.  Set this to NULL for creating an OpenGL window with no parent.
	\return = 1 for successful setup.
	\return = 0 if Axsun OCT Capture session not setup (call axStartSession first).
	\return = negative value if OpenGL setup failed. Call axGetMessage for more information.
	\details Any resources allocated with axSetupDisplay are automatically deallocated by axStopSession when terminating the main Axsun OCT Capture Session.
	Parameters set the initial size and location of the OpenGL window at creation but, except for the window mode and parent/child relationship, 
	these can be subsequently changed according to the axUpdateView function.
	*/
	EXPORT int32_t axSetupDisplay(uint8_t window_mode_in, int32_t w_left, int32_t w_top, int32_t w_width, int32_t w_height, uintptr_t parent_window_handle);

	/**
	\brief Display an image from the main image buffer directly to an OpenGL window (8-bit image data only).
	\param requested_image_number The image number requested for display. This can be a unique image number or it can be set to -1 to request the most recently enqueued image in the buffer.
	\param returned_image_number Will be populated with the unique image number displayed. This will be equal to the "requested_image_number" parameter unless that parameter is set to -1 to request the most recent image.
	\param height Will be populated with the height of the requested image (in pixels).
	\param width Will be populated with the width of the requested image (in pixels).
	\return = 1 for successful retrieval of requested image.
	\return = 0 if Axsun OCT Capture session not setup (call axStartSession first) or if OpenGL window not setup (call axSetupDisplay).
	\return = 9999 if requested image is not found in the main image buffer.
	\return = other error codes:  call axGetMessage for more information.
	\details axDisplayImage requests the display (directly rendered into an OpenGL window) of an image from the main image buffer.  This function works only for 8-bit image data.
	See axRequestImageAdv for an advanced version of this function.*/
	EXPORT int32_t axDisplayImage(int64_t requested_image_number, uint32_t * returned_image_number, int32_t * height, int32_t * width);

	/**
	\brief Select the color scheme of images displayed in an OpenGL window.
	\param colors The desired color scheme can be sepia, grayscale, inverted greyscale, or a user-defined scheme loaded using axLoadUserColormap (see colormap enum).
	\return = 1 for successful update of the color scheme.
	\return = 0 if Axsun OCT Capture session not setup (call axStartSession first) or if OpenGL window not setup (call axSetupDisplay).
	\details 
	*/
	EXPORT int32_t axSelectColormap(colormap colors);

	/**
	\brief Load a user-defined colormap for images displayed in an OpenGL window.
	\param user_colormap_in The colormap array to be loaded.
	\return = 1 for successful update of the user-defined colormap.
	\return = 0 if Axsun OCT Capture session not setup (call axStartSession first) or if OpenGL window not setup (call axSetupDisplay).
	\details To display a user-defined colormap loaded using this function, the "user" colormap must be selected with axSelectColormap.
	The colormap format is a 768-byte array composed of 256 R,G,B triads: (R0, G0, B0), (R1, G1, B1), (R2, G2, B2), ..., (R255, G255, B255)
	*/
	EXPORT int32_t axLoadUserColormap(uint8_t * user_colormap_in);

	/**
	\brief Change the polar -> rectangular scan conversion behavior of images displayed in an OpenGL window.
	\param convert The desired scan conversion behavior (disabled = 0, enabled = 1).
	\param interpolation The desired interpolation mode (bilinear = 0, nearest neighbor = 1).
	\param inner_radius A value on the interval [0..1] which defines the inner edge of the annulus onto which an image's r = 0 data is rendered. (0 = center, 1 = outer edge of uncropped display window) 
	\param outer_radius A value on the interval [0..1] which defines the outer edge of the annulus onto which an image's r = Rmax data is rendered. (0 = center, 1 = outer edge of uncropped display window)
	\param crop_inner A value on the interval [-1..1] which defines the fraction of total image cropped prior to scan conversion in the radial direction from r = 0 outward.
	\param crop_outer A value on the interval [0..2] which defines the fraction of total image cropped prior to scan conversion in the radial direction from r = Rmax inward.
	\return = 1 for successful update of the scan conversion behavior.
	\return = 0 if Axsun OCT Capture session not setup (call axStartSession first) or if OpenGL window not setup (call axSetupDisplay).
	\details Polar-to-rectangular scan conversion is useful for displaying images on a cartesian (x,y) display when acquired with a rotational probe or catheter in polar (r,theta) coordinates.
	For maximized field of view, inner_radius and crop_inner should be set to 0 and outer_radius and crop_outer should be set to 1. 
	Adjusting crop_inner and crop_outer by an equivalent amount will achieve a 'digital Z-offset' radial shifting effect.
	*/
	EXPORT int32_t axScanConvert(uint8_t convert, uint8_t interpolation, float inner_radius, float outer_radius, float crop_inner, float crop_outer);

	/**
	\brief Change the OpenGL window size and position.
	\param w_left The left edge of the window in display coordinates (fixed borderless window only).
	\param w_top The top edge of the window in display coordinates (fixed borderless window only).
	\param w_width The width of the window in pixels.
	\param w_height The height of the window in pixels.
	\return = 1 for successful update of the window size and position.
	\return = 0 if Axsun OCT Capture session not setup (call axStartSession first) or if OpenGL window not setup (call axSetupDisplay).
	\details Note that window width and height parameters outside the range [32,4000] will be coerced. 
	The w_left and w_top parameters are ignored when the window mode is floating with a border (see axSetupDisplay).
	*/
	EXPORT int32_t axUpdateView(int32_t w_left, int32_t w_top, int32_t w_width, int32_t w_height);

	/**
	\brief Change the rectangular cropping behavior of images displayed in an OpenGL window.
	\param crop_left Fraction of total image width cropped from left (0 = no cropping, 0.5 = half of image cropped, etc.).
	\param crop_top Fraction of total image height cropped from top.
	\param crop_bottom Fraction of total image height cropped from bottom.
	\param crop_right Fraction of total image width cropped from right.
	\return = 1 for successful update of the window size and position.
	\return = 0 if Axsun OCT Capture session not setup (call axStartSession first) or if OpenGL window not setup (call axSetupDisplay).
	\details Cropping parameters less than zero are ignored.
	*/
	EXPORT int32_t axCropRect(float crop_left, float crop_top, float crop_bottom, float crop_right);

	/**
	\brief Change the brightness and contrast of images displayed in an OpenGL window.
	\param brightness The desired brightness. Typical values are in the range [-0.5, 0.5].
	\param contrast The desired contrast. Typical values are in the range [0.5, 1.5].
	\return = 1 for successful update of the brightness and contrast.
	\return = 0 if Axsun OCT Capture session not setup (call axStartSession first) or if OpenGL window not setup (call axSetupDisplay).
	\details Note that if the color scheme is set to inverted greyscale (see axLoadColormap), the behavior of the brightness parameter is inverted (i.e. higher values of the brightness parameter result in a darker image).
	*/
	EXPORT int32_t axAdjustBrightnessContrast(float brightness, float contrast);

	/**
	\brief Hide or unhide the OpenGL image display window.
	\param visible_state The desired window visibility state (visible = 0, hidden = 1). The window is visible by default at window creation.
	\return = 1 for successful update of the window visibility state.
	\return = 0 if Axsun OCT Capture session not setup (call axStartSession first) or if OpenGL window not setup (call axSetupDisplay).
	\details
	*/
	EXPORT int32_t axHideWindow(uint32_t hidden);

	/**
	\brief Control the behavior of Force Trigger mode.
	\param timeout_frames The number of frames for which the driver will wait for a Image_sync signal before timing out and entering Force Trigger mode.  Defaults to 24 frames at session creation.
	\return = 1 for successful setting of trigger timeout.
	\return = 0 if Axsun OCT Capture session not setup (call axStartSession first).
	\return = -1 if requested number of frames is outside of allowable range.  Call axGetMessage for more information.
	\details The trigger timeout defines the number of consecutive frames for which the driver will wait for a Image_sync signal prior to transitioning into Force Trigger mode.
	Once in Force Trigger mode, the driver will return the most recently captured frame (256 A-scans) with no synchronization with the Image_sync signal (which is either too slow or absent altogether).
	The driver will automatically exit Force Trigger mode and re-synchronize with the Image_sync signal as soon as two consecutive Image_sync signals are detected within the timeout period.
	Set the trigger timeout based on the expected Image_sync signal period of your scanner and the system A-scan rate.
	For example, assume an effective A-scan rate of 100,000 Hz and a Image_sync period of 33 milliseconds (i.e. a B-scan period determined by the frequency of a scanner running at 30 fps).
	The trigger timeout is defined in number of frames (consisting of 256 A-scans each), hence the frame time for a 100kHz system is 2.56 milliseconds (=256/100000).
	A trigger timeout setting of at least 13 frames equaling 33.28 milliseconds (= 2.56 ms * 13) is required to avoid experiencing premature Force Trigger timeout.
	Setting a trigger timeout several frames larger than the minimum is recommended; however, setting it too high will delay or prevent the transition to Force Trigger mode when desired (e.g. when a Image_sync signal is absent).
	Remember that the A-scan subsampling feature on the DAQ reduces the effective A-scan rate of the system and could impact the trigger timeout calculation.
	*/
	EXPORT int32_t axSetTrigTimeout(uint32_t timeout_frames);

	/**
	\brief Enable or disable 2x downsampling during JPEG decompression.
	\param downsampling_state The desired downsampling behavior (disabled = 0, enabled = 1).  Downsampling is disabled by default at session creation.
	\return = 1 for successful update of the downsampling behavior.
	\return = 0 if Axsun OCT Capture session not setup (call axStartSession first).
	\details 2x downsampling speeds up JPEG decompression but halves the width and height of retrieved and/or displayed images.  The original full-resolution images persist in the main image buffer.
	Downsampling is helpful to keep frame rates high during real-time acquisition and display of images that have very high numbers of a-scans/image and are thus larger than the display pixel dimensions.
	Note that this function is not "thread-safe" with respect to the axGetImageInfo and axRequestImage functions; use of the "required_buffer_size" calculated by axGetImageInfo or axGetImageInfoAdv will not be appropriate as the "output_buf_len" for the subsequent axRequestImage or axRequestImageAdv call if the downsampling behavior was changed.
	*/
	EXPORT int32_t axDownsampling(uint32_t downsampling_state);

	/**
	\brief Save contents of main image buffer to disk.
	\param path_file Full directory and filename at which to create new save file.
	\param full_buffer Set to 0 for saving only data captured during the most recent imaging sequence (e.g. a burst record) or set to 1 to save the full buffer.
	\param packets_written Will be populated with the number of packets successfully saved to disk.
	\return = 1 for successful saving of buffer to disk.
	\return = 0 if Axsun OCT Capture session not setup (call axStartSession first).
	\return = -1 if unable to create file.
	\return = other error codes:  call axGetMessage for more information.
	\details Note that a preexisting file at the location indicated for saving will be overwritten without warning.
	*/
	EXPORT int32_t axSaveFile(const char * path_file, uint32_t full_buffer, uint32_t * packets_written);

	/**
	\brief Load contents from file on disk into main image buffer.
	\param path_file Full directory and filename from which to load data.
	\param packets_read Will be populated with the number of packets successfully loaded from disk.
	\return = 1 for successful loading of data into main image buffer from disk.
	\return = 0 if Axsun OCT Capture session not setup (call axStartSession first).
	\return = -1 if file could not be opened.
	\return = -2 if incorrect file type.
	\return = other error codes:  call axGetMessage for more information.
	\details Note that a subsequent call to axGetStatus is useful for determining the number of frames and images loaded into the main image buffer by this function.  A call to axClearBuffer can be used to clear the main image buffer prior to loading.  This function should be called only when images are NOT currently being enqueued into the buffer by a connected DAQ board.
	*/
	EXPORT int32_t axLoadFile(const char * path_file, uint32_t * packets_read);

	/**
	\brief Clear main image buffer by resetting all data to zero.
	\return = 1 for successful clearing of main image buffer.
	\return = 0 if Axsun OCT Capture session not setup (call axStartSession first).
	\return = other error codes:  call axGetMessage for more information.
	\details This function is useful for avoiding retrieval of images from prior imaging sequences which have not yet been overwritten. 
	Careful management of buffer status (i.e. number of images enqueued) returned using axGetStatus should avoid this situation, making the use of this function optional.
	This function should be called only when images are NOT currently being enqueued into the buffer by a connected DAQ board or load file operation.
	*/
	EXPORT int32_t axClearBuffer(void);

	/**
	\brief Start an Axsun PCIe DAQ imaging session by initializing PCIe interface and allocating memory for the main image buffer.
	\param capacity The desired size (in megabytes) to allocate for the main image buffer. (Note that the capacity argument for the Ethernet-specific axStartSession() function is in units of packets, not MB!) 
	\return = 0 for failed session start.  Call axGetMessage for more information.
	\return = 1 for successful session start.
	\return = 2 if session started but without capture capabilities (review pre-captured data only).
	\details axStartSessionPCIe is the first method called in a typical implementation of the AxsunOCTCapture API when using the PCIe interface.
	Sessions started with axStartSessionPCIe must be closed with axStopSession before the parent application exits.
	Note that an incomplete session start may still allocate resources, therefore axStopSession should always be called even if axStartSessionPCIe returns 0.
	*/
	EXPORT int32_t axStartSessionPCIe(uint32_t capacity);

	/**
	\brief Control the image streaming behavior of the Axsun PCIe DAQ between Live Imaging, Burst Recording, and Imaging Off states.
	\param number_of_images Set this argument to zero (0) for Imaging Off; set it to (-1) for Live Imaging (no record), or set it to any positive value between 1 and 32767 to request the desired number of images in a Burst Record operation.
	\return = 0 for failed control request to DAQ.  Call axGetMessage for more information.
	\return = 1 for successful control request to DAQ.
	\details axImagingCntrlPCIe controls the DMA-based transfer of images from the Axsun DAQ via the PCIe interface.  Note that this function does NOT control the laser
	and therefore the laser emission (along with its sweep trigger and k-clocks) must be enabled separately. This function takes a single parameter to select between three states: 
	Live Imaging, Burst Record, or Imaging Off.  In Live Imaging mode, the DAQ will acquire and transmit images indefinitely. 
	In Burst Record mode (actually a sub-mode of Live Imaging mode), the DAQ will acquire and transmit the finite number of images requested and then automatically transition itself to the Imaging Off state. 
	*/
	EXPORT int32_t axImagingCntrlPCIe(int16_t number_of_images);

	/**
	\brief Write a FPGA register on the Axsun DAQ via the PCIe interface.
	\param regnum The unique register number to which the write operation is directed.
	\param regval The desired 16-bit value to write.
	\return = 1 for successful request to write the FPGA register (see details).
	\return = 0 for failed register write.  Call axGetMessage for more information.
	\details Note that this function does not subsequently query the DAQ hardware to confirm the write was actually successful. A return value of 1 only indicates the software's request was made successfully. Call axReadFPGAreg to confirm hardware register value if desired.
	FPGA registers are 16-bits wide and all 16-bits must be written atomically.  To write individual bits in a register use the axWriteFPGAregBIT() function.
	axWriteFPGAreg is functionally equivalent to the AxsunOCTControl.dll library function "SetFPGARegister" used when connected to the DAQ via Ethernet or USB.
	*/
	EXPORT int32_t axWriteFPGAreg(uint16_t regnum, uint16_t regval);

	/**
	\brief Write a single bit in an FPGA register on the Axsun DAQ via the PCIe interface.
	\param regnum The unique register number to which the write operation is directed.
	\param bitnum The bit number within the desired register.  The 16 bits in the register are indexed from 0 (LSB) to 15 (MSB).
	\param bitval The value to write (0 = clear bit, 1 = set bit)
	\return = 1 for successful request to write the FPGA register (see details).
	\return = 0 for failed register write.  Call axGetMessage for more information.
	\details Note that this function does not subsequently query the DAQ hardware to confirm the write was actually successful. A return value of 1 only indicates the software's request was made successfully. Call axReadFPGAreg to confirm hardware register value if desired.
	*/
	EXPORT int32_t axWriteFPGAregBIT(uint16_t regnum, uint8_t bitnum, uint8_t bitval);

	/**
	\brief Configures FPGA registers to output the desired data type & location from the processing pipeline via the PCIe interface.
	\param mode The desired pipeline mode according to the numbered pipeline diagram shown as in the Operator's Manual.
	\return = 1 for successful request to write the FPGA registers (see details).
	\return = 0 for failed register write.  Call axGetMessage for more information.
	\details Note that this function does not subsequently query the DAQ hardware to confirm the write was actually successful. A return value of 1 only indicates the software's request was made successfully. Call axReadFPGAreg to confirm hardware register value if desired.
	*/
	EXPORT int32_t axPipelineMode(uint8_t mode);

	/**
	\brief Read a FPGA register on the Axsun DAQ via the PCIe interface.
	\param regnum The unique register number to which the read operation is directed.
	\param regval Will be populated with the register value fetched from the FPGA.
	\return = 1 for successful register read.
	\return = 0 for failed register read.  Call axGetMessage for more information.
	\details axReadFPGAreg is functionally equivalent to the AxsunOCTControl.dll library function "GetFPGARegister" used when connected to the DAQ via Ethernet or USB.
	*/
	EXPORT int32_t axReadFPGAreg(uint16_t regnum, uint16_t *regval);

	/**
	\brief Control analog output waveform generation for 2 channel (X-Y) scanners.
	\param scan_command The desired scanner function selected from available commands in the scan_cmd_t enum.  See below for notes on available scanner commands.
	\param misc_scalar A general purpose scalar value.  Valid when scan_command = init_scan or scan_command = wait_burst or scan_command = set_sample_clock. See below for usage.
	\param scan_parameters A structure defining the basic geometry of a rectangular raster scan pattern generated by the library (parameter valid when scan_command = set_rect_pattern or scan_command = stop_at_position, otherwise set to NULL).
	\param external_scan_pattern A structure defining the user-generated scan pattern and associated arrays to be loaded (parameter valid when scan_command = load_ext_pattern, otherwise set to NULL). 
	\param RFU Reserved for future use, set to NULL.
	\return = 1 for successful command execution.
	\return = 0 for scan command error.  Call axGetMessage for more information.
	\details Scan patterns are configured based on voltage values at the output pins of the analog output generation device. Converting a voltage value to an optical beam position must incorporate external linear and non-linear factors such as the type of scanner & amplifier/controller, the opto-mechanical layout, lens distortion, etc.
	The active scan pattern (an array of interleaved X and Y voltages) can be generated by the library based on user-configurable high-level geometric parameters (i.e. range and origin) to define a rectangular raster scan area, or generated externally by the user and then loaded directly via array format.
	The rectangular raster scan pattern generated by the library consists of linear ramp functions (sawtooth wave with 100% duty cycle) along the X and Y scan dimensions.  When scanning, the "fast" X voltage is updated for each clock pulse and the "slow" Y voltage is updated after each full period of the X waveform.

	HARDWARE SETUP:
	- requires NI USB-6211 (or 6211 OEM) hardware
	- requires installation of NI-DAQmx device driver software (http://sine.ni.com/nips/cds/view/p/lang/en/nid/10181)
	- requires that only one DAQmx device is connected
	- requires A-line sweep trigger to be input on PFI0 if used as the analog output generation sample clock
	- provides Image_sync pulse output on PFI5

	AVAILABLE SCANNER COMMANDS:
	- axScanCmd(<STRONG>init_scan</STRONG>, misc_scalar, ...) Initialize hardware and allocate scanner control resources.
	
		This command must be called after connecting the hardware via USB (verify successful connection with NI MAX control panel if necessary) but prior to calling any other axScanCmd command. The misc_scalar parameter sets the maximum voltage limits (up to 10V) for analog output waveforms (+/-, symmetric around 0V).  This feature guards against unintentional over-driving of connected scanners; subsequent commands to start scanning will return an error if the programmed scan pattern exceeds the configured voltage limit.

	- axScanCmd(<STRONG>destroy_scan</STRONG>, ...) Destroy and deallocate scanner control resources.
	
		Resources previously allocated with axScanCmd(init_scan, ...) are automatically deallocated by axStopSession() when terminating a main Axsun OCT Capture session.  Call this command to explicitly deallocate scanner resources if a main Capture session was not used. 

	- axScanCmd(<STRONG>set_rect_pattern</STRONG>, ..., scan_parameters, ...) Use scan_parameters to configure a rectangular raster scan pattern.

		The basic geometry defined in the scan_parameters structure is used to generate the active 1D (line) and 2D (raster) scan patterns for subsequent analog output generation, overwriting active scan patterns previously generated with this command or loaded with axScanCmd(load_ext_pattern,...).  Contents of the scan_parameters structure are copied internally and the pointer to this structure need not remain valid following return from this command.

	- axScanCmd(<STRONG>load_ext_pattern</STRONG>, ..., external_scan_pattern, ...) Use external_scan_pattern to load an externally generated scan pattern.

		An arbitrary user-generated scan pattern can be loaded for subsequent analog output generation, overwriting active scan patterns previously loaded with this command or generated with axScanCmd(set_rect_pattern,...).  Contents of the external_scan_pattern structure and associated arrays are copied internally and the pointer to this structure and its associated arrays need not remain valid following return from this command.  

	- axScanCmd(<STRONG>continuous_line_scan</STRONG>, ...) Start continuous line scanning based on configured scan pattern.

		Starts the analog output generation for the active 1D linear scan, repeating it continuously until commanded otherwise. The Image_sync pulse frequency is derived from the X_increment configured when the active scan pattern was set or loaded.

	- axScanCmd(<STRONG>continuous_raster_scan</STRONG>, ...) Start continuous raster scanning based on configured scan pattern. 

		Starts the analog output generation for the active 2D raster scan, repeating it continuously until commanded otherwise. The Image_sync pulse frequency is derived from the X_increment configured when the active scan pattern was set or loaded..

	- axScanCmd(<STRONG>stop_at_position</STRONG>, ..., scan_parameters, ...) Move to a configured position and stop scanning.

		Stops the Image_sync pulse and sets a constant (non-scanning) analog output at the voltages given in the X_shift and Y_shift fields of the scan_parameters argument. This command does not alter or overwrite the active scan parameters or patterns previously configured using axScanCmd(set_rect_pattern,...).  

	- axScanCmd(<STRONG>setup_burst_raster</STRONG>, ...) Prepare a burst raster scan by pre-loading buffers and waiting at the start position.
	
		Uploads the active raster scan pattern to device memory and sets a constant analog output at the pattern's initial voltage, but waits to start scanning until a subsequent call to axScanCmd(start_burst_raster,...).

	- axScanCmd(<STRONG>start_burst_raster</STRONG>, ...) Start a burst raster scan with minimum latency.

		Starts analog output and Image_sync pulse generation for a burst raster scan.  Must be preceded by a call to axScanCmd(setup_burst_raster,...). The raster scan starts with minimal latency and is executed once.

	- axScanCmd(<STRONG>wait_burst</STRONG>, misc_scalar, ...) Wait for a burst raster scan to complete.

		Waits for a burst raster scan operation to compete. The misc_scalar parameter sets the timeout (in seconds) to wait before returning an error. A timeout of -1 waits indefinitely, a timeout of 0 returns immediately with an error if the raster scan is still active or no error if it is complete.

	- axScanCmd(<STRONG>set_sample_clock</STRONG>, misc_scalar, ...) Changes between external and internal sample clock.

		The misc_scalar parameter sets the desired sample clock for subsequent analog output generation. The default value of 0 uses the external sample clock (connected to pin PFI0), a non-zero value uses a 100kHz sample clock generated internally by the device. Active scanning operations must be restarted for changes to take effect.

	*/
	EXPORT int32_t axScanCmd(scan_cmd_t scan_command, double misc_scalar, scan_params_t * scan_parameters, ext_pattern_t * external_scan_pattern, void * RFU);

#ifdef __cplusplus
}
#endif

#endif  // AXSUNOCTCAPTURE_H include guard