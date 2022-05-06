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
set ZIPFILE=%DEPSDIR%\shapelib-1.3.0.zip
set LIBDIR=%DEPSDIR%\shapelib-1.3.0

echo ZIPFILE=	%ZIPFILE%
echo LIBDIR=	%LIBDIR%

set ERRORLEVEL=
IF NOT EXIST %LIBDIR% ( mkdir %LIBDIR% )
cd /D %DEPSDIR%
%FILEDIR%utils\wget --show-progress=off -O %ZIPFILE% "http://download.osgeo.org/shapelib/shapelib-1.3.0.zip"
%FILEDIR%utils\unzip -o -q %ZIPFILE%
IF ERRORLEVEL 1 (ECHO Download and Extract of '%ZIPFILE%' - FAIL & cd /D %FILEDIR% & ENDLOCAL & EXIT /B 1)

set DEBUG_BUILD=0
set RELEASE_BUILD=0
set BUILD_ERROR=0

cd /D %LIBDIR%
copy shapelib_makefile_debug.vc .

SET ERRORLEVEL=
nmake -f makefile.vc SHARED=0 UNICODE=1
IF ERRORLEVEL 1 ( SET RELEASE_BUILD=1 )

SET ERRORLEVEL=
nmake -f shapelib_makefile_debug.vc SHARED=0 UNICODE=1
IF ERRORLEVEL 1 ( SET DEBUG_BUILD=1 )

mkdir include
copy *.h include
mkdir lib
move *.lib lib
move *.dll lib
::move *.pdb lib
mkdir bin
move *.exe bin

IF %RELEASE_BUILD% NEQ 0 (ECHO MSBuild of ShapeLib 1.3.0 Release project - FAIL )
IF %DEBUG_BUILD% NEQ 0  (ECHO MSBuild of ShapeLib 1.3.0 Debug project - FAIL )

cd /D %FILEDIR%
call DisplayDate.cmd
IF %BUILD_ERROR% NEQ 0 (ECHO STATUS: FAIL & ENDLOCAL & EXIT /B 1)
ENDLOCAL
ECHO STATUS: SUCCESS


