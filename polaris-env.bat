rem @echo off
IF NOT "%1" == "" (
	set POLARIS_DEPS_DIR=%1
) ELSE IF NOT "%POLARIS_DEPS_DIR%" == "" (
	  echo POLARIS_DEPS_DIR already set to %POLARIS_DEPS_DIR%
	  exit /B 0
) ELSE (
	set POLARIS_DEPS_DIR=%~dp0
)

::Does string have a trailing slash? if so remove it 
IF %POLARIS_DEPS_DIR:~-1%==\ SET POLARIS_DEPS_DIR=%POLARIS_DEPS_DIR:~0,-1%
set POLARIS_DEPS_DIR=%POLARIS_DEPS_DIR:\=/%
set PATH=%POLARIS_DEPS_DIR%/bin;%PATH%
