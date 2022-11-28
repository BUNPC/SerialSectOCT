#include "RenderingLibrary.h"

#ifdef __cplusplus
extern "C" {
#endif
    #include <SpectralRadar.h>

	typedef enum {
		RendererNoError = 0x00000000,
		RendererError = 0xE0000000
	} RendererErrorCode;

	typedef enum {
		MedianFilter_None = 0,
		MedianFilter_3 = 1,
		MedianFilter_5 = 2
	} MedianFilterType;

	RENDERINGLIBRARY_API RendererErrorCode getRendererError(char* Message, int StringSize);

    struct C_LiveVolumeRendering;
    typedef C_LiveVolumeRendering* LiveVolumeRenderingHandle;

    struct C_LiveDataSource;
    typedef C_LiveDataSource* LiveDataSourceHandle;

	struct C_VolumeRenderer;
	typedef C_VolumeRenderer* VolumeRendererHandle; 

	struct C_OfflineVolumeRendering;
	typedef C_OfflineVolumeRendering* OfflineVolumeRenderingHandle;

	struct C_DisplayRendering;
	typedef C_DisplayRendering* DisplayRenderingHandle;

	typedef enum C_RenderingMode {
		RenderingMode_Volume,
		RenderingMode_Sectional
	} RenderingMode;

	typedef enum C_VolumeMode {
		VolumeMode_Default,
		VolumeMode_MIP,
		VolumeMode_Mean
	} VolumeMode;

	RENDERINGLIBRARY_API VolumeRendererHandle createVolumeRenderer(void);
	RENDERINGLIBRARY_API void deleteVolumeRenderer(VolumeRendererHandle VR);

	RENDERINGLIBRARY_API void initializeVolumeRenderer(VolumeRendererHandle Renderer);
	RENDERINGLIBRARY_API void uninitializeVolumeRenderer(VolumeRendererHandle Renderer);

    RENDERINGLIBRARY_API void setAngles(VolumeRendererHandle Renderer, double AngleX, double AngleY);
	RENDERINGLIBRARY_API void setTranslation(VolumeRendererHandle Renderer, double TransX, double TransY, double TransZ);
    RENDERINGLIBRARY_API void setZoom(VolumeRendererHandle Renderer, double Zoom);
	

    RENDERINGLIBRARY_API void setViewportSize(int SizeX, int SizeY);
    RENDERINGLIBRARY_API void setRenderingSlices(VolumeRendererHandle Renderer, int Slices);
	RENDERINGLIBRARY_API void setLateralVoxelsPerPixel(VolumeRendererHandle Renderer, double VPP);
	RENDERINGLIBRARY_API void setRendererColoringBoundaries(VolumeRendererHandle Renderer, double Lower, double Upper);
	RENDERINGLIBRARY_API void setRendererColormap(VolumeRendererHandle Renderer, unsigned int* Colormap, int Size);
	RENDERINGLIBRARY_API void setSurfaceColormap(VolumeRendererHandle Renderer, unsigned int* Colormap, int Size);
	RENDERINGLIBRARY_API void setSectionalView(VolumeRendererHandle Renderer, BOOL ShowZ, float PosZ, BOOL ShowX, float PosX, BOOL ShowY, float PosY);
	RENDERINGLIBRARY_API void setClipPlane(VolumeRendererHandle Renderer, BOOL Show, BOOL Opaque, float Depth);
	RENDERINGLIBRARY_API void fixClipPlane(VolumeRendererHandle Renderer, BOOL Fix);
	RENDERINGLIBRARY_API void setBorder(VolumeRendererHandle Renderer, BOOL ShowScale, BOOL ShowBox, BOOL ShowText);
	RENDERINGLIBRARY_API void setRenderingMode(VolumeRendererHandle Renderer, RenderingMode Mode);
	RENDERINGLIBRARY_API void setVolumeMode(VolumeRendererHandle Renderer, VolumeMode Mode);
	RENDERINGLIBRARY_API void setRenderElements(VolumeRendererHandle Renderer, BOOL RenderVolume, BOOL RenderSurface);
	RENDERINGLIBRARY_API void setSurface(VolumeRendererHandle Renderer, int SizeX, int SizeY, double RangeZ, float* SurfaceData);
	RENDERINGLIBRARY_API void setSurfaceDepths(VolumeRendererHandle Renderer, double LowerDepth, double UpperDepth);
	RENDERINGLIBRARY_API void setRange(VolumeRendererHandle Renderer, double RangeZ, double RangeX, double RangeY);
	RENDERINGLIBRARY_API void setRenderBackground(VolumeRendererHandle Renderer, unsigned int top, unsigned int bottom);
	RENDERINGLIBRARY_API void clearVolumeRenderer(VolumeRendererHandle Renderer);

	// Live Rendering

	RENDERINGLIBRARY_API LiveVolumeRenderingHandle createLiveRendering(void);
    RENDERINGLIBRARY_API void clearLiveRendering(LiveVolumeRenderingHandle Render);  
	RENDERINGLIBRARY_API void setLiveVolumeRenderingRenderer(LiveVolumeRenderingHandle Rendering, VolumeRendererHandle Renderer);
	RENDERINGLIBRARY_API void renderLiveVolume(LiveVolumeRenderingHandle Renderer);
	RENDERINGLIBRARY_API void getLiveVolumeRenderingSize(LiveVolumeRenderingHandle DataSource, int* SizeZ, int* SizeX, int*SizeY);

	RENDERINGLIBRARY_API void setSizeZ(LiveDataSourceHandle DataSource, int SizeZ);
	RENDERINGLIBRARY_API double getRenderedVolumesPerSec(LiveVolumeRenderingHandle Renderer);
	RENDERINGLIBRARY_API BOOL isLiveVolumeRunning(LiveVolumeRenderingHandle Rendering);

	// Live Rendering data source
	RENDERINGLIBRARY_API LiveDataSourceHandle createOnlineDataSource(OCTDeviceHandle Dev, ProcessingHandle Proc);
    RENDERINGLIBRARY_API void clearDataSource(LiveDataSourceHandle DataSource);

    RENDERINGLIBRARY_API void startDataSource(LiveVolumeRenderingHandle Renderer, LiveDataSourceHandle DataSource, ScanPatternHandle Pattern);
    RENDERINGLIBRARY_API void stopDataSource(LiveDataSourceHandle DataSource);

	// Offline Rendering
	RENDERINGLIBRARY_API OfflineVolumeRenderingHandle createOfflineRendering(void);
	RENDERINGLIBRARY_API void clearOfflineRendering(OfflineVolumeRenderingHandle Rendering);
	RENDERINGLIBRARY_API void setOfflineRenderingRenderer(OfflineVolumeRenderingHandle Rendering, VolumeRendererHandle Renderer);
	RENDERINGLIBRARY_API void renderOfflineVolume(OfflineVolumeRenderingHandle Rendering);
	RENDERINGLIBRARY_API void allocateOfflineVolume(OfflineVolumeRenderingHandle Rendering, int SizeZ, int SizeX, int SizeY);
	RENDERINGLIBRARY_API void setOfflineAspectRatio(OfflineVolumeRenderingHandle Rendering, float RangeZ, float RangeX, float RangeY);
	RENDERINGLIBRARY_API void uploadOfflineVolume(OfflineVolumeRenderingHandle Rendering, float* Ptr);
	RENDERINGLIBRARY_API void uploadOfflineVolumeSlice(OfflineVolumeRenderingHandle Rendering, int SliceY, float* Ptr);


	// Display Rendering
	RENDERINGLIBRARY_API DisplayRenderingHandle createDisplayRendering(void);
	RENDERINGLIBRARY_API void clearDisplayRendering(DisplayRenderingHandle Rendering);
	RENDERINGLIBRARY_API void initDisplayRendering(DisplayRenderingHandle Rendering);
	RENDERINGLIBRARY_API void uninitDisplayRendering(DisplayRenderingHandle Rendering);

	RENDERINGLIBRARY_API void renderDisplay(DisplayRenderingHandle Rendering);
	RENDERINGLIBRARY_API void setDisplayData(DisplayRenderingHandle Rendering, int SizeX, int SizeY, float* Data);
	RENDERINGLIBRARY_API void clearDisplayData(DisplayRenderingHandle Rendering);
	RENDERINGLIBRARY_API void setDisplayColormap(DisplayRenderingHandle Renderer, unsigned int* Colormap, int Size);
	RENDERINGLIBRARY_API void setDisplayColoringBoundaries(DisplayRenderingHandle Renderer, double Lower, double Upper);
	RENDERINGLIBRARY_API void setGammaCorrection(DisplayRenderingHandle Renderer, double Gamma);

	RENDERINGLIBRARY_API void setDisplayBlur(DisplayRenderingHandle Renderer, BOOL ImageBlur, BOOL OverlayBlur);
	RENDERINGLIBRARY_API void setDisplayPepperFilter(DisplayRenderingHandle Renderer, BOOL PepperFilter);
	RENDERINGLIBRARY_API void setDisplayMedianFilter(DisplayRenderingHandle Renderer, MedianFilterType MedianFilter);
	RENDERINGLIBRARY_API void setDisplayFlip(DisplayRenderingHandle Renderer, BOOL Flip);

	RENDERINGLIBRARY_API void setNumberOverlays(DisplayRenderingHandle Rendering, int N);
	RENDERINGLIBRARY_API void setDisplayOverlayData(DisplayRenderingHandle Rendering, int SizeX, int SizeY, float* Data);
	RENDERINGLIBRARY_API void setDisplayOverlayColormap(DisplayRenderingHandle Renderer, int Index,  unsigned int* Colormap, int Size);
	RENDERINGLIBRARY_API void setDisplayOveralyColoringBoundaries(DisplayRenderingHandle Renderer, int Index, double Lower, double Upper);
	RENDERINGLIBRARY_API void setDisplayOveralyThreshold(DisplayRenderingHandle Renderer, double Threshold);
	

#ifdef __cplusplus
}
#endif
