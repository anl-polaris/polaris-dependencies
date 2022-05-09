@ECHO OFF

SETLOCAL

IF NOT "%1" == "" (
	set BASEDIR=%1
) ELSE IF NOT "%POLARIS_DEPS_DIR%" == "" (
	  set BASEDIR=%POLARIS_DEPS_DIR%
) ELSE (
	set BASEDIR=c:\opt\polaris\deps\
)

:: get our slashes all straightened out :)
set a=%BASEDIR%
set a=%a:/=\%
echo %a%
set BASEDIR=%a%

set FILEDIR=%~dp0..\

IF NOT EXIST %BASEDIR% (mkdir %BASEDIR%)

REM  see if Visual Studio is already set
echo %VSINSTALLDIR%
:: PAUSE
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

IF NOT "%VCROOT%" == "" (
	echo "calling vcvarsall"
    call "%VCROOT%\vcvarsall.bat" amd64
)
:: PAUSE

:: Download and expand source files
set TARBALL=%BASEDIR%\log4cpp-1.1.3.tar.gz
set DESTDIR=%BASEDIR%\log4cpp-1.1.3
set BUILDDIR=%DESTDIR%\CMAKE_BUILD

echo file=%TARBALL%
echo dir=%DESTDIR%

set DEBUG_BUILD=0
set RELEASE_BUILD=0
set BUILD_ERROR=0

set ERRORLEVEL=
cd /D %BASEDIR%
%FILEDIR%utils\wget --show-progress=off -O %TARBALL% "https://sourceforge.net/projects/log4cpp/files/latest/download" --no-check-certificate
tar xzvf %TARBALL%
IF ERRORLEVEL 1 ( ECHO Download and Extract of '%TARBALL%' - FAIL  & ECHO STTATUS: FAIL & ENDLOCAL & EXIT /B 1 )

mkdir %BUILDDIR%
cd %BUILDDIR%
IF "%VisualStudioVersion%" == "16.0" (
	cmake -G "Visual Studio 16 2019" -A x64 ..\. -Wno-dev
	IF ERRORLEVEL 1 ( ECHO Failed to build CMake file! /B 1 )
	cmake --build . -j --config Debug
	cmake --build . -j --config RelWithDebInfo
) ELSE IF "%VisualStudioVersion%" == "15.0" (
	cmake -G "Visual Studio 15 Win64" ..\. -Wno-dev
	IF ERRORLEVEL 1 ( ECHO Failed to build CMake file! /B 1 )
	cmake --build . -j --config Debug
	cmake --build . -j --config RelWithDebInfo
)

cd /D %FILEDIR%
call DisplayDate.cmd
IF %BUILD_ERROR% NEQ 0 (ECHO STATUS: FAIL & ENDLOCAL & EXIT /B 1)
ENDLOCAL
ECHO STATUS: SUCCESS
