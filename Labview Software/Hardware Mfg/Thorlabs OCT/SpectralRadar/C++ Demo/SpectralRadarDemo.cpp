// SpectralRadarDemo.cpp : Definiert den Einstiegspunkt für die Konsolenanwendung.
//
#define _USE_MATH_DEFINES
#include <cmath>
#include <iostream>
#include <ctime>
#include <sstream>
#include <string>
#include <fstream>
#include <algorithm>
#include <functional>
#include <cassert>
#include <chrono>
#include <vector>

using namespace std;


#define NOMINMAX
#define WIN32_LEAN_AND_MEAN
#include <conio.h>
#include <windows.h>
#include <SpectralRadar.h>


class Timer {
public:
    void start() {
        start_count = clock();
    }
    double get_seconds() {
        return static_cast<double>(clock() - start_count)/CLOCKS_PER_SEC;
    }
private:
    clock_t start_count;
};

void ContinuousBScanMeasurement(bool rotate)
{
	char message[1024];

	OCTDeviceHandle Dev = initDevice();

	if(getError(message, 1024))
	{
		cout << "ERROR: " << message << endl;
		_getch();
		return;
	}

	ProbeHandle Probe = initProbe(Dev, "Probe");
    ProcessingHandle Proc = createProcessingForDevice(Dev);

    setProcessingParameterInt(Proc, Processing_AScanAveraging, 1);
    setProcessingParameterInt(Proc, Processing_SpectrumAveraging, 1);
	setProcessingParameterInt(Proc, Processing_BScanAveraging, 1);
    setProbeParameterInt(Probe, Probe_Oversampling, 1);

	// setApodizationWindow(Proc, );

	const int N = 1024;
    ScanPatternHandle Pattern = createBScanPattern(Probe, 2.0, N, TRUE);
	if (rotate)
		rotateScanPattern(Pattern, 45.0 * 3.14159265/180);
	if(getError(message, 512))
	{
		cout << "ERROR: " << message << endl;
		_getch();
		return;
	}

	setCameraPreset(Dev, Probe, Proc, 0);
   
    RawDataHandle Raw = createRawData();
    DataHandle BScan = createData();
    ColoredDataHandle ColoredBScan = createColoredData();
    ComplexDataHandle ComplexBScan = createComplexData();

    Coloring32BitHandle Coloring = createColoring32Bit(ColorScheme_BlackAndWhite, Coloring_RGBA);

    setColoringBoundaries(Coloring, 0.0f, 70.0f);
    startMeasurement(Dev, Pattern, Acquisition_AsyncContinuous);
	if(getError(message, 512))
	{
		cout << "ERROR: " << message << endl;
		_getch();
		return;
	}

	Timer t;
	t.start();

	Timer t_proc;
	Timer t_get;
	double proc_secs = 0.0;
	double get_secs = 0.0;
    while(!_kbhit())
    {
		static int i = 1; 
		static clock_t counter = clock();

		t_get.start();
        getRawData(Dev, Raw);
		get_secs = t_get.get_seconds();

		t_proc.start();

		setProcessedDataOutput(Proc, BScan);

        executeProcessing(Proc, Raw);
		proc_secs = t_proc.get_seconds();

		if(i % 10 == 4) {
		 	cout << "Tot Speed: " << static_cast<double>(i*N)/t.get_seconds() << " A-scans per sec. " << endl;
			cout << "Getting: " << static_cast<double>(N)/get_secs << " A-scans per sec. " << endl;
			cout << "Processing: " << static_cast<double>(N)/proc_secs << " A-scans per sec. " << endl;
		}

		if(getError(message, 512))
		{
			cout << "ERROR: " << message << endl;
			stopMeasurement(Dev);
			closeDevice(Dev);
			_getch();
			return;
		}

		++i;
    }
	_getch();
    stopMeasurement(Dev);
    clearRawData(Raw);
    clearData(BScan);

    clearScanPattern(Pattern);
    closeProbe(Probe);
	closeProcessing(Proc);
    closeDevice(Dev);

	_getch();
}


void ColoringDemo()
{
	char message[1024];

	OCTDeviceHandle Dev = initDevice();

	if(getError(message, 1024))
	{
		cout << "ERROR: " << message << endl;
		_getch();
		return;
	}

	ProbeHandle Probe = initProbe(Dev, "Probe");
    ProcessingHandle Proc = createProcessingForDevice(Dev);

    setProcessingParameterInt(Proc, Processing_AScanAveraging, 1);
    setProcessingParameterInt(Proc, Processing_SpectrumAveraging, 1);
    setProbeParameterInt(Probe, Probe_Oversampling, 1);

	const int N = 2048;
    ScanPatternHandle Pattern = createBScanPattern(Probe, 2.0, N, TRUE);
	
	if(getError(message, 512))
	{
		cout << "ERROR: " << message << endl;
		_getch();
		return;
	}

	setCameraPreset(Dev, Probe, Proc, Device_CameraPreset_3);
   
    RawDataHandle Raw = createRawData();
    DataHandle BScan = createData();
    ColoredDataHandle ColoredBScan = createColoredData();
    ComplexDataHandle ComplexBScan = createComplexData();

    Coloring32BitHandle Coloring = createColoring32Bit(ColorScheme_BlackAndWhite, Coloring_RGBA);

    setColoringBoundaries(Coloring, 0.0f, 70.0f);
    startMeasurement(Dev, Pattern, Acquisition_AsyncContinuous);
	if(getError(message, 512))
	{
		cout << "ERROR: " << message << endl;
		_getch();
		return;
	}

	Timer t;
	t.start();

	Timer t_proc;
	Timer t_get;
	double proc_secs = 0.0;
	double get_secs = 0.0;
    while(!_kbhit())
    {
		static int i = 1; 
		static clock_t counter = clock();

		t_get.start();
        getRawData(Dev, Raw);
		get_secs = t_get.get_seconds();

		t_proc.start();

		setProcessedDataOutput(Proc, BScan);
        executeProcessing(Proc, Raw);

		colorizeData(Coloring, BScan, ColoredBScan, FALSE);

		proc_secs = t_proc.get_seconds();

		if(i % 10 == 4) {
		 	cout << "Tot Speed: " << static_cast<double>(i*N)/t.get_seconds() << " A-scans per sec. " << endl;
			cout << "Getting: " << static_cast<double>(N)/get_secs << " A-scans per sec. " << endl;
			cout << "Processing: " << static_cast<double>(N)/proc_secs << " A-scans per sec. " << endl;
		}

		if(getError(message, 512))
		{
			cout << "ERROR: " << message << endl;
			_getch();
			return;
		}

		++i;
    }
    stopMeasurement(Dev);
    clearRawData(Raw);
    clearData(BScan);
    clearScanPattern(Pattern);

    closeProbe(Probe);
    closeDevice(Dev);
	closeProcessing(Proc);

	_getch();
}

void ContinuousBilateralBScanMeasurement()
{
	char message[1024];

	OCTDeviceHandle Dev = initDevice();

	if(getError(message, 1024))
	{
		cout << "ERROR: " << message << endl;
		_getch();
		return;
	}

    ProbeHandle Probe = initProbe(Dev, "Probe");
    ProcessingHandle Proc = createProcessingForDevice(Dev);

    /* setProcessingParameterInt(Proc, Processing_AScanAveraging, 1);
    setProcessingParameterInt(Proc, Processing_SpectrumAveraging, 1); */
	// setProcessingParameterInt(Proc, Processing_BScanAveraging, 1);
    /* setProbeParameterInt(Probe, Probe_Oversampling, 1); */

	const int N = 512;
    ScanPatternHandle Pattern = createBilateralBScanPattern(Probe, 2.0, N, 1.0);
	
	if(getError(message, 512))
	{
		cout << "ERROR: " << message << endl;
		_getch();
		return;
	}
   
    RawDataHandle Raw = createRawData();
    DataHandle BScan = createData();

    startMeasurement(Dev, Pattern, Acquisition_AsyncContinuous);
	if(getError(message, 512))
	{
		cout << "ERROR: " << message << endl;
		_getch();
		return;
	}

	Timer t;
	t.start();

	Timer t_proc;
	Timer t_get;
	double proc_secs = 0.0;
	double get_secs = 0.0;
    while(!_kbhit())
    {
		static int i = 1; 
		static clock_t counter = clock();

		t_get.start();
        getRawData(Dev, Raw);
		get_secs = t_get.get_seconds();

		t_proc.start();

		setProcessedDataOutput(Proc, BScan);
        executeProcessing(Proc, Raw);
		proc_secs = t_proc.get_seconds();

		if(i % 1 == 0) {
		 	cout << "Tot Speed: " << static_cast<double>(i*N)/t.get_seconds() << " A-scans per sec. " << endl;
			cout << "Getting: " << static_cast<double>(N)/get_secs << " A-scans per sec. " << endl;
			cout << "Processing: " << static_cast<double>(N)/proc_secs << " A-scans per sec. " << endl;
		}

		cout << "Size1 = " << getDataPropertyInt(BScan, Data_Size1) << endl;
		cout << "Size1 = " << getDataPropertyInt(BScan, Data_Size2) << endl;

		exportData2D(BScan, Data2DExport_RAW, "C:\\OCTData\\Bilateral.raw");
		
		if(getError(message, 512))
		{
			cout << "ERROR: " << message << endl;
			_getch();
			return;
		}

		++i;
    }
	_getch();
    stopMeasurement(Dev);
    clearRawData(Raw);
    clearData(BScan);
    clearScanPattern(Pattern);

    closeProbe(Probe);
    closeDevice(Dev);
	closeProcessing(Proc);

	_getch();
}

void ContinuousVolumeMeasurement()
{
    OCTDeviceHandle Dev = initDevice();
    char error[512];
    if(getError(error, 512))
    {
        cout << "Error: " << error << endl;
        _getch();
        return;
    }
    ProbeHandle Probe = initProbe(Dev, "Probe");
    ProcessingHandle Proc = createProcessingForDevice(Dev);

    ScanPatternHandle Pattern = createVolumePattern(Probe, 2.0, 64, 2.0, 32);

	if(getError(error, 512))
    {
        cout << "Error: " << error << endl;
        _getch();
        return;
    }
   
    RawDataHandle Raw = createRawData();
    DataHandle BScan = createData();
    ColoredDataHandle ColoredBScan = createColoredData();
    ComplexDataHandle ComplexBScan = createComplexData();

    // Coloring32BitHandle Color = createColoring32Bit(ColorScheme_BlackAndWhite, Coloring_RGBA);
	Coloring32BitHandle Color = createColoring32Bit(ColorScheme_Inverted, Coloring_RGBA);

    setColoringBoundaries(Color, 0.0f, 70.0f);
    startMeasurement(Dev, Pattern, Acquisition_AsyncContinuous);

    while(!_kbhit())
    {
        getRawData(Dev, Raw);
        cout << "Raw image with size ";

        int SizeX, SizeY, SizeZ;
        getRawDataSize(Raw, &SizeX, &SizeY, &SizeZ);
        cout << SizeX << " x " << SizeY << " x " << SizeZ << endl;
        cout << " acquired. " << endl;

        setProcessedDataOutput(Proc, BScan);

		SizeZ = getDataPropertyInt(BScan, Data_Size1);
		SizeX = getDataPropertyInt(BScan, Data_Size2);
		SizeY = getDataPropertyInt(BScan, Data_Size3);
		cout << "Processed Volume: " << SizeX << " x " << SizeY << " x " << SizeZ << endl;
        
        // setComplexDataOutput(Proc, ComplexBScan);
        // setColoredDataOutput(Proc, ColoredBScan, Color); 
        
        executeProcessing(Proc, Raw); 
        
        char error[512];
        if(getError(error, 512))
        {
            cerr << "ERROR: \n";
            cerr << error << '\n';
            _getch();
        }
    }
    stopMeasurement(Dev);
	clearScanPattern(Pattern);

	_getch();

	Pattern = createVolumePattern(Probe, 2.0, 128, 2.0, 64);
    startMeasurement(Dev, Pattern, Acquisition_AsyncContinuous);
    while(!_kbhit())
    {
        getRawData(Dev, Raw);
        cout << "Raw image with size ";

        int SizeX, SizeY, SizeZ;
        getRawDataSize(Raw, &SizeX, &SizeY, &SizeZ);
        cout << SizeX << " x " << SizeY << " x " << SizeZ << endl;
        cout << " acquired. " << endl;

        setProcessedDataOutput(Proc, BScan);
        // setComplexDataOutput(Proc, ComplexBScan);
        // setColoredDataOutput(Proc, ColoredBScan, Color); 
        
        executeProcessing(Proc, Raw);
        
        char error[512];
        if(getError(error, 512))
        {
            cerr << "ERROR: \n";
            cerr << error << '\n';
            _getch();
        }
    }
    stopMeasurement(Dev);
	clearScanPattern(Pattern);

    clearRawData(Raw);
    clearData(BScan);
    
    closeProbe(Probe);
    closeDevice(Dev);
}


void SyncAcquisition()
{
    OCTDeviceHandle Dev = initDevice();
    ProbeHandle Probe = initProbe(Dev, "Probe");
    ProcessingHandle Proc = createProcessingForDevice(Dev);

    ScanPatternHandle Pattern = createBScanPattern(Probe, 2.0, 2048, TRUE);
   
    RawDataHandle Raw = createRawData();
    DataHandle BScan = createData();
    ColoredDataHandle ColoredBScan = createColoredData();
    ComplexDataHandle ComplexBScan = createComplexData();

    Coloring32BitHandle Color = createColoring32Bit(ColorScheme_BlackAndWhite, Coloring_RGBA);

    setColoringBoundaries(Color, 0.0f, 70.0f);
    startMeasurement(Dev, Pattern, Acquisition_Sync);

    while(!_kbhit())
    {
        getRawData(Dev, Raw);

        int SizeX, SizeY, SizeZ;
        getRawDataSize(Raw, &SizeX, &SizeY, &SizeZ);
        cout << SizeX << " x " << SizeY << " x " << SizeZ << endl;

        setProcessedDataOutput(Proc, BScan);
              
        executeProcessing(Proc, Raw);
        cout << "Raw image acquired..." << endl;
            
        exportData2DAsImage(BScan, Color, ColoredDataExport_BMP, "C:\\test.bmp", FALSE, FALSE, TRUE); 

        char error[512];
        if(getError(error, 512))
        {
            cerr << "ERROR: \n";
            cerr << error << '\n';
            _getch();
        }
    }
    stopMeasurement(Dev);

    clearRawData(Raw);
    clearData(BScan);
    clearScanPattern(Pattern);
    closeProbe(Probe);
    closeDevice(Dev);
}

void AScanMeasurement()
{
    OCTDeviceHandle Dev = initDevice();
	
    RawDataHandle Raw = createRawData();
    ProcessingHandle Proc = createProcessingForDevice(Dev);

    DataHandle Spectrum = createData();
    DataHandle OffsetSpectrum = createData();
    DataHandle ApoSpectrum = createData();
    DataHandle AScan = createData();
	ComplexDataHandle ComplexAScan = createComplexData();

    const int Averaging = 50;
    const int Binning = 1;
	const int N = 1;

    setProcessingParameterInt(Proc, Processing_SpectrumAveraging, Binning);
    setProcessingParameterInt(Proc, Processing_AScanAveraging, Averaging);
	setProcessingFlag(Proc, Processing_UseApodization, TRUE);
	setProcessingFlag(Proc, Processing_RemoveAdvancedDCSpectrum, TRUE);
	setProcessingFlag(Proc, Processing_RemoveDCSpectrum, TRUE);

    while(!_kbhit())
    {
        DataHandle Spectrum = createData();
        DataHandle OffsetSpectrum = createData();
        DataHandle ApoSpectrum = createData();
        DataHandle AScan = createData();

        measureSpectra(Dev, Averaging*Binning*N, Raw);
		char error[512];
        if(getError(error, 512))
        {
            cerr << "ERROR: \n";
            cerr << error << '\n';
			continue;
        }
		
        setSpectrumOutput(Proc, Spectrum);
        setOffsetCorrectedSpectrumOutput(Proc, OffsetSpectrum);
        setApodizedSpectrumOutput(Proc, ApoSpectrum);
        setProcessedDataOutput(Proc, AScan);
		setComplexDataOutput(Proc, ComplexAScan);
        executeProcessing(Proc, Raw);

		computeLinearKRawData(ComplexAScan, OffsetSpectrum);
		exportData1D(OffsetSpectrum, Data1DExport_RAW, "C:\\Spectrum.raw");

        DataHandle Contrast = createData();
        calcContrast(ApoSpectrum, Contrast);

		// do something with the data...
		// ....
		
        clearData(Contrast);

        clearData(AScan);
        clearData(Spectrum);
        clearData(ApoSpectrum);
        clearData(OffsetSpectrum);
    }

    closeProcessing(Proc);

    clearRawData(Raw);
    closeDevice(Dev);
}


void FiniteStackMeasurement()
{
	char message[512];


    OCTDeviceHandle Dev = initDevice();

	if (getError(message, 512))
	{
		cerr << "\n\n" << message << endl;
		_getch();
		return;
	}
	
	const int size_z = getDevicePropertyInt(Dev, DevicePropertyInt::Device_SpectrumElements) / 2;
	const int size_x = 400;
	const int size_y = 400;
	const int oversampling_y = 1;

    ProbeHandle Probe = initProbe(Dev, "Probe");
    ProcessingHandle Proc = createProcessingForDevice(Dev);
	
	setProbeParameterInt(Probe, Probe_Oversampling, 1);
	setProcessingParameterInt(Proc, Processing_SpectrumAveraging, 1);
	setProbeParameterInt(Probe, Probe_Oversampling_SlowAxis, oversampling_y);
    ScanPatternHandle Pattern = createBScanStackPattern(Probe, 5.0, size_x, 5.0, size_y);

    DataHandle BScan = createData();
    RawDataHandle Raw = createRawData();
	DataHandle Volume = createData();
	reserveData(Volume, size_z, size_x, size_y);
	Coloring32BitHandle coloring = createColoring32Bit(ColorScheme_BlackAndWhite, Coloring_BGRA);
   
	ofstream data("C:\\volume.raw", ios::binary);
    startMeasurement(Dev, Pattern, Acquisition_AsyncFinite);
    for(int i = 0; i < size_y*oversampling_y; ++i)
    {
        getRawData(Dev, Raw);
        setProcessedDataOutput(Proc, BScan);
        executeProcessing(Proc, Raw);

        cout << "BScan Size: " << getDataPropertyFloat(BScan, Data_Range1) << " x " << getDataPropertyFloat(BScan, Data_Range2) << endl;

		data.write(reinterpret_cast<char*>(getDataPtr(BScan)), sizeof(float)*size_x*512*1);
         appendData(Volume, BScan, Direction_3);
         cout << "Current volume size: " << getDataPropertyInt(Volume, Data_Size1) << " x " << getDataPropertyInt(Volume, Data_Size2) << " x " << getDataPropertyInt(Volume, Data_Size3) << endl;

		if(getError(message, 512))
		{
			cerr << "\n\nAn error occurred: " << message << endl; 
			_getch();
		}
    } 
	exportData3DAsImage(Volume, coloring, ColoredDataExport_TIFF, Direction::Direction_2, "D:\\FiniteStack.tiff", true, true, true);
	data.close();
    // cout << "FINAL DATA: " << endl;
    // cout << "Current volume size: " << getDataPropertyInt(Volume, Data_Size1) << " x " << getDataPropertyInt(Volume, Data_Size2) << " x " << getDataPropertyInt(Volume, Data_Size3) << endl;
    // cout << "Current volume size (physical): " << getDataPropertyFloat(Volume, Data_Range1) << " x " << getDataPropertyFloat(Volume, Data_Range2) << " x " << getDataPropertyFloat(Volume, Data_Range3) << endl;
    
    /* getDataSlicePos(Volume, BScan, Direction_1, 0.1);
    getDataSlicePos(Volume, BScan, Direction_2, 1.0);
    getDataSlicePos(Volume, BScan, Direction_3, 1.0);

    getDataSliceIndex(Volume, BScan, Direction_1, getDataPropertyInt(Volume, Data_Size1)-1);
    getDataSliceIndex(Volume, BScan, Direction_2, getDataPropertyInt(Volume, Data_Size2)-1);
    getDataSliceIndex(Volume, BScan, Direction_3, getDataPropertyInt(Volume, Data_Size3)-1);
    cout << "100% " << endl; */

    stopMeasurement(Dev);

    clearRawData(Raw);
    clearData(BScan);
	clearData(Volume);
    clearScanPattern(Pattern);

    _getch();
	if(getError(message, 512))
	{
		cerr << "\n\nAn error occurred: " << message << endl; 
		_getch();
	}
	/* 
	Pattern = createBScanStackPattern(Probe, 2.0, size_x, 2.0, size_y);

	if(!checkAvailableMemoryForScanPattern(Dev, Pattern, -size_x*size_y*512*sizeof(float)))
	{
		_getch();
		return;
	}
	
    BScan = createData();
    Volume = createData();
    Raw = createRawData();

	reserveData(Volume, 1024, size_x, size_y);
   
    startMeasurement(Dev, Pattern, Acquisition_AsyncFinite);
    for(int i = 0; i < size_y; ++i)
    {
        getRawData(Dev, Raw);
        setProcessedDataOutput(Proc, BScan);
        executeProcessing(Proc, Raw);

        cout << "BScan Size: " << getDataPropertyFloat(BScan, Data_Range1) << " x " << getDataPropertyFloat(BScan, Data_Range2) << endl;

        appendData(Volume, BScan, Direction_3);
        cout << "Current volume size: " << getDataPropertyInt(Volume, Data_Size1) << " x " << getDataPropertyInt(Volume, Data_Size2) << " x " << getDataPropertyInt(Volume, Data_Size3) << endl;

		if(getError(message, 512))
		{
			cerr << "\n\nAn error occurred: " << message << endl; 
			_getch();
		}
    }  
    cout << "FINAL DATA: " << endl;
    cout << "Current volume size: " << getDataPropertyInt(Volume, Data_Size1) << " x " << getDataPropertyInt(Volume, Data_Size2) << " x " << getDataPropertyInt(Volume, Data_Size3) << endl;
    cout << "Current volume size (physical): " << getDataPropertyFloat(Volume, Data_Range1) << " x " << getDataPropertyFloat(Volume, Data_Range2) << " x " << getDataPropertyFloat(Volume, Data_Range3) << endl;
    
    getDataSlicePos(Volume, BScan, Direction_1, 0.1);
    getDataSlicePos(Volume, BScan, Direction_2, 1.0);
    getDataSlicePos(Volume, BScan, Direction_3, 1.0);

    getDataSliceIndex(Volume, BScan, Direction_1, getDataPropertyInt(Volume, Data_Size1)-1);
    getDataSliceIndex(Volume, BScan, Direction_2, getDataPropertyInt(Volume, Data_Size2)-1);
    getDataSliceIndex(Volume, BScan, Direction_3, getDataPropertyInt(Volume, Data_Size3)-1);
    cout << "100% " << endl;

    stopMeasurement(Dev);

    clearRawData(Raw);
    clearData(BScan);
	clearData(Volume);
    clearScanPattern(Pattern);

	if(getError(message, 512))
	{
		cerr << "\n\nAn error occurred: " << message << endl; 
		_getch();
	} */

	closeProbe(Probe);
    closeProcessing(Proc);
    closeDevice(Dev);
}

void LargeVolumeErrorHandling()
{
    OCTDeviceHandle Dev = initDevice();
    ProbeHandle Probe = initProbe(Dev, "Probe");
    ProcessingHandle Proc = createProcessingForDevice(Dev);
	
	setProbeParameterInt(Probe, Probe_Oversampling, 1);
	setProcessingParameterInt(Proc, Processing_SpectrumAveraging, 1);

	for(int x=400; x<2000; x+=100)
	{
		char error_text[1024];

		const int size_x = x;
		const int size_y = x;

		ScanPatternHandle Pattern = createBScanStackPattern(Probe, 2.0, size_x, 2.0, size_y);
		
		DataHandle BScan = createData();
		DataHandle Volume = createData();
		RawDataHandle Raw = createRawData();

		reserveData(Volume, 1024, size_x, size_y);
		if(getError(error_text, 1024))
		{
			cout << error_text << endl;
			_getch();
		}	   
		startMeasurement(Dev, Pattern, Acquisition_AsyncFinite);
		if(getError(error_text, 1024))
		{
			cout << error_text << endl;
			_getch();
		} else {
			for(int i = 0; i < size_y; ++i)
			{
				getRawData(Dev, Raw);
				setProcessedDataOutput(Proc, BScan);
				executeProcessing(Proc, Raw);
				if(getError(error_text, 1024))
				{
					cout << size_x << "x" << size_y << ": " << error_text << endl;
					_getch();
					break;					
				}

				cout << "BScan Size: " << getDataPropertyFloat(BScan, Data_Range1) << " x " << getDataPropertyFloat(BScan, Data_Range2) << endl;

				appendData(Volume, BScan, Direction_3);
				cout << "Current volume size: " << getDataPropertyInt(Volume, Data_Size1) << " x " << getDataPropertyInt(Volume, Data_Size2) << " x " << getDataPropertyInt(Volume, Data_Size3) << endl;
			}  
		}
		stopMeasurement(Dev);
		if(getError(error_text, 1024))
		{
			cout << error_text << endl;
			_getch();
		}

		clearRawData(Raw);
		clearData(BScan);
		clearData(Volume);
		clearScanPattern(Pattern);
	}

    closeProbe(Probe);
    closeProcessing(Proc);
    closeDevice(Dev);

    _getch();
}

void AveragingAndBinning()
{
    OCTDeviceHandle Dev = initDevice();
    ProbeHandle Probe = initProbe(Dev, "Probe");
    ProcessingHandle Proc = createProcessingForDevice(Dev);

    setProbeParameterInt(Probe, Probe_Oversampling, 10);
    // setProcessingParameterInt(Proc, Processing_SpectrumAveraging, 10);
 	setProcessingParameterInt(Proc, Processing_AScanAveraging, 10);
	setProcessingParameterInt(Proc, Processing_BScanAveraging, 10);
	setProcessingAveragingAlgorithm(Proc, Processing_Averaging_Fourier_Max);

    ScanPatternHandle Pattern = createBScanPattern(Probe, 2.0, 150, TRUE);
   
    RawDataHandle Raw = createRawData();
    DataHandle BScan = createData();
    ColoredDataHandle ColBScan = createColoredData();

    Coloring32BitHandle Color = createColoring32Bit(ColorScheme_BlackAndWhite, Coloring_RGBA);
    setColoringBoundaries(Color, 0.0f, 70.0f);
        
    startMeasurement(Dev, Pattern, Acquisition_AsyncContinuous);

    while(!_kbhit())
    {
        getRawData(Dev, Raw);
        setProcessedDataOutput(Proc, BScan);
        setColoredDataOutput(Proc, ColBScan, Color);
        
        executeProcessing(Proc, Raw);
        
        double sp1 = getDataPropertyFloat(BScan, Data_Spacing1);
        cout << "Current Spacing 1: " << sp1 << endl;
       
        exportColoredData(ColBScan, ColoredDataExport_JPG, "D:\\test2.jpg");

        char error[512];
        if(getError(error, 512))
        {
            cerr << "ERROR: \n";
            cerr << error << '\n';
            _getch();
        }
    }
    stopMeasurement(Dev);

    clearRawData(Raw);
    clearData(BScan);
    clearScanPattern(Pattern);
    closeProbe(Probe);
    closeDevice(Dev);
}

void ContinuousDopplerMeasurement()
{
    OCTDeviceHandle Dev = initDevice();
    ProbeHandle Probe = initProbe(Dev, "Probe");
    ProcessingHandle Proc = createProcessingForDevice(Dev);
    ScanPatternHandle Pattern = createBScanPattern(Probe, 2.0, 512, TRUE);
    DopplerProcessingHandle Doppler = createDopplerProcessing();
   
    RawDataHandle Raw = createRawData();
    ComplexDataHandle ComplexBScan = createComplexData();

    DataHandle Amps = createData();
    DataHandle Phases = createData();

    startMeasurement(Dev, Pattern, Acquisition_AsyncContinuous);

	bool start = true;
	while(!_kbhit())
    {
		getRawData(Dev, Raw);
		setComplexDataOutput(Proc, ComplexBScan);
       	executeProcessing(Proc, Raw);

       	setDopplerPhaseOutput(Doppler, Phases);
		setDopplerAmplitudeOutput(Doppler, Amps);

		setDopplerPropertyInt(Doppler, DopplerAveraging_1, 3);
		setDopplerPropertyInt(Doppler, DopplerAveraging_2, 3);

		executeDopplerProcessing(Doppler, ComplexBScan);

		// Repeat Doppler processing with different average number //
		setComplexDataOutput(Proc, ComplexBScan);
		executeProcessing(Proc, Raw);

		setDopplerPhaseOutput(Doppler, Phases);
		setDopplerAmplitudeOutput(Doppler, Amps);

		setDopplerPropertyInt(Doppler, DopplerAveraging_1, 2);
		setDopplerPropertyInt(Doppler, DopplerAveraging_2, 2);

		executeDopplerProcessing(Doppler, ComplexBScan);

		if(start)
		{
			float min_dB, max_dB;
			determineDynamicRange(Amps, &min_dB, &max_dB);
			start = false;
		}
		     
		char error[512];
		if(getError(error, 512))
		{
			cerr << "ERROR: \n";
	        cerr << error << '\n';
	        _getch();
        }
    }

/* 
    while(!_kbhit())
    {
        getRawData(Dev, Raw);
        setComplexDataOutput(Proc, ComplexBScan);
        executeProcessing(Proc, Raw);

        setDopplerPhaseOutput(Doppler, Phases);
        setDopplerAmplitudeOutput(Doppler, Amps);

        executeDopplerProcessing(Doppler, ComplexBScan);
     
        char error[512];
        if(getError(error, 512))
        {
            cerr << "ERROR: \n";
            cerr << error << '\n';
            _getch();
        }
    } */
    stopMeasurement(Dev);

    clearRawData(Raw);
    clearComplexData(ComplexBScan);
    clearData(Amps);
    clearData(Phases);
    clearScanPattern(Pattern);
    closeProbe(Probe);
    closeDevice(Dev);
}

void ExportImportTest()
{
    OCTDeviceHandle Dev = initDevice();
    ProbeHandle Probe = initProbe(Dev, "Probe");
    ProcessingHandle Proc = createProcessingForDevice(Dev);

    ScanPatternHandle Pattern = createBScanPattern(Probe, 2.0, 1024, TRUE);
   
    RawDataHandle Raw = createRawData();
    DataHandle BScan = createData();
    DataHandle Import = createData();

    DataHandle Tmp = createData();
    getCalibration(Proc, Calibration_ApodizationVector, Tmp);
    exportData1D(Tmp, Data1DExport_TXT, "D:\\Apodization.txt");

    getCalibration(Proc, Calibration_OffsetErrors, Tmp);
    exportData1D(Tmp, Data1DExport_TXT, "D:\\OffsetErrors.txt");

    getCalibration(Proc, Calibration_Chirp, Tmp);
    exportData1D(Tmp, Data1DExport_TXT, "D:\\Chirp.txt");
    
    char error[512];
    if(getError(error, 512))
    {
        cerr << "ERROR: \n";
        cerr << error << '\n';
        _getch();
    }

    startMeasurement(Dev, Pattern, Acquisition_Sync);
    while(!_kbhit())
    {
        getRawData(Dev, Raw);

        exportRawData(Raw, RawDataExport_RAW, "D:\\InFocus.raw");

        char error[512];
        if(getError(error, 512))
        {
            cerr << "ERROR: \n";
            cerr << error << '\n';
            _getch();
        }

        setProcessedDataOutput(Proc, BScan);
        executeProcessing(Proc, Raw);
 
        exportData2D(BScan, Data2DExport_SRM, "D:\\test.srm");
        exportData2D(BScan, Data2DExport_RAW, "D:\\test.raw");

        importData(Import, DataImport_SRM, "D:\\test");

        cout << "Imported data of size " << getDataPropertyInt(Import, Data_Size1) << " x " << getDataPropertyInt(Import, Data_Size2) << " x " << getDataPropertyInt(Import, Data_Size3) << endl;
        cout << "Min: " << analyzeData(Import, Data_Min) << endl;
        cout << "Mean: " << analyzeData(Import, Data_Mean) << endl;
        cout << "Max: " << analyzeData(Import, Data_Max) << endl;

        //char error[512];
        if(getError(error, 512))
        {
            cerr << "ERROR: \n";
            cerr << error << '\n';
            _getch();
        }
    }
    stopMeasurement(Dev);

    clearRawData(Raw);
    clearData(Import);
    clearData(BScan);
    clearScanPattern(Pattern);
    closeProbe(Probe);
    closeDevice(Dev);
}

void RawData(void)
{
    OCTDeviceHandle Dev = initDevice();
    ProcessingHandle Proc = createProcessingForDevice(Dev);
    ProbeHandle Factory = initProbe(Dev, "Probe");
    ScanPatternHandle Pattern = createBScanPattern(Factory, 2.0, 512, TRUE);

    RawDataHandle Raw = createRawData();
    ComplexDataHandle CData = createComplexData();

    startMeasurement(Dev, Pattern, Acquisition_Sync);
    while(!_kbhit())
    {
        getRawData(Dev, Raw);
        setComplexDataOutput(Proc, CData);
        executeProcessing(Proc, Raw);

        exportComplexData(CData, ComplexDataExport_RAW, "D:\\complex_disp.raw");
        cout << "EXPORTED Data" << endl;
    }
    _getch();
    stopMeasurement(Dev);
    
    closeProcessing(Proc);
    closeDevice(Dev);
}

void OnOffTest()
{
    cout << "First opnening... \n";
    OCTDeviceHandle Dev = initDevice();
    closeDevice(Dev);
    cout << "Second opnening... \n";
    Dev = initDevice();
    closeDevice(Dev);

	char error[512];
	if(getError(error, 512))
	{
		cerr << "An error occurred: " << error << endl;
	}
    cout << "Done.\n";
    _getch();
}

void ManualScannerMove()
{
    OCTDeviceHandle Dev = initDevice();
    ProbeHandle Probe = initProbe(Dev, "Probe");

    cout << "FactorX = " << getProbeParameterFloat(Probe, Probe_FactorX) << endl;
    cout << "FactorY = " << getProbeParameterFloat(Probe, Probe_FactorY) << endl;
    cout << "OffsetX = " << getProbeParameterFloat(Probe, Probe_OffsetX) << endl;
    cout << "OffsetY = " << getProbeParameterFloat(Probe, Probe_OffsetY) << endl;

    moveScanner(Dev, Probe, ScanAxis_X, 1.0);
    moveScanner(Dev, Probe, ScanAxis_Y, 1.0);

    closeProbe(Probe);
    closeDevice(Dev);

    _getch();
}


void BufferTest()
{
    OCTDeviceHandle Dev = initDevice();
    ProbeHandle Probe = initProbe(Dev, "Probe");
    ProcessingHandle Proc = createProcessingForDevice(Dev);
    ScanPatternHandle Pattern = createBScanPattern(Probe, 2.0, 512, TRUE);
   
    RawDataHandle Raw = createRawData();
    

    BufferHandle Buffer = createMemoryBuffer();

    startMeasurement(Dev, Pattern, Acquisition_AsyncContinuous);

    while(!_kbhit())
    {
        DataHandle BScan = createData();        

        getRawData(Dev, Raw);
        setProcessedDataOutput(Proc, BScan);
        executeProcessing(Proc, Raw);

        appendToBuffer(Buffer, BScan, NULL);
    }
    stopMeasurement(Dev);

    clearBuffer(Buffer);
    clearRawData(Raw);
    clearScanPattern(Pattern);
    closeProbe(Probe);
    closeDevice(Dev);
}

void VideoCameraTest()
{
    OCTDeviceHandle Dev = initDevice();
	ProbeHandle prb = initProbe(Dev, "Probe.ini");

	if(Dev == 0)
	{
		cerr << "Device handle is invalid. " << endl;
		char message[512];
		getError(message, 512);
		cerr << message << endl;
		_getch();
		return;
	}

    ColoredDataHandle Image = createColoredData();
    while(!_kbhit())
    {
        cout << "Acquired image. " << endl;
        getCameraImage(Dev, 320, 200, Image);
        exportColoredData(Image, ColoredDataExport_JPG, "C:\\tmp\\Test.jpg");
    }
    clearColoredData(Image);
    closeDevice(Dev);

	char message[512];
	
	if(getError(message, 512))
	{
		cerr << "An error occurred: " << message << endl;
	}
	_getch();
	_getch();
}

void RingLightIntensityChangeTest(void)
{
    OCTDeviceHandle Dev = initDevice();

	if(Dev == 0)
	{
		cerr << "Device handle is invalid. " << endl;
		char message[512];
		getError(message, 512);
		cerr << message << endl;
		_getch();
		return;
	}
	cout << "Ring light intensity test" << endl;
	int outCount = getNumberOfOutputValues(Dev);
	if (outCount == 0) 
	{
		cout << "No output values available. Driver present?" << endl;
	} 
	else 
	{
		cout << "Output value count: " << getNumberOfOutputValues(Dev) << endl;
		for (int i=100;i>=10;i-=10) 
		{
			Sleep(1000);
			setOutputValueByName(Dev, "ring light", i);
			cout << "Set ring light intensity to " << i << ". " << endl;
		}
	}
	_getch();
}

void ADC_DAC_Test(void)
{
    OCTDeviceHandle Dev = initDevice();
	int count = getNumberOfInternalValues(Dev);
    cout << endl << "Number of internal values found: " << count << endl;
	char* name = (char*)malloc(512);
	char* unit = (char*)malloc(512);
	for (int i=0;i<count;++i)
	{
		getInternalValueName(Dev, i, name, 512, unit, 512);
		cout << "Name: " << name << ", Unit: " << unit << endl;
	}
	cout << endl;
	closeDevice(Dev);
	free(name);
	free(unit);
    _getch();
}

void GalvoBenchmarkTest()
{
    OCTDeviceHandle Dev = initDevice();

    const int size = 1024;
    
    double* tmpX = new double[size];
    double* tmpY = new double[size];

    double* resX = new double[size];
    double* resY = new double[size];

    for(int i=0; i<size; ++i)
    {
        tmpX[i] = 9.0*sin(2*M_PI*i/((double)size));
        tmpY[i] = 4.0*cos(2*M_PI*i/((double)size));
    }

    startScanBenchmark(Dev, tmpX, tmpY, size, 200000.0);
    do {
        getScanFeedback(Dev, resX, resY);
    } while(!_kbhit());
    stopScanBenchmark(Dev);
    _getch();

    ofstream out("D:\\galvo_bench");
    for(int i=0; i<size; ++i)
    {
        out << i << " " << tmpX[i] << " " << tmpY[i] << " " << resX[i] << "  " << resY[i] << endl;
    }
    out.close();

    delete[] tmpX;
    delete[] tmpY;

    delete[] resX;
    delete[] resY;

    closeDevice(Dev);
}

void LaserDiodeTest()
{
    OCTDeviceHandle Dev = initDevice();

    char error[512];
    if(getError(error, 512))
    {
        cerr << error << endl;
        _getch();
    }

    int n = getNumberOfOutputValues(Dev);
    cout << "Found " << n << " output values. \n";

    char name[512];
    char unit[512];
    for(int i=0; i<n; ++i)
    {
        double min, max;
        getOutputValueName(Dev, i, name, 512, unit, 512);
        cout << name << ", " << unit << ": ";
        getOutputValueRangeByName(Dev, name, &min, &max);
        cout << min << " to " << max << endl;
    }

    _getch();

    closeDevice(Dev);
}

void NoScanPatternTest()
{
	OCTDeviceHandle Dev = initDevice();
	ProbeHandle Probe = initProbe(Dev, "");

	ProcessingHandle Proc = createProcessingForDevice(Dev);
	
	setProcessingParameterInt(Proc, Processing_SpectrumAveraging, 100);
	ScanPatternHandle Pattern = createNoScanPattern(Probe, 100, 1);

	RawDataHandle Raw = createRawData();

	startMeasurement(Dev, Pattern, Acquisition_AsyncFinite);

	getRawData(Dev, Raw);

	stopMeasurement(Dev);

	clearRawData(Raw);
	clearScanPattern(Pattern);
	closeProcessing(Proc);

	closeProbe(Probe);
	closeDevice(Dev);

	_getch();
}

void RawDataExportImportTest()
{
	OCTDeviceHandle Dev = initDevice();

	RawDataHandle Raw = createRawData();
	measureSpectra(Dev, 100, Raw);
	exportRawData(Raw, RawDataExport_SRR, "D:\\Test\\Raw.srr");
	clearRawData(Raw);

	Raw = createRawData();
	importRawData(Raw, RawDataImport_SRR, "D:\\Test\\Raw.srr");
	exportRawData(Raw, RawDataExport_SRR, "D:\\Test\\Raw_copy.srr");
	clearRawData(Raw);

	closeDevice(Dev);

	_getch();
}

void OfflineProcessingTest()
{
	// example is currently optimized for Callisto
	OCTDeviceHandle Dev = initDevice();

	const int numberOfPixels = getDevicePropertyInt(Dev, Device_SpectrumElements);
	const float scalingFactor = getDevicePropertyFloat(Dev, Device_BinToElectronScaling);
	const int bytesPerPixel = getDevicePropertyInt(Dev, Device_BytesPerElement);
	const float minElectrons = sqrtf(getDevicePropertyFloat(Dev, Device_FullWellCapacity));
	const float FFTOversampling = 2.0;

	cout << "Device properties: ";
	cout << "number of pixels: " << numberOfPixels << "\n";
	cout << "scaling factor:   " << scalingFactor << "\n";
	cout << "bytes per pixel:  " << bytesPerPixel << "\n";
	cout << "Min Electrons:    " << minElectrons << "\n";
	cout << "Please press a key to continue. " << endl;

	ProcessingHandle ProcTmp = createProcessingForDevice(Dev);
	setProcessingParameterInt(ProcTmp, Processing_SpectrumAveraging, 50);
	measureCalibration(Dev, ProcTmp, Calibration_ApodizationVector);

	saveCalibration(ProcTmp, Calibration_Chirp, "C:\\tmp\\Chirp.dat");
	saveCalibration(ProcTmp, Calibration_OffsetErrors, "C:\\tmp\\Offset.dat");
	saveCalibration(ProcTmp, Calibration_ApodizationSpectrum, "C:\\tmp\\Spectrum.dat");
	
	RawDataHandle RawTmp = createRawData();
	measureSpectra(Dev, 100, RawTmp);

	DataHandle DataTmp = createData();
	setProcessedDataOutput(ProcTmp, DataTmp);
	executeProcessing(ProcTmp, RawTmp);

	exportData2D(DataTmp, Data2DExport_RAW, "C:\\tmp\\res_orig.raw");
	clearData(DataTmp);

	closeProcessing(ProcTmp);

	closeDevice(Dev);
	exportRawData(RawTmp, RawDataExport_SRR, "C:\\tmp\\raw.srr");
	clearRawData(RawTmp);

	// At this point raw

	cout << "Creating offline processing... " << flush;
	ProcessingHandle Proc = createProcessing(numberOfPixels, bytesPerPixel, false, scalingFactor, minElectrons, Processing_NFFT2, FFTOversampling);
	cout << "done. " << endl;

	loadCalibration(Proc, Calibration_Chirp, "C:\\tmp\\Chirp.dat");
	loadCalibration(Proc, Calibration_OffsetErrors, "C:\\tmp\\Offset.dat");
	loadCalibration(Proc, Calibration_ApodizationSpectrum, "C:\\tmp\\Spectrum.dat");

	RawDataHandle Raw = createRawData();
	importRawData(Raw, RawDataImport_SRR, "C:\\tmp\\raw.srr");

	DataHandle Data = createData();

	for(int i=0; i<1000; i++)
	{
		setProcessedDataOutput(Proc, Data);
		executeProcessing(Proc, Raw);
	}

	exportData2D(Data, Data2DExport_RAW, "C:\\tmp\\res.raw");

	closeProcessing(Proc);
	clearData(Data);
	clearRawData(Raw);
	
	char error_message[512];
	if(getError(error_message, 512))
	{
		cerr << "An error occurred when attempting to perform offline processing: \n";
		cerr << error_message << '\n';
	}
	cout << "Press any key to quit. \n"; 
	_getch();
}

void NFFTProcessingTest()
{
	// example is currently optimized for Callisto
	// OCTDeviceHandle Dev = initDevice();

	const int numberOfPixels = 1024;
	const float scalingFactor = 540.;
	const int bytesPerPixel = 2;
	const float minElectrons = 1;
	const int Binning = 4;

	/* const int numberOfPixels = getDevicePropertyInt(Dev, Device_SpectrumElements);
	const float scalingFactor = getDevicePropertyFloat(Dev, Device_BinToElectronScaling);
	const int bytesPerPixel = getDevicePropertyInt(Dev, Device_BytesPerElement);
	const float minElectrons = sqrtf(getDevicePropertyFloat(Dev, Device_FullWellCapacity)); */

	cout << "Device properties: ";
	cout << "number of pixels: " << numberOfPixels << "\n";
	cout << "scaling factor:   " << scalingFactor << "\n";
	cout << "bytes per pixel:  " << bytesPerPixel << "\n";
	cout << "Min Electrons:    " << minElectrons << "\n";
	cout << "Please press a key to continue. " << endl;

	cout << "Creating offline processing... " << flush;

	const ProcessingType ProcArrayType[] = 
		{Processing_StandardFFT,
		Processing_StandardNDFT,
		Processing_iFFT1,
		Processing_iFFT2,
		Processing_iFFT3,
		Processing_iFFT4,
		Processing_NFFT1,
		Processing_NFFT2,
		Processing_NFFT3,
		Processing_NFFT4};

	const char* ProcArrayName[] = 
		{"FFT",
		"NDFT",
		"iFFT1",
		"iFFT2",
		"Processing_iFFT3",
		"Processing_iFFT4",
		"Processing_NFFT1",
		"Processing_NFFT2",
		"Processing_NFFT3",
		"Processing_NFFT4"};

	Coloring32BitHandle Coloring = createColoring32Bit(ColorScheme_BlackAndWhite, Coloring_RGBA);
	RawDataHandle Raw = createRawData();

	std::string Dir = "D:\\NFFT\\Mirror\\";

	const int I = 703;
	for(ptrdiff_t i=1; i<I; ++i)
	{

#ifdef RAW_DATA
	ifstream in((Dir + std::string("tmp   8")).c_str(), ios::binary);
	if(!in)
	{
		cerr << "Error opening file" << endl;
		_getch();
	}
	const ptrdiff_t XOffset = 139;
	const ptrdiff_t SizeX = 4096;
	const ptrdiff_t SizeZ = 1024;
	unsigned short* tmp = new unsigned short[(SizeX+XOffset)*SizeZ];
	in.read(reinterpret_cast<char*>(tmp), sizeof(unsigned short)*(SizeX+XOffset)*SizeZ);
	setRawDataBytesPerPixel(Raw, bytesPerPixel);
	resizeRawData(Raw, SizeZ, SizeX+XOffset, 1);
	setRawDataContent(Raw, tmp); 
	delete[] tmp;
	in.close();


	int ScanRegion[2] = {XOffset, SizeX + XOffset};
	setScanSpectra(Raw, 1, ScanRegion);
#else

	stringstream input_file;
	input_file << "tmp";
	input_file.width(4);
	input_file << i;
	
	// easy version:
	importRawData(Raw, RawDataImport_SRR, (Dir + input_file.str()).c_str());
#endif

	for(ptrdiff_t i=0; i<16; ++i)
	{
		ProcessingHandle Proc = createProcessing(numberOfPixels, bytesPerPixel, false, scalingFactor, minElectrons, ProcArrayType[i], 2.0);
		DataHandle Data = createData();

		loadCalibration(Proc, Calibration_Chirp, (Dir + std::string("tmp_Chirp.txt")).c_str());
		loadCalibration(Proc, Calibration_OffsetErrors, (Dir + std::string("tmp_Offset.txt")).c_str());
		loadCalibration(Proc, Calibration_ApodizationSpectrum, (Dir + std::string("tmp_Apo.txt")).c_str());
	
		setProcessingParameterInt(Proc, Processing_SpectrumAveraging, Binning);
		setProcessedDataOutput(Proc, Data);
		// setSpectrumOutput(Proc, Data);
		executeProcessing(Proc, Raw);

		const std::string filename = std::string("D:\\NFFT\\") + input_file.str() + std::string("_") + std::string(ProcArrayName[i]) + std::string(".raw");
		exportData2D(Data, Data2DExport_Fits, filename.c_str());

		float MinRange;
		float MaxRange;
		determineDynamicRange(Data, &MinRange, &MaxRange);
		MinRange -= 5.0;
		setColoringBoundaries(Coloring, MinRange, MaxRange);

		const std::string png_filename = std::string("D:\\NFFT\\res_") + input_file.str() + std::string("_") + std::string(ProcArrayName[i]) + std::string(".png");
		exportData2DAsImage(Data, Coloring, ColoredDataExport_PNG, png_filename.c_str(), FALSE, FALSE, TRUE);
		
		closeProcessing(Proc);
		clearData(Data);

		char error_message[512];
		if(getError(error_message, 512))
		{
			cerr << "An error occurred when attempting to perform offline processing: \n";
			cerr << error_message << '\n';
		}
	}
	} // for schleife
	clearRawData(Raw);
	cout << "Press any key to quit. \n"; 
	_getch();
}


void DispersionCalibrationTest()
{
	OCTDeviceHandle Dev = initDevice();
	ProcessingHandle Proc = createProcessingForDevice(Dev);
	RawDataHandle Raw = createRawData();

	DataHandle Data1 = createData();
	DataHandle Data2 = createData();

	setProcessingParameterInt(Proc, Processing_SpectrumAveraging, 100);
	setApodizedSpectrumOutput(Proc, Data1);
	measureSpectra(Dev, 100, Raw);
	executeProcessing(Proc, Raw);

	setApodizedSpectrumOutput(Proc, Data2);
	measureSpectra(Dev, 100, Raw);
	executeProcessing(Proc, Raw);

	clearRawData(Raw);
	closeProcessing(Proc);
	closeDevice(Dev);

	DataHandle Chirp = createData();
	DataHandle Disp = createData();

	computeDispersion(Data1, Data2, Chirp, Disp);	
}

void FullRangeTest() 
{
	OCTDeviceHandle Dev = initDevice();
	ProcessingHandle Proc = createProcessingForDevice(Dev);
	ProcessingHandle Proc_2 = Proc;
	// ProcessingHandle Proc_2 = createProcessing(1024, 2, 1.0f, 0.0f, Processing_StandardFFT);
	RawDataHandle Raw = createRawData();
	ProbeHandle Probe = initProbe(Dev, "Probe");
	setProbeParameterInt(Probe, Probe_Oversampling, 1);
	setProcessingParameterInt(Proc, Processing_SpectrumAveraging, 1);
	ScanPatternHandle Pattern = createBScanPattern(Probe, 1.0, 2000, TRUE);

	FullRangeHandle FullRange = initFullRange();
	
	DataHandle Data = createData();
		
	ComplexDataHandle CData = createComplexData();
	ComplexDataHandle CData2 = createComplexData();

	DataHandle FullRangeImage = createData();
	DataHandle FullRangeImage_Inv = createData();

	char error[1024];
	if(getError(error, 1024))
	{
		cout << "ERROR: " << error << endl;
		_getch();
	}

	startMeasurement(Dev, Pattern, Acquisition_AsyncContinuous);
	while(!_kbhit())
	{
		getRawData(Dev, Raw);

		setComplexDataOutput(Proc, CData2);
		executeProcessing(Proc, Raw);
		
		computeLinearKRawData(CData2, Data);
		exportData2D(Data, Data2DExport_RAW, "C:\\tmp\\full_range_spec.raw");
		executeFullRange(FullRange, Data, CData);

		setProcessedDataOutput(Proc_2, FullRangeImage_Inv);
		setHorMirroredDataOutput(Proc_2, FullRangeImage);
		executeComplexProcessing(Proc_2, CData);
	
		exportData2D(FullRangeImage, Data2DExport_RAW, "C:\\tmp\\full_range.raw");
	}
	stopMeasurement(Dev);
	
	clearData(FullRangeImage);
	clearData(FullRangeImage_Inv);
	clearComplexData(CData);
	clearData(Data);
	closeFullRange(FullRange);

	clearScanPattern(Pattern);
	closeProbe(Probe);
	closeProcessing(Proc);
	// closeProcessing(Proc_2);
	clearRawData(Raw);
	closeDevice(Dev);
}



void DispersionTest()
{
	OCTDeviceHandle Dev = initDevice();
	ProcessingHandle Proc = createProcessingForDevice(Dev);

	RawDataHandle Raw = createRawData();
	ProbeHandle Probe = initProbe(Dev, "Probe");

	setProbeParameterInt(Probe, Probe_Oversampling, 1);
	
	setProcessingParameterInt(Proc, Processing_SpectrumAveraging, 1);
	setProcessingParameterInt(Proc, Processing_AScanAveraging, 1);

	ScanPatternHandle Pattern = createBScanPattern(Probe, 1.0, 2048, TRUE);

	DataHandle Data = createData();
	DataHandle Spectra = createData();
	DataHandle Disp = createData();
		
	ComplexDataHandle CData = createComplexData();

	char error[1024];
	if(getError(error, 1024))
	{
		cout << "ERROR: " << error << endl;
		_getch();
		return;
	}

	DataHandle Chirp = createData();
	getCalibration(Proc, Calibration_Chirp, Chirp);

	startMeasurement(Dev, Pattern, Acquisition_AsyncContinuous);
	while(!_kbhit())
	{
		getRawData(Dev, Raw);
		
		setProcessingFlag(Proc, Processing_UseDispersionCompensation, FALSE);
		// setApodizedSpectrumOutput(Proc, Spectra);
		setComplexDataOutput(Proc, CData);
		executeProcessing(Proc, Raw);
		
		computeLinearKRawData(CData, Spectra); 

		computeDispersionByImage(Spectra, Chirp, Disp);

		setCalibration(Proc, Calibration_Dispersion, Disp);
		setProcessingFlag(Proc, Processing_UseDispersionCompensation, TRUE);
		setProcessedDataOutput(Proc, Data);
		executeProcessing(Proc, Raw);

		exportData2D(Data, Data2DExport_RAW, "C:\\BScan_DispCorrected.raw");

		setProcessingFlag(Proc, Processing_UseDispersionCompensation, FALSE);
		setProcessedDataOutput(Proc, Data);
		executeProcessing(Proc, Raw);

		exportData2D(Data, Data2DExport_RAW, "C:\\BScan_Original.raw");
	}
	stopMeasurement(Dev);
	
	clearComplexData(CData);
	clearData(Spectra);
	clearData(Data);
	clearData(Disp);

	clearScanPattern(Pattern);
	closeProbe(Probe);
	closeProcessing(Proc);

	clearRawData(Raw);
	closeDevice(Dev);
}

void OfflineDispersionTest()
{
	OCTDeviceHandle Dev = initDevice();
	ProcessingHandle Proc = createProcessingForDevice(Dev);

	RawDataHandle Raw = createRawData();
	
	setProcessingParameterInt(Proc, Processing_SpectrumAveraging, 1);
	setProcessingParameterInt(Proc, Processing_AScanAveraging, 1);

	setApodizationWindow(Proc, Apodization_Blackman);

	DataHandle Data = createData();
	DataHandle Spectra = createData();
	DataHandle Disp = createData();
		
	ComplexDataHandle CData = createComplexData();

	char error[1024];
	if(getError(error, 1024))
	{
		cout << "ERROR: " << error << endl;
		_getch();
		return;
	}

	DataHandle Chirp = createData();
	getCalibration(Proc, Calibration_Chirp, Chirp);

	importRawData(Raw, RawDataImport_SRR, "C:\\OCTData\\Telesto_Disp_48.srr");
	
	// while(!_kbhit())
	{
		setProcessingFlag(Proc, Processing_UseDispersionCompensation, FALSE);

		setProcessedDataOutput(Proc, Data);
		executeProcessing(Proc, Raw);

		setComplexDataOutput(Proc, CData);
		executeProcessing(Proc, Raw);

		exportData2D(Data, Data2DExport_RAW, "C:\\DispCorrectedBscan_Orig.raw");
		
		computeLinearKRawData(CData, Spectra); 
		exportData2D(Spectra, Data2DExport_RAW, "C:\\DispCorrectedBscan_Spectra.raw");

		clock_t start = clock();
		for(int i=0; i<10; ++i)
			computeDispersionByImage(Spectra, Chirp, Disp);
		clock_t stop = clock();
		cout << "Time used: " << static_cast<double>(stop - start)/CLOCKS_PER_SEC << endl;
		_getch();

		setCalibration(Proc, Calibration_Dispersion, Disp);
		setProcessingFlag(Proc, Processing_UseDispersionCompensation, TRUE);
		setProcessedDataOutput(Proc, Data);
		executeProcessing(Proc, Raw);

		exportData2D(Data, Data2DExport_RAW, "C:\\DispCorrectedBscan.raw");
	}
	_getch();
	clearComplexData(CData);
	clearData(Spectra);
	clearData(Data);
	clearData(Disp);

	closeProcessing(Proc);

	clearRawData(Raw);
	closeDevice(Dev);
}


void FullRangeTest2() 
{
	OCTDeviceHandle Dev = initDevice();
	ProcessingHandle Proc = createProcessingForDevice(Dev);
	RawDataHandle Raw = createRawData();
	ProbeHandle Probe = initProbe(Dev, "Probe");
	setProbeParameterInt(Probe, Probe_Oversampling, 1);
	setProcessingParameterInt(Proc, Processing_SpectrumAveraging, 1);
	ScanPatternHandle Pattern = createBScanPattern(Probe, 1.0, 2000, TRUE);

	FullRangeHandle FullRange = initFullRange();
	
	DataHandle Data = createData();
		
	DataHandle Spectra = createData();
	ComplexDataHandle CSpectra = createComplexData();

	DataHandle FullRangeImage = createData();
	DataHandle FullRangeImage_Inv = createData();

	startMeasurement(Dev, Pattern, Acquisition_AsyncContinuous);
	while(!_kbhit())
	{
		getRawData(Dev, Raw);

		setApodizedSpectrumOutput(Proc, Spectra);
		executeProcessing(Proc, Raw);
		
		executeFullRange(FullRange, Spectra, CSpectra);
	
		setHorMirroredDataOutput(Proc, FullRangeImage);
		// setProcessedDataOutput(Proc, FullRangeImage_Inv);
		executeComplexProcessing(Proc, CSpectra);
	
		exportData2D(FullRangeImage, Data2DExport_RAW, "C:\\tmp\\full_range.raw");
		exportData2D(FullRangeImage_Inv, Data2DExport_RAW, "C:\\tmp\\full_range_inv.raw");
	}
	stopMeasurement(Dev);
	
	clearData(FullRangeImage);
	clearData(FullRangeImage_Inv);
	clearComplexData(CSpectra);
	clearData(Spectra);
	closeFullRange(FullRange);

	clearScanPattern(Pattern);
	closeProbe(Probe);
	closeProcessing(Proc);
	clearRawData(Raw);
	closeDevice(Dev);
}


void OfflineProcessingTest2()
{
	char* RawData;
	int SizeX, SizeY, SizeZ;
	int* apo_cycles;
	int* scan_cycles;

	OCTDeviceHandle Dev = initDevice();
	ProcessingHandle Proc = createProcessingForDevice(Dev);
    ProbeHandle Probe = initProbe(Dev, "Probe");

    setProcessingParameterInt(Proc, Processing_AScanAveraging, 1);
    setProcessingParameterInt(Proc, Processing_SpectrumAveraging, 1);
    setProbeParameterInt(Probe, Probe_Oversampling, 1);

    ScanPatternHandle Pattern = createBScanPattern(Probe, 2.0, 512, TRUE);

    RawDataHandle Raw = createRawData();
    DataHandle BScan = createData();

	Coloring32BitHandle Color = createColoring32Bit(ColorScheme_BlackAndWhite, Coloring_RGBA);
	setColoringBoundaries(Color, 0.0f, 70.0f);

	const int numberOfPixels = getDevicePropertyInt(Dev, Device_SpectrumElements);
	const float scalingFactor = getDevicePropertyFloat(Dev, Device_BinToElectronScaling);
	const int bytesPerPixel = getDevicePropertyInt(Dev, Device_BytesPerElement);
	const float minElectrons = sqrtf(getDevicePropertyFloat(Dev, Device_FullWellCapacity));
	
	saveCalibration(Proc, Calibration_Chirp, "C:\\tmp\\Chirp.dat");
	saveCalibration(Proc, Calibration_OffsetErrors, "C:\\tmp\\Offset.dat");

	// Start measurement and saving the raw data //
	startMeasurement(Dev, Pattern, Acquisition_AsyncContinuous);

    getRawData(Dev, Raw);
	getRawDataSize(Raw, &SizeX, &SizeY, &SizeZ);

	size_t N_scan = getNumberOfScanRegions(Raw);
	size_t N_apo = getNumberOfApodizationRegions(Raw);

	scan_cycles = new int[2*N_scan];
	apo_cycles = new int[2*N_apo];
	getScanSpectra(Raw, scan_cycles);
	getApodizationSpectra(Raw, apo_cycles);

	RawData = new char[bytesPerPixel*SizeX*SizeY*SizeZ];
	copyRawDataContent(Raw, RawData);

	ofstream out("C:\\tmp\\rawdata.raw", ios::binary);
	out.write(RawData, bytesPerPixel*SizeX*SizeY*SizeZ);
	out.close();

	exportRawData(Raw, RawDataExport_SRR, "C:\\tmp\\raw.srr");

	setHorMirroredDataOutput(Proc, BScan);
	executeProcessing(Proc, Raw);
	exportData2DAsImage(BScan, Color, ColoredDataExport_BMP, "C:\\tmp\\test.bmp", FALSE, FALSE, TRUE); 

	stopMeasurement(Dev);

    clearRawData(Raw);
    clearData(BScan);
    clearScanPattern(Pattern);
    closeProbe(Probe);
	closeProcessing(Proc);
    closeDevice(Dev);

	// Start loading and processing the raw data //
	ProcessingHandle OfflineProc = createProcessing(numberOfPixels, bytesPerPixel, false, scalingFactor, minElectrons, Processing_NFFT4, 3.0);
	loadCalibration(OfflineProc, Calibration_Chirp, "C:\\tmp\\Chirp.dat");
	loadCalibration(OfflineProc, Calibration_OffsetErrors, "C:\\tmp\\Offset.dat");

	RawDataHandle OfflineRaw = createRawData();

	// Method1: Import raw data and set apodization vector //
	// loadCalibration(OfflineProc, Calibration_ApodizationVector, "C:\\OCTData\\Apodization.dat");
	// importRawData(OfflineRaw, RawDataImport_SRR, "C:\\OCTData\\raw.srr");

	// Method2: Load raw data into a memory, copy memory to raw data object, set scan and apodization spectra //
	resizeRawData(OfflineRaw, SizeX, SizeY, SizeZ);

	ifstream in("C:\\OCTData\\rawdata.raw", ios::binary);
	if(!in) {
		cerr << "File could not be opened. " << endl;
		return;
	}
	in.read(RawData, bytesPerPixel*SizeX*SizeY*SizeZ);
	in.close();

	setRawDataContent(OfflineRaw, RawData);

	setApodizationSpectra(OfflineRaw, N_scan, apo_cycles);
	setScanSpectra(OfflineRaw, N_apo, scan_cycles);

	// now get info of offline raw
	getRawDataSize(OfflineRaw, &SizeX, &SizeY, &SizeZ);

	// Process the data //
	DataHandle OfflineBScan = createData();

	setProcessedDataOutput(OfflineProc, OfflineBScan);
	executeProcessing(OfflineProc, OfflineRaw);

	exportData2DAsImage(OfflineBScan, Color, ColoredDataExport_BMP, "C:\\tmp\\test1.bmp", FALSE, FALSE, TRUE);

	closeProcessing(OfflineProc);
	clearData(OfflineBScan);
	clearRawData(OfflineRaw);

	delete[] RawData;

	cout << "Press any key to quit. \n"; 
	_getch();
}

void PatternSwitchTest()
{
	OCTDeviceHandle Dev = initDevice();
	ProbeHandle Probe = initProbe(Dev, "Probe");
	ProcessingHandle Proc = createProcessingForDevice(Dev);
	DataHandle Data = createData();
	RawDataHandle Raw = createRawData();

	ScanPatternHandle P1 = createBScanPattern(Probe, 2.0, 1000, TRUE);
	ScanPatternHandle P2 = createCirclePattern(Probe, 1.0, 1000);

	const size_t error_size = 512;
	char error[error_size];
	while(!_kbhit())
	{
		static int i = 0;
		cout << "Attempt " << ++i << endl;

		
		startMeasurement(Dev, P1, Acquisition_AsyncContinuous);
		if(getError(error, error_size))
		{
			cout << "ERROR: " << error << endl;
			_getch();
		}
		getRawData(Dev, Raw);
		setProcessedDataOutput(Proc, Data);
		executeProcessing(Proc, Raw);
		stopMeasurement(Dev);
		if(getError(error, error_size))
		{
			cout << "ERROR: " << error << endl;
			_getch();
		}
				
		startMeasurement(Dev, P2, Acquisition_AsyncContinuous);
		if(getError(error, error_size))
		{
			cout << "ERROR: " << error << endl;
			_getch();
		}
		getRawData(Dev, Raw);
		setProcessedDataOutput(Proc, Data);
		executeProcessing(Proc, Raw);
		stopMeasurement(Dev);
		if(getError(error, error_size))
		{
			cout << "ERROR: " << error << endl;
			_getch();
		}
		
	}
	clearScanPattern(P1);
	clearScanPattern(P2);

	clearRawData(Raw);
	clearData(Data);
	closeProcessing(Proc);
	closeProbe(Probe);
	closeDevice(Dev);

	_getch();
}

void StreamRawVolumeToDisk()
{
	const size_t size_x = 1024;
	const size_t size_y = 1024;

	OCTDeviceHandle Dev = initDevice();
	ProcessingHandle Proc = createProcessingForDevice(Dev);
	ProbeHandle Probe = initProbe(Dev, "Probe");
	ScanPatternHandle Pattern = createBScanStackPattern(Probe, 2.0, size_x, 2.0, size_y);

	RawDataHandle Raw = createRawData();
	DataHandle BScan = createData();

	startMeasurement(Dev, Pattern, Acquisition_Sync);
	for(int i=0; i<size_y && !_kbhit(); ++i)
	{
		stringstream stream;
		stream << "C:\\tmp\\stream_";
		stream.width(4);
		stream << i << ".fits";

		getRawData(Dev, Raw);
		setProcessedDataOutput(Proc, BScan);
		executeProcessing(Proc, Raw);
		exportData2D(BScan, Data2DExport_Fits, stream.str().c_str());
	}
	stopMeasurement(Dev);
	clearRawData(Raw);
	clearData(BScan);

	clearScanPattern(Pattern);
	closeProbe(Probe);
	closeDevice(Dev);
	_getch();
}

void PatternTest()
{
	const size_t size_x = 360;
	const size_t size_y = 180;

    OCTDeviceHandle Dev = initDevice();
    ProbeHandle Probe = initProbe(Dev, "Probe");
    ProcessingHandle Proc = createProcessingForDevice(Dev);
	
	setProbeParameterInt(Probe, Probe_Oversampling, 1);
	setProcessingParameterInt(Proc, Processing_SpectrumAveraging, 1);

    ScanPatternHandle Pattern = createBScanStackPattern(Probe, 2.0, size_x, 2.0, size_y);
	

    DataHandle BScan = createData();
    DataHandle Volume = createData();
    RawDataHandle Raw = createRawData();

	reserveData(Volume, 1024, size_x, size_y);
   
    startMeasurement(Dev, Pattern, Acquisition_AsyncFinite);
    for(int i = 0; i < size_y; ++i)
    {
        getRawData(Dev, Raw);
        setProcessedDataOutput(Proc, BScan);
        executeProcessing(Proc, Raw);

        cout << "BScan Size: " << getDataPropertyFloat(BScan, Data_Range1) << " x " << getDataPropertyFloat(BScan, Data_Range2) << endl;

        appendData(Volume, BScan, Direction_3);
        cout << "Current volume size: " << getDataPropertyInt(Volume, Data_Size1) << " x " << getDataPropertyInt(Volume, Data_Size2) << " x " << getDataPropertyInt(Volume, Data_Size3) << endl;
    }  
	stopMeasurement(Dev);

    cout << "FINAL DATA: " << endl;
    cout << "Current volume size: " << getDataPropertyInt(Volume, Data_Size1) << " x " << getDataPropertyInt(Volume, Data_Size2) << " x " << getDataPropertyInt(Volume, Data_Size3) << endl;
    cout << "Current volume size (physical): " << getDataPropertyFloat(Volume, Data_Range1) << " x " << getDataPropertyFloat(Volume, Data_Range2) << " x " << getDataPropertyFloat(Volume, Data_Range3) << endl;

	DataHandle EnFace = createData();
	getDataSliceAnalyzed(Volume, EnFace, Direction_1, Data_Max);
	Coloring32BitHandle Coloring = createColoring32Bit(ColorScheme_BlackAndWhite, Coloring_RGBA);

	ColoredDataHandle EnFaceColored = createColoredData();
	colorizeData(Coloring, EnFace, EnFaceColored, TRUE);

	ColoredDataHandle Image = createColoredData();
	getCameraImage(Dev, 320, 200, Image);

	blendEnFaceInCamera(Probe, Pattern, EnFaceColored, Image, 0.5, FALSE);

	_getch();

	clearColoredData(EnFaceColored);
	clearColoredData(Image);

    clearRawData(Raw);
    clearData(BScan);
    clearScanPattern(Pattern);
    closeProbe(Probe);
    closeProcessing(Proc);
    closeDevice(Dev);
}

void PatternTest2()
{
	OCTDeviceHandle Dev = initDevice();
    ProbeHandle Probe = initProbe(Dev, "Probe");

	ScanPatternHandle Pattern = createBScanPatternManual(Probe, -2.0, 1.0, 2.0, -1.0, 1024, TRUE);

	int N = getScanPatternLUTSize(Pattern);
	double* x = new double[N];
	double* y = new double[N];
	getScanPatternLUT(Pattern, x, y);

	ofstream out("C:\\Galvo_LUT.txt");
	for(int i=0; i<N; ++i)
	{
		out << x[i] << " " << y[i] << endl;
	}
	out.close();

	delete[] x;
	delete[] y;

	clearScanPattern(Pattern);

	closeDevice(Dev);
	closeProbe(Probe);
}

void FragmentedPatternTest()
{
	const int chunk_size = 256;
    const int chunks = 10;

    OCTDeviceHandle Dev = initDevice();
    ProcessingHandle Proc = createProcessingForDevice(Dev);
	ProbeHandle Probe = initProbe(Dev, "Probe");
    ScanPatternHandle Pattern = createFragmentedScanPattern(Probe, chunk_size, chunks);

    DataHandle Chunk = createData();
    DataHandle BScan = createData();
    RawDataHandle Raw = createRawData();

    startMeasurement(Dev, Pattern, Acquisition_AsyncFinite);
    for(int i = 0; i < chunks; ++i)
    {
        getRawData(Dev, Raw);
        setProcessedDataOutput(Proc, Chunk);
        executeProcessing(Proc, Raw);

        cout << "Chunk Size: " << getDataPropertyFloat(Chunk, Data_Range1) << " x " << getDataPropertyFloat(Chunk, Data_Range2) << endl;

        appendData(BScan, Chunk, Direction_2);
        cout << "Current volume size: " << getDataPropertyInt(BScan, Data_Size1) << " x " << getDataPropertyInt(BScan, Data_Size2) << " x " << getDataPropertyInt(BScan, Data_Size3) << endl;
    }  
    cout << "FINAL DATA: " << endl;
    cout << "Current volume size: " << getDataPropertyInt(BScan, Data_Size1) << " x " << getDataPropertyInt(BScan, Data_Size2) << " x " << getDataPropertyInt(BScan, Data_Size3) << endl;
    cout << "Current volume size (physical): " << getDataPropertyFloat(BScan, Data_Range1) << " x " << getDataPropertyFloat(BScan, Data_Range2) << " x " << getDataPropertyFloat(BScan, Data_Range3) << endl;
    
    cout << "100% " << endl;

    stopMeasurement(Dev);

    clearRawData(Raw);
	clearData(Chunk);
    clearData(BScan);
    clearScanPattern(Pattern);
    closeProcessing(Proc);
    closeDevice(Dev);

    _getch();

}

void getDeviceNameTest()
{
	OCTDeviceHandle Dev = initDevice();
	char name[512];
	getDeviceType(Dev, name, 512);
	cout << "\n\n" << name << endl;
	_getch();
}

void getProbeParametersTest()
{
	char message[1024];

	OCTDeviceHandle Dev = initDevice();
	ProbeHandle Probe = initProbe(Dev, "Probe");

	if(getError(message, 1024))
	{
		cout << "ERROR: " << message << endl;
		_getch();
		return;
	}

	cout << "Factor X: " << getProbeParameterFloat(Probe, Probe_FactorX) << endl;
	cout << "Offset X: " << getProbeParameterFloat(Probe, Probe_OffsetX) << endl;

	cout << "Factor Y: " << getProbeParameterFloat(Probe, Probe_FactorY) << endl;
	cout << "Offset Y: " << getProbeParameterFloat(Probe, Probe_OffsetY) << endl;

	cout << "FlybackTime: " << getProbeParameterFloat(Probe, Probe_FlybackTime_Sec) << endl;
	cout << "RotationTime: " << getProbeParameterFloat(Probe, Probe_RotationTime_Sec) << endl;
	cout << "ExpansionTime: " << getProbeParameterFloat(Probe, Probe_ExpansionTime_Sec) << endl;

	_getch();
}

void Chirp()
{
	OCTDeviceHandle Dev = initDevice();

	const int numberOfPixels = getDevicePropertyInt(Dev, Device_SpectrumElements);
	const float scalingFactor = getDevicePropertyFloat(Dev, Device_BinToElectronScaling);
	const int bytesPerPixel = getDevicePropertyInt(Dev, Device_BytesPerElement);
	const float minElectrons = sqrtf(getDevicePropertyFloat(Dev, Device_FullWellCapacity));

	cout << "Device properties: ";
	cout << "number of pixels: " << numberOfPixels << "\n";
	cout << "scaling factor:   " << scalingFactor << "\n";
	cout << "bytes per pixel:  " << bytesPerPixel << "\n";
	cout << "Min Electrons:    " << minElectrons << "\n";
	cout << "Please press a key to continue. " << endl;

	ProcessingHandle ProcTmp = createProcessingForDevice(Dev);
	measureCalibration(Dev, ProcTmp, Calibration_ApodizationVector);
	measureCalibration(Dev, ProcTmp, Calibration_Chirp);
	measureCalibration(Dev, ProcTmp, Calibration_Chirp);
	closeProcessing(ProcTmp);
	closeDevice(Dev);

	char message[1024];

	if(getError(message, 1024))
	{
		cout << "ERROR: " << message << endl;
		_getch();
		return;
	}
}

#include <numeric>
using namespace std;

template<typename T>
inline void linear_regression(size_t size, T* x, T* y, T* slope, T* intercept)
{
    T x_bar = 0;
	T y_bar = 0;
	T xy_bar = 0;
	T xx_bar = 0;

	T* tmp = new T[size]; 

	x_bar = accumulate(x, x+size, static_cast<T>(0))/static_cast<T>(size);
	y_bar = accumulate(y, y+size, static_cast<T>(0))/static_cast<T>(size);
	
	transform(x, x+size, y, tmp, multiplies<T>());
	xy_bar = accumulate(tmp, tmp+size, static_cast<T>(0))/static_cast<T>(size);

	transform(x, x+size, tmp, bind2nd(ptr_fun<T, T, T>(pow), static_cast<T>(2)));
	xx_bar = accumulate(tmp, tmp+size, static_cast<T>(0))/static_cast<T>(size);

	*slope = (xy_bar - y_bar*x_bar)/(xx_bar - x_bar*x_bar);
	*intercept = y_bar - (*slope)*x_bar;
}

void BidirectionalCalibration() 
{
	OCTDeviceHandle Dev = initDevice();
	ProbeHandle Probe = initProbe(Dev, "Probe");

	const double dist = 0.5;
	const int pattern_size = 1024;

	ScanPatternHandle Pattern = createBilateralBScanPattern(Probe, dist, pattern_size, 1.0);

	int Size = getScanPatternLUTSize(Pattern);
	cout << "Scan pattern size: " << Size << endl;

	double* X = new double[Size];
	double* Y = new double[Size];
	getScanPatternLUT(Pattern, X, Y);

	double* Xres = new double[Size];
	double* Yres = new double[Size];

	double* Ind1 = new double[pattern_size];
	for(ptrdiff_t i=0; i<pattern_size; ++i)
		Ind1[i] = i - pattern_size/2.0f;

	double* Ind2 = new double[pattern_size];
	for(ptrdiff_t i=0; i<pattern_size; ++i)
		Ind2[i] = -(i - pattern_size/2.0f);

	clearScanPattern(Pattern);

	ofstream out("C:\\bi_cal", ios::binary);
	ofstream tout("C:\\bi_cal_fit_corr.txt");
	

	for(double Hz=500.0; Hz < 600000.0; Hz += 500.0)
	{
		setProbeParameterFloat(Probe, Probe_ExpectedScanRate_Hz, Hz);
		ScanPatternHandle Pattern = createBilateralBScanPattern(Probe, dist, pattern_size, 1.0);
		int Size = getScanPatternLUTSize(Pattern);
		getScanPatternLUT(Pattern, X, Y);

		cout << "Current rate: " << Hz << " Hz" << endl;
		startScanBenchmark(Dev, X, Y, Size, Hz);
		getScanFeedback(Dev, Xres, Yres);
		getScanFeedback(Dev, Xres, Yres);
		cout << "Feedback size: " << getScanFeedbackSize(Dev) << endl;

		double velocity = dist/pattern_size * Hz;

		double slope1;
		double intercept1;
		double slope2;
		double intercept2;
		linear_regression(pattern_size - 256, Ind1 + 128, Xres + 128, &slope1, &intercept1);
		linear_regression(pattern_size - 256, Ind2 + 128, Xres + pattern_size + 128, &slope2, &intercept2);

		ofstream fout("C:\\current_fit.txt");
		for(ptrdiff_t i=0; i<pattern_size; ++i)
		{
			fout << Ind1[i] << " " << Xres[i] << " " << slope1 * Ind1[i] + intercept1 << " " << Ind2[i] << " " << Xres[i + pattern_size] << " " << slope2 * Ind1[i] + intercept2 << endl;
		}
		fout.close();

		tout << velocity << " " << Hz << " " << slope1 << " " << intercept1 << " " << slope2 << " " << intercept2 << endl;

		out.write(reinterpret_cast<char*>(Xres), sizeof(double)*Size);

		stopScanBenchmark(Dev);
		clearScanPattern(Pattern);
	}
	tout.close();
	out.close();
	
	closeDevice(Dev);
	closeProbe(Probe);
}

void PresetTest()
{
	OCTDeviceHandle Dev = initDevice();
	ProbeHandle Probe = initProbe(Dev, "Probe");
	ProcessingHandle Proc = createProcessingForDevice(Dev);

	setCameraPreset(Dev, Probe, Proc, Device_CameraPreset_1);

	char message[1024];

	if(getError(message, 1024))
	{
		cout << "ERROR: " << message << endl;
		_getch();
		return;
	}

	cout << "Preset activated. " << endl;
	closeProcessing(Proc);
	closeProbe(Probe);
	closeDevice(Dev);
}

void StartStopDemo()
{
	const int N = 4096;

	OCTDeviceHandle Dev = initDevice();
	ProbeHandle Probe = initProbe(Dev, "Probe");
	ProcessingHandle Proc = createProcessingForDevice(Dev);

	RawDataHandle Raw = createRawData();

	float angle = 1.0f;
	while(!_kbhit())
	{
		ScanPatternHandle Pattern = createBScanPattern(Probe, 2.0, N, TRUE);
		
		rotateScanPattern(Pattern, angle * 3.14159265/180);

		startMeasurement(Dev, Pattern, Acquisition_AsyncContinuous);

		// getRawData(Dev, Raw);

		stopMeasurement(Dev);

		clearScanPattern(Pattern);
		angle += 1.0f;
	}

	clearRawData(Raw);

	closeProcessing(Proc);
	closeProbe(Probe);
	closeDevice(Dev);

}

void CheckErrorHandling()
{
	OCTDeviceHandle Dev = initDevice();
	ProbeHandle Probe = initProbe(Dev, "Probe");
	ProcessingHandle Proc = createProcessingForDevice(Dev);
	ScanPatternHandle Pattern = createBScanPatternManual(Probe, -2.0, 1.0, 2.0, -1.0, 1024, TRUE);
	startMeasurement(Dev, Pattern, Acquisition_AsyncContinuous);

	// supposedely crashed
	Dev = initDevice();	
	closeDevice(Dev);

	_getch();
}


void OfflineDispersionTest2()
{	
	ProcessingHandle Proc = createProcessing(2048, 2, false, 1.0, 10.0, Processing_NFFT3, 2.0);
	RawDataHandle Raw = createRawData();

	loadCalibration(Proc, Calibration_Chirp, "E:\\Dispersion\\Calibration\\Chirp.dat");

	DataHandle Chirp = createData();
	getCalibration(Proc, Calibration_Chirp, Chirp);

	DataHandle Data = createData();
	DataHandle Spectra = createData();
	DataHandle Disp = createData();
	ComplexDataHandle CData = createComplexData();

	char error[1024];
	if(getError(error, 1024))
	{
		cout << "ERROR: " << error << endl;
		_getch();
		return;
	}

	const int Nz = 2048;
	const int Nx = 8292;
	const int Ny = 1;

	setRawDataBytesPerPixel(Raw, 2);
	resizeRawData(Raw, Nz, Nx, Ny);

	unsigned short* tmp = new unsigned short[Nz*Nx*Ny];
	ifstream in("E:\\Dispersion\\Christian\\20.raw", ios::binary);
	// ifstream in("E:\\Dispersion\\Gesa\\9.raw", ios::binary);
	// ifstream in("E:\\Dispersion\\Gesa\\11.raw", ios::binary);
	// ifstream in("E:\\Dispersion\\Mirror_20mm\\1.raw", ios::binary);
	in.read(reinterpret_cast<char*>(tmp), sizeof(unsigned short)*Nx*Ny*Nz);
	in.close();

	setRawDataContent(Raw, tmp);

	int ScanRegion[2] = {99, 8291};
	setScanSpectra(Raw, 1, ScanRegion);

	int ApoRegion[2] = {30, 70};
	setApodizationSpectra(Raw, 1, ApoRegion);

	setProcessingFlag(Proc, Processing_UseDispersionCompensation, FALSE);
	setProcessingParameterInt(Proc, Processing_SpectrumAveraging, 4);
	setProcessingParameterInt(Proc, Processing_AScanAveraging, 2);

// #define GUESS_DISP
#ifdef GUESS_DISP
	setComplexDataOutput(Proc, CData);
	executeProcessing(Proc, Raw);
		
	computeLinearKRawData(CData, Spectra); 
	computeDispersionByImage(Spectra, Chirp, Disp);
	setCalibration(Proc, Calibration_Dispersion, Disp);
	saveCalibration(Proc, Calibration_Dispersion, "E:\\Dispersion\\Results\\Gesa11_Phases.txt");
	setProcessingFlag(Proc, Processing_UseDispersionCompensation, TRUE);
	setProcessedDataOutput(Proc, Data);
	executeProcessing(Proc, Raw);

	exportData2D(Data, Data2DExport_RAW, "C:\\BScan_DispCorrected.raw");
#endif

#define USE_CALIBRATION
#ifdef USE_CALIBRATION
	loadCalibration(Proc, Calibration_Dispersion, "E:\\Dispersion\\Results\\Gesa9_Phases.txt");
	// loadCalibration(Proc, Calibration_Dispersion, "E:\\Dispersion\\Calibration\\Dispersion.dat");
	// loadCalibration(Proc, Calibration_Chirp, "E:\\Dispersion\\Calibration\\Chirp.dat");
	setProcessingFlag(Proc, Processing_UseDispersionCompensation, TRUE);
	setProcessedDataOutput(Proc, Data);
	executeProcessing(Proc, Raw);

	exportData2D(Data, Data2DExport_RAW, "C:\\BScan_DispCorrected_Calib_C20_disp_G9.raw");
#endif

	setProcessingFlag(Proc, Processing_UseDispersionCompensation, FALSE);
	setProcessedDataOutput(Proc, Data);
	executeProcessing(Proc, Raw);

	exportData2D(Data, Data2DExport_RAW, "C:\\BScan_Original.raw");

	clearComplexData(CData);
	clearData(Spectra);
	clearData(Data);
	clearData(Disp);

	closeProcessing(Proc);

	clearRawData(Raw);
}

void MultiCameraTest()
{
	const int error_length = 1024;
	char message[error_length];

    OCTDeviceHandle Dev = initDevice();
	
    RawDataHandle Raw = createRawData();
    ProcessingHandle Proc = createProcessingForDevice(Dev);

    DataHandle Spectrum = createData();
    DataHandle OffsetSpectrum = createData();
    DataHandle ApoSpectrum = createData();
    DataHandle AScan = createData();
	ComplexDataHandle ComplexAScan = createComplexData();

    const int Averaging = 1;
    const int Binning = 1;
	const int N = 10;

    setProcessingParameterInt(Proc, Processing_SpectrumAveraging, Binning);
    setProcessingParameterInt(Proc, Processing_AScanAveraging, Averaging);
	setProcessingFlag(Proc, Processing_UseApodization, TRUE);
	setProcessingFlag(Proc, Processing_RemoveAdvancedDCSpectrum, TRUE);
	setProcessingFlag(Proc, Processing_RemoveDCSpectrum, TRUE);

	int counter = 0;
    while(!_kbhit())
    {
        DataHandle Spectrum = createData();
        DataHandle OffsetSpectrum = createData();
        DataHandle ApoSpectrum = createData();
        DataHandle AScan = createData();

        measureSpectraEx(Dev, Averaging*Binning*N, Raw, (counter++)%2);

		if(getError(message, error_length))
		{
			cout << "ERROR: " << message << endl;
			_getch();
			return;
		}

        setSpectrumOutput(Proc, Spectrum);
        setOffsetCorrectedSpectrumOutput(Proc, OffsetSpectrum);
        setApodizedSpectrumOutput(Proc, ApoSpectrum);
        setProcessedDataOutput(Proc, AScan);
		setComplexDataOutput(Proc, ComplexAScan);
        executeProcessing(Proc, Raw);

		computeLinearKRawData(ComplexAScan, OffsetSpectrum);
		exportData1D(OffsetSpectrum, Data1DExport_RAW, "C:\\Spectrum.raw");
		exportData1D(Spectrum, Data1DExportFormat::Data1DExport_TableTXT, "C:\\Spectrum.txt");
		
		// do something with the data...
		// ....
		
        clearData(AScan);
        clearData(Spectrum);
        clearData(ApoSpectrum);
        clearData(OffsetSpectrum);
    }

    closeProcessing(Proc);

    clearRawData(Raw);
    closeDevice(Dev);
}

void MultiCameraTest2()
{
	const int error_length = 1024;
	char message[error_length];

	OCTDeviceHandle Dev = initDevice();

	if(getError(message, 1024))
	{
		cout << "ERROR: " << message << endl;
		_getch();
		return;
	}

	ProbeHandle Probe = initProbe(Dev, "Probe");
    ProcessingHandle Proc = createProcessingForDevice(Dev);

    setProcessingParameterInt(Proc, Processing_AScanAveraging, 1);
    setProcessingParameterInt(Proc, Processing_SpectrumAveraging, 1);
	setProcessingParameterInt(Proc, Processing_BScanAveraging, 2);
    setProbeParameterInt(Probe, Probe_Oversampling, 1);

	const int N = 2048;
    ScanPatternHandle Pattern = createBScanPattern(Probe, 2.0, N, TRUE);
	if(getError(message, error_length))
	{
		cout << "ERROR: " << message << endl;
		_getch();
		return;
	}

	setCameraPreset(Dev, Probe, Proc, Device_CameraPreset_3);
   
    RawDataHandle Raw0 = createRawData();
	RawDataHandle Raw1 = createRawData();
    DataHandle BScan = createData();
    ColoredDataHandle ColoredBScan = createColoredData();
    ComplexDataHandle ComplexBScan = createComplexData();

    Coloring32BitHandle Coloring = createColoring32Bit(ColorScheme_BlackAndWhite, Coloring_RGBA);

    setColoringBoundaries(Coloring, 0.0f, 70.0f);
    startMeasurement(Dev, Pattern, Acquisition_AsyncContinuous);
	if(getError(message, error_length))
	{
		cout << "ERROR: " << message << endl;
		_getch();
		return;
	}

    while(!_kbhit())
    {
		static int i = 1; 
		static clock_t counter = clock();

        getRawDataEx(Dev, Raw0, 0);
		getRawDataEx(Dev, Raw1, 1);

		setProcessedDataOutput(Proc, BScan);
        executeProcessing(Proc, Raw0);
		// now BScan contains processed data of Raw0
		executeProcessing(Proc, Raw1);
		// now BScan contains processed data of Raw1

		if(getError(message, error_length))
		{
			cout << "ERROR: " << message << endl;
			_getch();
			return;
		}

		++i;
    }
	_getch();
    stopMeasurement(Dev);
    clearRawData(Raw0);
	clearRawData(Raw1);
    clearData(BScan);

    clearScanPattern(Pattern);

    closeProbe(Probe);
    closeDevice(Dev);
	closeProcessing(Proc);

	_getch();
}

void ExternalTriggerDemo()
{
	cout << "Do not trigger externally until the measurement is started correctly" << endl;
	char message[1024];

	OCTDeviceHandle Dev = initDevice();

	if (getError(message, 1024))
	{
		cout << "ERROR: " << message << endl;
		_getch();
		return;
	}

	ProbeHandle Probe = initProbe(Dev, "Probe");
	
	ProcessingHandle Proc = createProcessingForDevice(Dev);

	setProcessingParameterInt(Proc, Processing_AScanAveraging, 1);
	setProcessingParameterInt(Proc, Processing_SpectrumAveraging, 1);
	setProcessingParameterInt(Proc, Processing_BScanAveraging, 1);
	setProbeParameterInt(Probe, Probe_Oversampling, 1);

	const int N = 1024;
	ScanPatternHandle Pattern = createBScanPattern(Probe, 2.0, N, TRUE);
	if (getError(message, 512))
	{
		cout << "ERROR: " << message << endl;
		_getch();
		return;
	}

	setCameraPreset(Dev, Probe, Proc, 0); // slowest

	RawDataHandle Raw = createRawData();
	DataHandle BScan = createData();
	ColoredDataHandle ColoredBScan = createColoredData();
	Coloring32BitHandle Coloring = createColoring32Bit(ColorScheme_BlackAndWhite, Coloring_RGBA);

	setColoringBoundaries(Coloring, 0.0f, 70.0f);

	setTriggerMode(Dev, Trigger_External_AScan);
	setTriggerTimeoutSec(Dev, 5);

	startMeasurement(Dev, Pattern, Acquisition_AsyncContinuous);
	cout << "External triggering possible as of now. " << endl;
	if (getError(message, 512))
	{
		cout << "ERROR: " << message << endl;
		_getch();
		return;
	}

	Timer t;
	t.start();

	Timer t_proc;
	Timer t_get;
	double proc_secs = 0.0;
	double get_secs = 0.0;
	while (!_kbhit())
	{
		static int i = 1;
		static clock_t counter = clock();

		t_get.start();
		getRawData(Dev, Raw);
		get_secs = t_get.get_seconds();

		t_proc.start();

		setProcessedDataOutput(Proc, BScan);

		executeProcessing(Proc, Raw);
		if (getError(message, 512))
		{
			cout << "ERROR: " << message << endl;
			stopMeasurement(Dev);
			closeDevice(Dev);
			_getch();
			return;
		}

		++i;
	}
	colorizeData(Coloring, BScan, ColoredBScan, false);
	exportColoredData(ColoredBScan, ColoredDataExport_PNG, "C:\\ExtTriggerTestImg");

	stopMeasurement(Dev);
	cout << "Please stop the external trigger signal here to make sure that the next measurement can be started correctly. " << endl;
	clearRawData(Raw);
	clearData(BScan);

	clearScanPattern(Pattern);
	closeProbe(Probe);
	closeProcessing(Proc);
	closeDevice(Dev);

	_getch();
}

void LinearizeData()
{
	const int N = 2048;
	const int Nx = 2385;
	const std::string infile = "Peak1";

	ProcessingHandle Proc = createProcessing(N, 2, false, 32.958984, 1.0, ProcessingType::Processing_NFFT2, 2.0);
	RawDataHandle Raw = createRawData();
	setRawDataBytesPerPixel(Raw, 2);
	resizeRawData(Raw, N, Nx, 1);

	char* tmp = new char[N*Nx*sizeof(short)];
	ifstream in((std::string("E:\\DEFR\\Data\\") + infile).c_str(), ios::binary);
	in.read(tmp, sizeof(short)*N*Nx);
	in.close();
	setRawDataContent(Raw, tmp);
	int ScanRegion[] = {2385-2048, 2385};
	setScanSpectra(Raw, 1, ScanRegion);

	loadCalibration(Proc, CalibrationData::Calibration_OffsetErrors, "E:\\DEFR\\Data\\tmp_Offset.txt");
	loadCalibration(Proc, CalibrationData::Calibration_ApodizationSpectrum, "E:\\DEFR\\Data\\tmp_Apo.txt");
	loadCalibration(Proc, CalibrationData::Calibration_Chirp, "E:\\DEFR\\Data\\Config\\Chirp.dat");
	// loadCalibration(Proc, CalibrationData::Calibration_Dispersion, "E:\\DEFR\\Data\\Config\\Dispersion.dat");

	DataHandle SpectraIn = createData();
	DataHandle Image = createData();
	setApodizedSpectrumOutput(Proc, SpectraIn);
	setProcessedDataOutput(Proc, Image);
	executeProcessing(Proc, Raw);

	DataHandle Chirp = createData();
	DataHandle OrigDisp = createData();
	getCalibration(Proc, CalibrationData::Calibration_Chirp, Chirp);
	// getCalibration(Proc, CalibrationData::Calibration_Dispersion, OrigDisp);
	
	DataHandle SpectraOut = createData();
	DataHandle LinDisp = createData();
	
	linearizeSpectralData(SpectraIn, SpectraOut, Chirp);
	// linearizeSpectralData(OrigDisp, LinDisp, Chirp);

	exportData2D(SpectraIn, Data2DExportFormat::Data2DExport_RAW, (std::string("E:\\DEFR\\Resampled\\") + infile + std::string(".raw")).c_str());
	exportData2D(SpectraOut, Data2DExportFormat::Data2DExport_RAW, (std::string("E:\\DEFR\\Resampled\\") + infile + std::string("_LinearK.raw")).c_str()); 
	exportData2D(Image, Data2DExportFormat::Data2DExport_RAW, (std::string("E:\\DEFR\\Resampled\\") + infile + std::string("_Reconstructed.raw")).c_str());

	DataHandle NoChirp = createGradientData(N);
	float* ptr = getDataPtr(NoChirp);
	for(int i=0; i<N; ++i)
		ptr[i] *= static_cast<float>(N);
	DataHandle Disp = createData();
	computeDispersionByImage(SpectraOut, NoChirp, Disp);
	setCalibration(Proc, CalibrationData::Calibration_Dispersion, Disp);
	saveCalibration(Proc, CalibrationData::Calibration_Dispersion, "E:\\DEFR\\Disp_NoChirp.dat");

	// setCalibration(Proc, CalibrationData::Calibration_Dispersion, LinDisp);
	// saveCalibration(Proc, CalibrationData::Calibration_Dispersion, "E:\\DEFR\\LinearizedDisp.dat");

	DataHandle Spec1 = createData();
	DataHandle Spec2 = createData();
	DataHandle Spec3 = createData();
	importRealBinaryData(Spec1, 2048, 1, 1, "E:\\DEFR\\Resampled\\Peak1_LinearK.raw");
	importRealBinaryData(Spec2, 2048, 1, 1, "E:\\DEFR\\Resampled\\Peak2_LinearK.raw");
	importRealBinaryData(Spec3, 2048, 1, 1, "E:\\DEFR\\Resampled\\Peak3_LinearK.raw");

	DataHandle NewChirp = createData();
	DataHandle NewDisp = createData();
	computeDispersion(Spec1, Spec3, NewChirp, NewDisp);

	cout << "Dimensionality of NewDisp: " << getDataPropertyInt(NewDisp, DataPropertyInt::Data_Dimensions) << endl;

	setCalibration(Proc, CalibrationData::Calibration_Dispersion, NewDisp);
	saveCalibration(Proc, CalibrationData::Calibration_Dispersion, "E:\\DEFR\\CalibDisp.dat");
	
	// computeDispersion(

	closeProcessing(Proc);
}

void DEFR()
{
	const int N = 2048;
	const int Nx = 2048;
	const std::string infile = "Skin3";
	float* spectra = new float[N*Nx];
	ifstream in((std::string("E:\\DEFR\\Resampled\\") + infile + std::string("_LinearK.raw")).c_str(), ios::binary);
	in.read(reinterpret_cast<char*>(spectra), sizeof(float)*N*Nx);
	in.close();

	DataHandle Spectra = createData();
	resizeData(Spectra, N, Nx, 1);
	setDataContent(Spectra, spectra);
	delete[] spectra;

	// DEFR(Spectra);
}

void GalvoTFTest()
{
    OCTDeviceHandle Dev = initDevice();

    const int size = 1024;
    
    double* tmp = new double[size];

    double* resX = new double[size];
    double* resY = new double[size];

	double re,im;

	double freqs[] = { 10000, 50000, 100000, 200000, 400000 };
	double ampl[] = { 1, 3, 6, 9 };

	ofstream outxa("D:\\galvo_bench_xa");
	ofstream outxp("D:\\galvo_bench_xp");
	ofstream outya("D:\\galvo_bench_ya");
	ofstream outyp("D:\\galvo_bench_yp");

	for(int l=0; l<4; l++)
	{
		for(int k=0; k<5; k++)
		{
			for(int i=0; i<size; ++i)
			{
				tmp[i] = ampl[l]*cos(2*M_PI*i/((double)size));
			}

			startScanBenchmark(Dev, tmp, tmp, size, freqs[k]);
			for(int z=0; z<10; z++)
				getScanFeedback(Dev, resX, resY);
			stopScanBenchmark(Dev);

			re = 0; im = 0; 
			for(int i=0; i<size; ++i)
			{
				re += cos(2*M_PI*i/((double)size)) * resX[i] / ampl[l] / 2.0 / size;
				im += sin(2*M_PI*i/((double)size)) * resX[i] / ampl[l] / 2.0 / size;
			}

			outxa << sqrt(re*re+im*im) << " ";
			outxp << atan2(im,re) << " ";

			re = 0; im = 0; 
			for(int i=0; i<size; ++i)
			{
				re += cos(2*M_PI*i/((double)size)) * resY[i] / ampl[l] / 2.0 / size;
				im += sin(2*M_PI*i/((double)size)) * resY[i] / ampl[l] / 2.0 / size;
			}

			outya << sqrt(re*re+im*im) << " ";
			outyp << atan2(im,re) << " ";

		}
		outxa << endl;
		outya << endl;
		outxp << endl;
		outyp << endl;
	}
	outxa.close();
	outya.close();
	outxp.close();
	outyp.close();

    delete[] tmp;

    delete[] resX;
    delete[] resY;

    closeDevice(Dev);
}

void USBProbeControllerTest()
{
	OCTDeviceHandle dev = initDevice();
	initUSBProbeCtrl(dev);
	char* msg = new char[64];
	while (!_kbhit())
	{
		memset(msg, 0x00, sizeof(char) * 64);
		if (getLastUSBProbeMessage(dev, msg, 64))
		{
			//std::cout << "Message received: " << hex << static_cast<unsigned int>(msg[0]) << std::endl;
		}
	}
	delete[] msg;
}

void __stdcall refstagestatuscallback(RefstageStatus msg)
{
	std::cout << "			--- Stage callback says motor is ";
	switch (msg)
	{
	case 0:
		cout << "idle.";
		break;
	case 1:
		cout << "homing.";
		break;
	case 2:
		cout << "moving.";
		break;
	case 3:
		cout << "moving to a specified length.";
		break;
	default: "existing.";
	}
	std::cout << std::endl;
}

void __stdcall refstageposchange(double pos)
{
	cout << "Position is " << pos << " mm." << endl;
}

void ReferenceStageTest()
{
	OCTDeviceHandle dev = initDevice();
	ProbeHandle probe = initProbe(dev, "");
	cout << endl << "Initializing reference stage and waiting for homing to finish..." << endl;
	cout << "Reference stage reports length of " << refstageGetLength_mm(dev, probe) << "mm." << endl;
	refstageSetStatusCallback(dev, &refstagestatuscallback);
	refstageSetPosChangeCallback(dev, &refstageposchange);
	refstageSetPosChangeCallback(dev, &refstageposchange);
	refstageHome(dev, false);
	while (refstageGetStatus(dev) != RefstageStatus::REFSTAGE_STATUS_IDLE){};
	cout << "Moving to 40.0mm ..." << endl;
	refstageMoveAbsolute(dev, probe, 40.0);
	while (refstageGetStatus(dev) != RefstageStatus::REFSTAGE_STATUS_IDLE){};
	cout << "Please press any key..." << endl;
	_getch();
	cout << "Moving to 45.0mm ..." << endl;
	refstageMoveAbsolute(dev, probe, 45.0);
	while (refstageGetStatus(dev) != RefstageStatus::REFSTAGE_STATUS_IDLE){};
	cout << "Please press any key..." << endl;
	_getch();
	cout << "Moving for 1 second... " << endl;
	refstageMoveShorter(dev);
	Sleep(1000);
	refstageStop(dev);
	while (refstageGetStatus(dev) != RefstageStatus::REFSTAGE_STATUS_IDLE){};
	Sleep(1000);
	cout << "Please press any key..." << endl;
	_getch();
	cout << "... and moving back to 0.1." << endl;
	refstageMoveAbsolute(dev, probe, 0.1);
	cout << "Done.";
}


void AdvancedSnapshotTest()
{
	char message[512];

	OCTDeviceHandle Dev = initDevice();

	if (getError(message, 512))
	{
		cerr << "\n\n" << message << endl;
		_getch();
		return;
	}

	const int size_z = getDevicePropertyInt(Dev, DevicePropertyInt::Device_SpectrumElements) / 2;
	const int size_x = 512;
	const int size_y = 10;

	ProbeHandle Probe = initProbe(Dev, "Probe");
	ProcessingHandle Proc = createProcessingForDevice(Dev);

	ScanPatternHandle Pattern = createBScanStackPattern(Probe, 5.0, size_x, 0.0, size_y);

	DataHandle BScan = createData();
	RawDataHandle Raw = createRawData();
	DataHandle Volume = createData();
	reserveData(Volume, size_z, size_x, size_y);
	Coloring32BitHandle coloring = createColoring32Bit(ColorScheme_BlackAndWhite, Coloring_BGRA);

	startMeasurement(Dev, Pattern, Acquisition_AsyncFinite);
	for (int i = 0; i < size_y; ++i)
	{
		getRawData(Dev, Raw);
		setProcessedDataOutput(Proc, BScan);
		executeProcessing(Proc, Raw);

		appendData(Volume, BScan, Direction_3);

		cout << "BScan Size: " << getDataPropertyFloat(BScan, Data_Range1) << " x " << getDataPropertyFloat(BScan, Data_Range2) << endl;

		if (getError(message, 512))
		{
			cerr << "\n\nAn error occurred: " << message << endl;
			_getch();
		}
	}
	crossCorrelatedProjection(Volume, BScan);
	if (getError(message, 512))
	{
		cerr << "\n\nAn error occurred: " << message << endl;
		_getch();
	}
	float min_dB, max_dB;
	determineDynamicRange(BScan, &min_dB, &max_dB);
	setColoringBoundaries(coloring, min_dB, max_dB);

	exportData2DAsImage(BScan, coloring, ColoredDataExport_PNG, "D:\\temp\\AdvancedSnapshot.png", false, false, false);

	stopMeasurement(Dev);

	clearRawData(Raw);
	clearData(BScan);
	clearData(Volume);
	clearScanPattern(Pattern);
	closeProbe(Probe);
	closeProcessing(Proc);
	closeDevice(Dev);

	_getch();
	if (getError(message, 512))
	{
		cerr << "\n\nAn error occurred: " << message << endl;
		_getch();
	}
}

int main()
{  
	cout << "The following tests are available: \n\n";
    cout << "a: Continuous B-scan acquisition\n";
    cout << "b: Measuring a single stack (volume) \n";
    cout << "c: Continuous volume acquisition \n";
    cout << "d: Continuous Doppler acquisition\n";
    cout << "e: Testing analog to digital converter.\n";
    cout << "f: Raw Data test.\n";
#ifdef _NEW_FILEHANDLER
    cout << "g: Zip engine test.\n";
#endif
	cout << "h: Camera video test.\n";
    cout << "i: Sync Acquisition test.\n";
    cout << "j: A-scan test.\n";
    cout << "k: On-off test. \n";
    cout << "l: Export-Import test. \n";
    cout << "m: Manual scanner move. \n";
    cout << "n: Averaging and Binning. \n";
    cout << "o: Galvo Feedback Test. \n";
	cout << "?: Galvo TF Test. \n";
    cout << "p: Laser Diode Test. \n";
	cout << "q: No Scan Pattern Test. \n";
	cout << "r: Raw Data export, import test. \n";
	cout << "s: Offline processing test. \n";
	cout << "t: Dispersion test. \n"; 
	cout << "u: Full Range test. \n";
	cout << "v: Offline Processing Test 2.\n";
	cout << "w: Pattern Switch Test. \n"; 
	cout << "x: Stream volume. \n";
	cout << "y: Pattern test. \n";
	cout << "z: Pattern test 2. \n";
	cout << "1: Continuous B-Scan acquisition, rotated by 90°\n";
	cout << "3: Fragmented Scan Pattern Test\n";
	cout << "6: Init Probe Test. \n";
	cout << "E: External Trigger Demo\n";
	cout << "M: Multi Camera test\n";
	cout << "Q: Motorized Reference Stage Test\n";
	cout << "D: Advanced Snapshot Test\n";

    char c = _getch();
    switch(c)
    {
    case 'a': ContinuousBScanMeasurement(false);
        break;
    case 'b': FiniteStackMeasurement();
        break;
    case 'c': ContinuousVolumeMeasurement();
        break;
    case 'd': ContinuousDopplerMeasurement();
        break;
    case 'e': ADC_DAC_Test();
        break;
    case 'f': RawData();
        break;
#ifdef _NEW_FILEHANDLER
	case 'g': TestFileEngine();
		_getch();
		break;
#endif
    case 'h': VideoCameraTest();
        break;
    case 'i': SyncAcquisition();
        break;
    case 'j': AScanMeasurement();
        break;
    case 'k': OnOffTest();
        break;
    case 'l': ExportImportTest();
        break;
    case 'm': ManualScannerMove();
        break;
    case 'n': AveragingAndBinning();
        break;
    case 'o': GalvoBenchmarkTest();
        break;
    case 'p': LaserDiodeTest();
        break;
	case 'q': NoScanPatternTest();
		break;
	case 'r': RawDataExportImportTest();
		break;
	case 's': OfflineProcessingTest();
		break;
	case 't': DispersionCalibrationTest();
		break;
	case 'u': FullRangeTest();
		break;
	case 'v': OfflineProcessingTest2();
		break;
	case 'w': PatternSwitchTest();
		break;
	case 'x': StreamRawVolumeToDisk();
		break;
	case 'y': PatternTest();
		break;
	case 'z': PatternTest2();
		break;
	case '1': ContinuousBScanMeasurement(true);
		break;
	case '2': LargeVolumeErrorHandling();
		break;
	case '3': FragmentedPatternTest();
		break;
	case '4': FullRangeTest2();
		break;
	case '5': getDeviceNameTest();
		break;
	case '6': getProbeParametersTest ();
		break;
	case '7': DispersionTest();
		break;
	case '8': Chirp();
		break;
	case '9': ContinuousBilateralBScanMeasurement();
		break;	
	case '0': BidirectionalCalibration();
		break;
	case ',': OfflineDispersionTest();
		break;
	case '.': PresetTest();
		break;
	case '-': CheckErrorHandling();
		break;
	case '+': ColoringDemo();
		break;
	case '#': StartStopDemo();
		break;
	case 'E': ExternalTriggerDemo();
		break;
	case 'M': MultiCameraTest();
		break;
	case 'N': MultiCameraTest2();
		break;
	case 'O': USBProbeControllerTest();
		break;
	case 'Q': ReferenceStageTest();
		break;
	case 'D': AdvancedSnapshotTest();
		break;
	case '?': GalvoTFTest();
		break;
	default:
        cerr << "Not supported!" << endl;
        _getch();
    }  
	_getch();
	return 0;
} 