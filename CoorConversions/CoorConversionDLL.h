// CoorConversionDLL.h
// Luke Rumbaugh
// 18 September 2007

// Defines coordinate conversion functions for export to MATLAB

#ifndef CoorConversionDLL
#define CoorConversionDLL

#ifdef COOR_CONVERSION_DLL_EXPORTS
#define COOR_CONVERSION_DLL_ENU2ECEF extern "C" __declspec(dllexport)
#define COOR_CONVERSION_DLL_ECEF2ENU extern "C" __declspec(dllexport)
#define COOR_CONVERSION_DLL_ECEF2ECI extern "C" __declspec(dllexport)
#define COOR_CONVERSION_DLL_ECI2ECEF extern "C" __declspec(dllexport)
#define COOR_CONVERSION_DLL_ANGLE extern "C" __declspec(dllexport)
#else
#define COOR_CONVERSION_DLL_ENU2ECEF extern "C" __declspec(dllimport)
#define COOR_CONVERSION_DLL_ECEF2ENU extern "C" __declspec(dllimport)
#define COOR_CONVERSION_DLL_ECEF2ECI extern "C" __declspec(dllimport)
#define COOR_CONVERSION_DLL_ECI2ECEF extern "C" __declspec(dllimport)
#define COOR_CONVERSION_DLL_ANGLE extern "C" __declspec(dllimport)
#endif

COOR_CONVERSION_DLL_ENU2ECEF	void ENU2ECEF(const double arInput[6], double dOSLat, double dOSLong, double arOutput[6]);
COOR_CONVERSION_DLL_ECEF2ENU	void ECEF2ENU(const double arInput[6], double dOSLat, double dOSLong, double arOutput[6]);
COOR_CONVERSION_DLL_ECEF2ECI	void ECEF2ECI(const double arInput[6], double dDeltaT, double arOutput[6]);
COOR_CONVERSION_DLL_ECI2ECEF	void ECI2ECEF(const double arInput[6], double dDeltaT, double arOutput[6]);
COOR_CONVERSION_DLL_ANGLE		double angle(double x, double y);//returns value of angle in radians from x axis. Range is 0 - 2PI

#endif