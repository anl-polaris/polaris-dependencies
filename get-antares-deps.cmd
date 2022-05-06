@ECHO OFF

SETLOCAL

IF NOT "%1" == "" (
	set BASEDIR=%1
) ELSE IF NOT "%POLARIS_DEPS_DIR%" == "" (
	set BASEDIR=%POLARIS_DEPS_DIR%
) ELSE (
	set BASEDIR=C:\opt\polaris\deps
)

REM  see if Vsual Studio is already set
SET VCROOT=
IF "%VSINSTALLDIR%" == "" (
	call find-msvc.bat 14
    IF ERRORLEVEL 1 exit /B %ERRORLEVEL%
) ELSE IF NOT "%VisualStudioVersion%" == "14.0" (
	echo "Visual Studio 14.0 (2015) is required"
	exit /B 1
) ELSE IF NOT "%Platform%" == "X64" (
	echo "Visual Studio 14.0 (2015) must be set for X64 platform"
	exit /B 1
)

IF NOT "%VCROOT%" == "" (
    call "%VCROOT%\vcvarsall.bat" amd64
)

SET COMPILER_VER=msvc-14.0
SET DEPSDIR=%BASEDIR%\%COMPILER_VER%

:: get our slashes all straightened out :)
set a=%DEPSDIR%
set a=%a:/=\%
echo DEPSDIR=%a% with slashes fixed
set DEPSDIR=%a%

SET LOGDIR=%DEPSDIR%\builds
IF NOT EXIST %LOGDIR% ( mkdir %LOGDIR% )
IF EXIST %LOGDIR%\shapelib_build.log ( DEL %LOGDIR%\shapelib_build.log )
IF EXIST %LOGDIR%\freetype_build.log ( DEL %LOGDIR%\freetype_build.log )
IF EXIST %LOGDIR%\glew_build.log ( DEL %LOGDIR%\glew_build.log )
IF EXIST %LOGDIR%\wxWidgets_build.log ( DEL %LOGDIR%\wxWidgets_build.log )
IF EXIST %LOGDIR%\plplot_build.log ( DEL %LOGDIR%\plplot_build.log )

set BUILD_ERROR=0

cd /D %~dp0
set SHAPELIB_BUILD=0
set ERRORLEVEL=
call %~dp0\antares\build-shapelib-1.3.0.cmd %DEPSDIR% > %LOGDIR%\shapelib_build.log 2>&1
IF %ERRORLEVEL% NEQ 0 (ECHO Build of ShapeLib 1.3.0 - FAIL  & set BUILD_ERROR=1) ELSE (ECHO Build of ShapeLib 1.3.0 - SUCCESS)

cd /D %~dp0
set FREETYPE_BUILD=0
set ERRORLEVEL=
call %~dp0\antares\build-freetype-2.6.3.cmd %DEPSDIR% > %LOGDIR%\freetype_build.log 2>&1
IF %ERRORLEVEL% NEQ 0 (ECHO Build of FreeType 2.6.3 - FAIL & set BUILD_ERROR=1) ELSE (ECHO Build of FreeType 2.6.3 - SUCCESS)

cd /D %~dp0
SET GLEW_BUILD=0
set ERRORLEVEL=
call %~dp0\antares\build-glew-1.13.0.cmd %DEPSDIR% > %LOGDIR%\glew_build.log 2>&1
IF %ERRORLEVEL% NEQ 0 (ECHO Build of Glew 1.13.0 - FAIL & set BUILD_ERROR=1) ELSE (ECHO Build of Glew 1.13.0 - SUCCESS)

cd /D %~dp0
set WXWIDGETS_BUILD=0
set ERRORLEVEL=
call %~dp0\antares\build-wxWidgets-3.1.2.cmd %DEPSDIR% > %LOGDIR%\wxWidgets_build.log 2>&1
IF %ERRORLEVEL% NEQ 0 (ECHO Build of wxWidgets 3.1.2 - FAIL & set BUILD_ERROR=1) ELSE (ECHO Build of wxWidgets 3.1.2 - SUCCESS)

cd /D %~dp0
SET PLPLOT_BUILD=0
set ERRORLEVEL=
call %~dp0\antares\build-plplot-5.11.1.cmd %DEPSDIR% > %LOGDIR%\plplot_build.log 2>&1
IF %ERRORLEVEL% NEQ 0 (ECHO Build of plPlot 5.11.1 - FAIL & set BUILD_ERROR=1) ELSE (ECHO Build of plPlot 5.11.1 - SUCCESS)

:: as a convenience we copy all dll's to a single folder to save on path entries
IF NOT EXIST %DEPSDIR%\antares_bin ( mkdir %DEPSDIR%\antares_bin )
IF NOT EXIST %DEPSDIR%\_antares_bin\Debug ( mkdir %DEPSDIR%\antares_bin\Debug )
IF NOT EXIST %DEPSDIR%\antares_bin\Release ( mkdir %DEPSDIR%\antares_bin\Release )

COPY %DEPSDIR%\glew-1.13.0\build_vs2015\bin\Debug\*.dll		%DEPSDIR%\antares_bin\Debug
COPY %DEPSDIR%\glew-1.13.0\build_vs2015\bin\Release\*.dll	%DEPSDIR%\antares_bin\Release

COPY %DEPSDIR%\shapelib-1.3.0\lib\shapelib_d.dll			%DEPSDIR%\antares_bin\Debug
COPY %DEPSDIR%\shapelib-1.3.0\lib\shapelib.dll				%DEPSDIR%\antares_bin\Release

copy %DEPSDIR%\wxWidgets-3.1.2\lib\vc_x64_dll\wx*310ud_*.dll %DEPSDIR%\antares_bin\Debug
copy %DEPSDIR%\wxWidgets-3.1.2\lib\vc_x64_dll\wx*310u_*.dll %DEPSDIR%\antares_bin\Release

cd /D %~dp0
call DisplayDate.cmd
IF %BUILD_ERROR% NEQ 0 (ECHO STATUS: FAIL & ENDLOCAL & EXIT /B 1)
ENDLOCAL
ECHO STATUS: SUCCESS
