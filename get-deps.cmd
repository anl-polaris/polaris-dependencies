@ECHO OFF

SETLOCAL

IF NOT "%1" == "" (
	set BASEDIR=%1
	call polaris-env.bat %1
) ELSE IF NOT "%POLARIS_DEPS_DIR%" == "" (
	set BASEDIR=%POLARIS_DEPS_DIR%
) ELSE (
	set BASEDIR=C:\opt\polarisdeps
	call polaris-env.bat C:\opt\polarisdeps
)

SET COMPILER_VER=msvc-15.0
SET DEPSDIR=%BASEDIR%\%COMPILER_VER%

echo DEPSDIR=%DEPSDIR%
IF NOT EXIST %DEPSDIR% (
	MKDIR %DEPSDIR%
)
COPY polaris-env.bat %DEPSDIR%

REM  see if Vsual Studio is already set
SET VCROOT=
IF "%VSINSTALLDIR%" == "" (
	call find-msvc.bat 15
    IF ERRORLEVEL 1 exit /B %ERRORLEVEL%
) ELSE IF NOT "%VisualStudioVersion%" == "15.0" (
	echo "Visual Studio 15.0 (2017) is required"
	exit /B 1
) ELSE IF NOT "%Platform%" == "x64" (
	echo "Visual Studio 15.0 (2017) must be set for X64 platform"
	exit /B 1
)

IF NOT "%VCROOT%" == "" (
    call "%VCROOT%\vcvarsall.bat" amd64
)

:: call this because for some goofy reason it fails on the first call - but then works
call find-python.cmd > nul 2>&1

:: get our slashes all straightened out :)
set a=%DEPSDIR%
set a=%a:/=\%
echo DEPSDIR=%a% with slashes fixed
set DEPSDIR=%a%

SET LOGDIR=%DEPSDIR%\builds
IF NOT EXIST %LOGDIR% ( mkdir %LOGDIR% )
IF EXIST %LOGDIR%\boost_build.log (DEL %LOGDIR%\boost_build.log)
IF EXIST %LOGDIR%\odb_build.log (DEL %LOGDIR%\odb_build.log)
IF EXIST %LOGDIR%\gtest_build.log (DEL %LOGDIR%\gtest_build.log)
IF EXIST %LOGDIR%\rapidjson_build.log (DEL %LOGDIR%\rapisjson_build.log)
IF EXIST %LOGDIR%\log4cpp_build.log (DEL %LOGDIR%\log4cpp_build.log)
IF EXIST %LOGDIR%\tflite_build.log (DEL %LOGDIR%\tflite_build.log)
IF EXIST %LOGDIR%\glpk_build.log (DEL %LOGDIR%\glpk_build.log)

set BUILD_ERROR=0

cd /D %~dp0
set ERRORLEVEL=
call %~dp0build-odb-2.5.0.cmd %DEPSDIR%  2>&1 | %~dp0utils\tee %LOGDIR%\odb_build.log 2>&1
IF %ERRORLEVEL% NEQ 0 (ECHO Build of ODB 2.5.0  - FAIL & set BUILD_ERROR=1)

cd /D %~dp0
set ERRORLEVEL=
call %~dp0build-boost-1.71.0.cmd %DEPSDIR%	2>&1 | %~dp0utils\tee %LOGDIR%\boost_build.log 2>&1
IF %ERRORLEVEL% NEQ 0 (ECHO Build of Boost 1.71.0  - FAIL  & set BUILD_ERROR=1)

cd /D %~dp0
set ERRORLEVEL=
call %~dp0build-gtest-1.7.0.cmd %DEPSDIR% 2>&1 | %~dp0utils\tee %LOGDIR%\gtest_build.log 2>&1
IF %ERRORLEVEL% NEQ 0 (ECHO Build of GTest 1.7.0 - FAIL  & set BUILD_ERROR=1)

cd /D %~dp0
set ERRORLEVEL=
call %~dp0build-rapidjson-1.1.0.cmd %DEPSDIR% 2>&1 | %~dp0utils\tee %LOGDIR%\rapidjson_build.log 2>&1
IF %ERRORLEVEL% NEQ 0 (ECHO Build of RapidJson 1.1.0 - FAIL  & set BUILD_ERROR=1)

cd /D %~dp0
set ERRORLEVEL=
call %~dp0build-log4cpp-1.1.3.cmd %DEPSDIR%	2>&1 | %~dp0utils\tee %LOGDIR%\log4cpp_build.log 2>&1
IF %ERRORLEVEL% NEQ 0 (ECHO Build of log4cpp 1.1.3 - FAIL  & set BUILD_ERROR=1)

cd /D %~dp0
set ERRORLEVEL=
call %~dp0build-tflite-2.4.0.cmd %DEPSDIR% 2>&1 | %~dp0utils\tee %LOGDIR%\tflite_build.log 2>&1
IF %ERRORLEVEL% NEQ 0 (ECHO Build of TensorflowLite 2.4.0 - FAIL  & set BUILD_ERROR=1)

cd /D %~dp0
set ERRORLEVEL=
call %~dp0build-glpk-4.65.cmd %DEPSDIR%	2>&1 | %~dp0utils\tee %LOGDIR%\glpk_build.log 2>&1
IF %ERRORLEVEL% NEQ 0 (ECHO Build of GLPK 4.65  - FAIL  & set BUILD_ERROR=1)

cd /D %~dp0
:: as a convenience we copy all dll's to a single folder to save on path entries
IF NOT EXIST %DEPSDIR%\bin ( mkdir %DEPSDIR%\bin )

IF NOT EXIST %DEPSDIR%\bin\Release ( mkdir %DEPSDIR%\bin\Release )
COPY %DEPSDIR%\odb-2.5.0-release\bin\*				%DEPSDIR%\bin\Release
COPY %DEPSDIR%\glpk-4.65\w64\glpk_4_65.dll			%DEPSDIR%\bin\Release
COPY %DEPSDIR%\tflite-2.4.0\tensorflow\lite\*		%DEPSDIR%\bin\Release

IF NOT EXIST %DEPSDIR%\bin\RelWithDebInfo ( mkdir %DEPSDIR%\bin\RelWithDebInfo )
COPY %DEPSDIR%\odb-2.5.0-release\bin\*		%DEPSDIR%\bin\RelWithDebInfo
COPY %DEPSDIR%\glpk-4.65\w64\glpk_4_65.dll			%DEPSDIR%\bin\RelWithDebInfo
COPY %DEPSDIR%\tflite-2.4.0\tensorflow\lite\*		%DEPSDIR%\bin\RelWithDebInfo

IF NOT EXIST %DEPSDIR%\bin\Debug ( mkdir %DEPSDIR%\bin\Debug )
COPY %DEPSDIR%\odb-2.5.0-debug\bin\*				%DEPSDIR%\bin\Debug
COPY %DEPSDIR%\glpk-4.65\w64\glpk_4_65.dll			%DEPSDIR%\bin\Debug
COPY %DEPSDIR%\tflite-2.4.0\tensorflow\lite\*		%DEPSDIR%\bin\Debug

cd /D %~dp0
call DisplayDate.cmd
IF %BUILD_ERROR% NEQ 0 (ECHO STATUS: FAIL & ENDLOCAL & EXIT /B 1)
ENDLOCAL
ECHO STATUS: SUCCESS
