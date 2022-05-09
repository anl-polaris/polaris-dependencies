@ECHO OFF

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

IF NOT EXIST %BASEDIR% (mkdir %BASEDIR%)

:: Download and expand source files
set BOOSTZIPFILE=%BASEDIR%\boost_1_71_0.zip
set BOOSTDIR=%BASEDIR%\boost_1_71_0

echo file=%BOOSTZIPFILE%
echo dir=%BOOSTDIR%

set DEBUG_BUILD=0
set RELEASE_BUILD=0
set BUILD_ERROR=0

IF NOT EXIST %BOOSTZIPFILE% (
	set ERRORLEVEL=
	cd /D %BASEDIR%
	%FILEDIR%utils\wget --show-progress=off -O %BOOSTZIPFILE% "https://boostorg.jfrog.io/artifactory/main/release/1.71.0/source/boost_1_71_0.zip"
	IF ERRORLEVEL 1 ( ECHO Download of '%BOOSTZIPFILE%' - FAIL  & ECHO STATUS: FAIL & ENDLOCAL & EXIT /B 1 )
) ELSE (
	ECHO Boost file already exists
)

iF NOT EXIST %BOOSTDIR% (
	%FILEDIR%utils\7-Zip\7z x %BOOSTZIPFILE%
	IF ERRORLEVEL 1 ( ECHO Extraction of '%BOOSTZIPFILE%' - FAIL  & ECHO STATUS: FAIL & ENDLOCAL & EXIT /B 1 )
) ELSE (
	ECHO Boost directory already exists
)


:: if you want to use boost libraries (as opposed to just headers)
:: uncomment the commands here:

::cd /D %BOOSTDIR%
::call bootstrap.bat

::set ERRORLEVEL=
::b2 address-model=64 link=shared,static variant=release install --prefix=%BOOSTDIR% --without-python
::IF ERRORLEVEL 1 (SET RELEASE_BUILD=1 & set BUILD_ERROR=1)

::set ERRORLEVEL=
::b2 address-model=64 link=shared,static variant=debug install --prefix=%BOOSTDIR% --without-python
::IF ERRORLEVEL 1 (SET DEBUG_BUILD=1 & set BUILD_ERROR=1)

::cd /D %BOOSTDIR%
::ren lib lib64-msvc-14.0

::IF %RELEASE_BUILD% NEQ 0 (ECHO MSBuild of Boost 1.60.0 Release project - FAIL )
::IF %DEBUG_BUILD% NEQ 0  (ECHO MSBuild of Boost 1.60.0 Debug project - FAIL )

cd /D %FILEDIR%
call DisplayDate.cmd
IF %BUILD_ERROR% NEQ 0 (ECHO STATUS: FAIL & ENDLOCAL & EXIT /B 1)
ENDLOCAL
ECHO STATUS: SUCCESS
