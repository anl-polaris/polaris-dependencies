@ECHO OFF
::ECHO This is just a test
::EXIT /B 1

SETLOCAL

IF NOT "%1" == "" (
	set BASEDIR=%1
) ELSE IF NOT "%POLARIS_DEPS_DIR%" == "" (
	  set BASEDIR=%POLARIS_DEPS_DIR%
) ELSE (
	set BASEDIR=c:\opt\polaris\deps
)

:: get our slashes all straightened out :)
set a=%BASEDIR%
set a=%a:/=\%
echo %a%
set BASEDIR=%a%

set FILEDIR=%~dp0..\

REM  see if Vsual Studio is already set
SET VCROOT=
IF "%VSINSTALLDIR%" == "" (
	call python .\compiler_version.py
	echo "called find compiler"
    IF ERRORLEVEL 1 exit /B %ERRORLEVEL%
) 

IF "%VisualStudioVersion%" == "16.0" (
	IF "%Platform%" == "x64" (
		echo "Using Visual Studio 16.0 (2019)"
	) ELSE (
		echo "Visual Studio 16.0 (2019) must be set for x64 platform"
		exit /B 1
	)
)ELSE IF "%VisualStudioVersion%" == "15.0" (
	IF "%Platform%" == "x64" (
		echo "Using Visual Studio 15.0 (2017)"
	) ELSE (
		echo "Visual Studio 15.0 (2017) must be set for x64 platform"
		exit /B 1
	)
)

:: Download and expand source files
set GTESTZIPFILE=%BASEDIR%\release-1.11.0.zip
set GTESTDIR=%BASEDIR%\googletest-release-1.11.0

echo file=%GTESTZIPFILE%
echo dir=%GTESTDIR%

set ERRORLEVEL=
IF NOT EXIST %GTESTDIR% ( mkdir %GTESTDIR% )
cd /D %BASEDIR%
%FILEDIR%utils\wget --show-progress=off -O %GTESTZIPFILE% "https://github.com/google/googletest/archive/refs/tags/release-1.11.0.zip"
%FILEDIR%utils\unzip -o -q %GTESTZIPFILE%
IF ERRORLEVEL 1 (ECHO Download and Extract of '%GTESTZIPFILE%' failed. & ECHO STATUS: FAIL & ENDLOCAL & EXIT /B 1)

set BUILDDIR=%GTESTDIR%\build
mkdir %BUILDDIR%
cd /D %BUILDDIR%

set DEBUG_BUILD=0
set RELEASE_BUILD=0
set BUILD_ERROR=0

IF "%VisualStudioVersion%" == "16.0" (
	cmake -D  gtest_force_shared_crt=TRUE -DCMAKE_CXX_FLAGS="-D_SILENCE_TR1_NAMESPACE_DEPRECATION_WARNING=1" -G "Visual Studio 16 2019" -A x64 ..\. -Wno-dev
	IF ERRORLEVEL 1 ( ECHO Failed to build CMake file! /B 1 )
	cmake --build . -j --config Debug
	cmake --build . -j --config RelWithDebInfo
	IF ERRORLEVEL 1 (SET DEBUG_BUILD=1 & set BUILD_ERROR=1)
) ELSE IF "%VisualStudioVersion%" == "15.0" (
	cmake -D  gtest_force_shared_crt=TRUE -DCMAKE_CXX_FLAGS="-D_SILENCE_TR1_NAMESPACE_DEPRECATION_WARNING=1" -G "Visual Studio 15 Win64" ..\. -Wno-dev
	IF ERRORLEVEL 1 ( ECHO Failed to build CMake file! /B 1 )
	cmake --build . -j --config Debug
	cmake --build . -j --config RelWithDebInfo
	IF ERRORLEVEL 1 (SET DEBUG_BUILD=1 & set BUILD_ERROR=1)
)

IF %RELEASE_BUILD% NEQ 0 (ECHO MSBuild of gtest 1.11.0 Release project - FAIL )
IF %DEBUG_BUILD% NEQ 0  (ECHO MSBuild of gtest 1.11.0 Debug project - FAIL )

cd /D %FILEDIR%
IF %BUILD_ERROR% NEQ 0 (ECHO STATUS: FAIL & ENDLOCAL & EXIT /B 1)
ENDLOCAL
ECHO STATUS: SUCCESS
