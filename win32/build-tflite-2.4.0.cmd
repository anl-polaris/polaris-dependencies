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
set a=%a:\=\%
echo %a%
set BASEDIR=%a%

set FILEDIR=%~dp0..\

IF NOT EXIST %BASEDIR% (mkdir %BASEDIR%)

:: Download and expand source files
set SCRIPTSDIR=%cd%
set ZIPFILE=%BASEDIR%\tflite-2.4.0.zip
set TFLITEDIR=%BASEDIR%\tflite-2.4.0

IF NOT EXIST %ZIPFILE% (
	set ERRORLEVEL=
	cd /D %BASEDIR%
	%FILEDIR%utils\wget --show-progress=off -O %ZIPFILE% https://github.com/anl-polaris/polaris-dependencies/releases/download/Tensorflow/tflite-2.4.0.zip
	IF ERRORLEVEL 1 ( ECHO Download of '%ZIPFILE%' - FAIL  & ECHO STATUS: FAIL & ENDLOCAL & EXIT /B 1 )
) ELSE (
	ECHO TFLite zip file already exists
)


IF NOT EXIST %TFLITEDIR% (
	%FILEDIR%utils\7-Zip\7z x %ZIPFILE%
	IF ERRORLEVEL 1 ( ECHO Extraction of '%ZIPFILE%' - FAIL  & ECHO STATUS: FAIL & ENDLOCAL & EXIT /B 1 )
) ELSE (
	ECHO TFLite directory already exists
)



