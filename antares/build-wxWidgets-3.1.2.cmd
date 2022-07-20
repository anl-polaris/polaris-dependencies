@ECHO OFF

SETLOCAL

IF NOT "%1" == "" (
	set DEPSDIR=%1
) ELSE IF NOT "%POLARIS_DEPS_DIR%" == "" (
	  set DEPSDIR=%POLARIS_DEPS_DIR%
) ELSE (
	set DEPSDIR=c:\opt\polaris\deps
)

:: get our slashes all straightened out :)
set a=%DEPSDIR%
set a=%a:/=\%
echo %a%
set DEPSDIR=%a%

set FILEDIR=%~dp0..\

:: Download and expand source files
set WIDGETZIPFILE=%DEPSDIR%\wxWidgets-3.1.2.zip
set WIDGETDIR=%DEPSDIR%\wxWidgets-3.1.2

echo WIDGETZIPFILE=		%WIDGETZIPFILE%
echo WIDGETDIR=		    %WIDGETDIR%

set ERRORLEVEL=
IF NOT EXIST %WIDGETDIR% ( mkdir %WIDGETDIR% )
cd /D %WIDGETDIR%
%FILEDIR%utils\wget --show-progress=off -O %WIDGETZIPFILE% "https://github.com/wxWidgets/wxWidgets/releases/download/v3.1.2/wxWidgets-3.1.2.zip"
%FILEDIR%utils\unzip -o -q %WIDGETZIPFILE%
IF %ERRORLEVEL% NEQ 0 (ECHO Download and Extract of '%WIDGETZIPFILE%' - FAIL & ENDLOCAL & EXIT /B 1)

::mkdir %WIDGETDIR%
cd /D %WIDGETDIR%/build/msw

set DLL_RELEASE_BUILD=0
set DLL_DEBUG_BUILD=0
set DEBUG_BUILD=0
set RELEASE_BUILD=0
set BUILD_ERROR=0

::set ERRORLEVEL=
::msbuild wx_vc14.sln /p:Platform=x64 /p:Configuration="DLL Release"
::IF %ERRORLEVEL% NEQ 0 (SET DLL_RELEASE_BUILD=1 & set BUILD_ERROR=1)

::set ERRORLEVEL=
::msbuild wx_vc14.sln /p:Platform=x64 /p:Configuration="DLL Debug"
::IF %ERRORLEVEL% NEQ 0 (SET DLL_DEBUG_BUILD=1 & set BUILD_ERROR=1)

set ERRORLEVEL=
::msbuild wx_vc14.sln /p:Platform=x64 /p:Configuration=Release
nmake /f makefile.vc BUILD=release SHARED=1 TARGET_CPU=X64
IF %ERRORLEVEL% NEQ 0 (SET RELEASE_BUILD=1 & set BUILD_ERROR=1)

set ERRORLEVEL=
::msbuild wx_vc14.sln /p:Platform=x64 /p:Configuration=Debug
nmake /f makefile.vc BUILD=debug SHARED=1 TARGET_CPU=X64
IF %ERRORLEVEL% NEQ 0 (SET DEBUG_BUILD=1 & set BUILD_ERROR=1)

IF %DLL_RELEASE_BUILD% NEQ 0 (ECHO MSBuild of wxWidgets 3.1.2 DLL Release project - FAIL)
IF %DLL_DEBUG_BUILD% NEQ 0 (ECHO MSBuild of wxWidgets 3.1.2 DLL Debug project - FAIL)
IF %RELEASE_BUILD% NEQ 0 (ECHO MSBuild of wxWidgets 3.1.2 LIB Release project - FAIL)
IF %DEBUG_BUILD% NEQ 0 (ECHO MSBuild of wxWidgets 3.1.2 LIB Debug project - FAIL)

cd /D %FILEDIR%
IF %BUILD_ERROR% NEQ 0 (ECHO STATUS: FAIL & ENDLOCAL & EXIT /B 1)
ENDLOCAL
ECHO STATUS: SUCCESS

