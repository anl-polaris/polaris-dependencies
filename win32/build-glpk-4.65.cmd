@ECHO OFF

SETLOCAL

IF NOT "%1" == "" (
	set BASEDIR=%1
) ELSE IF NOT "%POLARIS_DEPS_DIR%" == "" (
	  set BASEDIR=%POLARIS_DEPS_DIR%
) ELSE (
	set BASEDIR=c:\opt\polarisdeps\msvc-15.0
)

:: get our slashes all straightened out :)
set a=%BASEDIR%
set a=%a:/=\%
echo %a%
set BASEDIR=%a%

set FILEDIR=%~dp0..\

IF NOT EXIST %BASEDIR% (mkdir %BASEDIR%)

:: Download and expand source files
set GLPKTARFILE=%BASEDIR%\glpk-4.65.tar.gz
set GLPKDIR=%BASEDIR%\glpk-4.65

echo file=%GLPKTARFILE%
echo dir=%GLPKDIR%

set DEBUG_BUILD=0
set RELEASE_BUILD=0
set BUILD_ERROR=0

IF NOT EXIST %GLPKTARFILE% (
	set ERRORLEVEL=
	cd /D %BASEDIR%
	%FILEDIR%utils\wget --show-progress=off -O %GLPKTARFILE% http://ftp.gnu.org/gnu/glpk/glpk-4.65.tar.gz
	IF ERRORLEVEL 1 ( ECHO Download of '%GLPKTARFILE%' - FAIL  & ECHO STATUS: FAIL & ENDLOCAL & EXIT /B 1 )
) ELSE (
	ECHO GLPK file already exists
)


IF NOT EXIST %GLPKDIR% (
	%FILEDIR%utils\7-Zip\7z x %GLPKTARFILE% -so | %FILEDIR%utils\7-Zip\7z x -si -ttar -o%BASEDIR%
	cd %GLPKDIR%\w64\
	@echo | call Build_GLPK_with_VC14_DLL
	IF ERRORLEVEL 1 ( ECHO Extraction of '%GLPKTARFILE%' - FAIL  & ECHO STATUS: FAIL & ENDLOCAL & EXIT /B 1 )
) ELSE (
	ECHO GLPK directory already exists
)

cd %FILEDIR%

