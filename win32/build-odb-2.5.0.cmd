::@ECHO OFF

SETLOCAL

IF NOT "%1" == "" (
	set BASEDIR=%1
) ELSE IF NOT "%POLARIS_DEPS_DIR%" == "" (
	  set BASEDIR=%POLARIS_DEPS_DIR%
) ELSE (
	set BASEDIR=c:\opt\polarisdeps
)

:: get our slashes all straightened out :)
set a=%BASEDIR%
set a=%a:/=\%
echo %a%
set BASEDIR=%a%

set FILEDIR=%~dp0..\

IF NOT EXIST %BASEDIR% ( mkdir %BASEDIR% )
 
:: Download and expand source files
set BUILD2_BUILD=0
set ODB_COMPILER_BUILD=0
set ODB_RELEASE_BUILD=0
set ODB_DEBUG_BUILD=0
set BUILD_ERROR=0

cd /D %~dp0

set ERRORLEVEL=
call build-build2-0.14.0.cmd %BASEDIR%
IF ERRORLEVEL 1 (SET BUILD2_BUILD=1 & set BUILD_ERROR=1)

set "PATH=%BASEDIR%\build2\bin;%PATH%"

cd /D %~dp0

set ERRORLEVEL=
call %~dp0build-odb-compiler.cmd %BASEDIR%
IF ERRORLEVEL 1 (SET ODB_COMPILER_BUILD=1 & set BUILD_ERROR=1)

cd /D %~dp0

set ERRORLEVEL=
call %~dp0build-odb-release.cmd %BASEDIR%
IF ERRORLEVEL 1 (SET ODB_RELEASE_BUILD=1 & set BUILD_ERROR=1)

cd /D %~dp0

set ERRORLEVEL=
call %~dp0build-odb-debug.cmd %BASEDIR%
IF ERRORLEVEL 1 (SET ODB_DEBUG_BUILD=1 & set BUILD_ERROR=1)

IF %ODB_DEBUG_BUILD% 		NEQ 0 (ECHO Build od ODB Debug project - FAIL)
IF %ODB_RELEASE_BUILD%		NEQ 0 (ECHO Build of ODB Release project - FAIL)

cd /D %FILEDIR%
call DisplayDate.cmd
IF %BUILD_ERROR% NEQ 0 (ECHO STATUS: FAIL & ENDLOCAL & EXIT /B 1)
ENDLOCAL
ECHO STATUS: SUCCESS
