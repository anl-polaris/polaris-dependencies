@ECHO OFF

SETLOCAL

IF NOT "%1" == "" (
	set DEPSDIR=%1
) ELSE IF NOT "%POLARIS_DEPS_DIR%" == "" (
	  set DEPSDIR=%POLARIS_DEPS_DIR%
) ELSE (
	set DEPSDIR=C:\opt\polaris\deps
)

:: get our slashes all straightened out :)
set a=%DEPSDIR%
set a=%a:/=\%
echo %a%
set DEPSDIR=%a%

set FILEDIR=%~dp0..\

:: Download and expand source files
set FREETYPEZIPFILE=%DEPSDIR%\ft263.zip
set FREETYPEDIR=%DEPSDIR%\freetype-2.6.3

echo FREETYPEZIPFILE=	%FREETYPEZIPFILE%
echo FREETYPEDIR=		%FREETYPEDIR%

set ERRORLEVEL=
IF NOT EXIST %FREETYPEDIR% ( mkdir %FREETYPEDIR% )
cd /D %DEPSDIR%
%FILEDIR%utils\wget --show-progress=off --no-check-certificate -O %FREETYPEZIPFILE% "https://download.savannah.gnu.org/releases/freetype/freetype-old/ft263.zip"
%FILEDIR%utils\unzip -o -q %FREETYPEZIPFILE%
IF ERRORLEVEL 1 (ECHO Download and Extract of '%FREETYPEZIPFILE%' - FAIL & cd /D %FILEDIR% & ENDLOCAL & EXIT /B 1)

set BUILDDIR=%FREETYPEDIR%\build_vs2015
IF NOT EXIST %BUILDDIR% ( mkdir %BUILDDIR% )
cd %BUILDDIR%

SET ERRORLEVEL=
cmake -DCMAKE_CONFIGURATION_TYPES="Debug;Release" -G "Visual Studio 14 Win64" ..
IF ERRORLEVEL 1 (ECHO Error configuring FreeType 2.6.3  projects. & cd /D %FILEDIR% & EXIT /B 1)

set DEBUG_BUILD=0
set RELEASE_BUILD=0
set BUILD_ERROR=0

set ERRORLEVEL=
msbuild freetype.sln /p:Platform=x64 /p:Configuration=Release
IF ERRORLEVEL 1 (SET RELEASE_BUILD=1 & set BUILD_ERROR=1)

set ERRORLEVEL=
msbuild freetype.sln /p:Platform=x64 /p:Configuration=Debug
IF %ERRORLEVEL% NEQ 0 (SET DEBUG_BUILD=1 & set BUILD_ERROR=1)

IF %RELEASE_BUILD% NEQ 0 (ECHO MSBuild of FreeType 2.6.3 Release project - FAIL)
IF %DEBUG_BUILD% NEQ 0  (ECHO MSBuild of FreeType 2.6.3 Debug project - FAIL)

cd /D %FILEDIR%
call DisplayDate.cmd
IF %BUILD_ERROR% NEQ 0 (ECHO STATUS: FAIL &  ENDLOCAL & EXIT /B 1)
ENDLOCAL
ECHO STATUS: SUCCESS
