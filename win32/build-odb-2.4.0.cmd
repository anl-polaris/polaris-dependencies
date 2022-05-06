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

IF NOT EXIST %BASEDIR% ( mkdir %BASEDIR% )

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

:: Download and expand source files
set ODBZIPFILE=%BASEDIR%\odb-2.4.0-i686-windows.zip
set LIBODBZIPFILE=%BASEDIR%\libodb-2.4.0.zip
set ODBSQLITEBZIPFILE=%BASEDIR%\libodb-sqlite-2.4.0.zip
set SQLITEZIPFILE=%BASEDIR%\sqlite-amalgamation-3110100.zip

set ODBDIR=%BASEDIR%\odb-2.4.0-i686-windows
set LIBODBDIR=%BASEDIR%\libodb-2.4.0
set LIBSQLITEDIR=%LIBODBDIR%\libodb-sqlite-2.4.0
set SQLITE3DIR=%LIBODBDIR%\sqlite-amalgamation-3110100

echo ODBZIPFILE=        %ODBZIPFILE%
echo LIBODBZIPFILE=     %LIBODBZIPFILE%
echo ODBSQLITEBZIPFILE= %ODBSQLITEBZIPFILE%
echo SQLITEZIPFILE=     %SQLITEZIPFILE%
echo ODBDIR=            %ODBDIR%
echo LIBODBDIR=         %LIBODBDIR%
echo LIBSQLITEDIR=      %LIBSQLITEDIR%
echo SQLITE3DIR=        %SQLITE3DIR%
echo filedir=           %~dp0

SET DOWNLOAD_ODB=0
SET DOWNLOAD_LIBODB=0
SET DOWNLOAD_SQLITE=0
SET DOWNLOAD_LIBSQLITE=0
set LIBODB_DEBUG_BUILD=0
set LIBODB_RELEASE_BUILD=0
set SQLITE_BUILD=0
set LIBSQLITE_DEBUG_BUILD=0
set LIBSQLITE_RELEASE_BUILD=0
set BUILD_ERROR=0

set ERRORLEVEL=
cd /D %BASEDIR%
%~dp0utils\wget --show-progress=off -O %ODBZIPFILE% "http://www.codesynthesis.com/download/odb/2.4/odb-2.4.0-i686-windows.zip"
%~dp0utils\unzip -o -q %ODBZIPFILE%
IF ERRORLEVEL 1 ( SET DOWNLOAD_ODB=1 & SET BUILD_ERROR=1 )

set ERRORLEVEL=
cd /D %BASEDIR%
%~dp0utils\wget --show-progress=off -O %LIBODBZIPFILE% "http://www.codesynthesis.com/download/odb/2.4/libodb-2.4.0.zip"
%~dp0utils\unzip -o -q %LIBODBZIPFILE%
IF ERRORLEVEL 1 ( SET DOWNLOAD_LIBODB=1 & SET BUILD_ERROR=1 )

set ERRORLEVEL=
IF NOT EXIST %LIBODBDIR% ( mkdir %LIBODBDIR% )
cd /D %BASEDIR%
%~dp0utils\wget --show-progress=off -O %ODBSQLITEBZIPFILE% "http://www.codesynthesis.com/download/odb/2.4/libodb-sqlite-2.4.0.zip"
%~dp0utils\unzip -o -q %ODBSQLITEBZIPFILE% -d %LIBODBDIR%
IF ERRORLEVEL 1 ( SET DOWNLOAD_LIBSQLITE=1 & SET BUILD_ERROR=1 )

set ERRORLEVEL=
IF NOT EXIST %LIBODBDIR% ( mkdir %LIBODBDIR% )
cd /D %BASEDIR%
%~dp0utils\wget --show-progress=off -O %SQLITEZIPFILE% "https://www.sqlite.org/2016/sqlite-amalgamation-3110100.zip"
%~dp0utils\unzip -o -q %SQLITEZIPFILE% -d %LIBODBDIR%
IF ERRORLEVEL 1 ( SET DOWNLOAD_SQLITE=1 & SET BUILD_ERROR=1 )

mkdir %LIBODBDIR%
echo copy %~dp0libodb-vc14.sln %LIBODBDIR%
copy %~dp0libodb-vc14.sln %LIBODBDIR%
copy %~dp0libodb-vc14.vcxproj %LIBODBDIR%\odb
cd /D %LIBODBDIR%

set ERRORLEVEL=
msbuild libodb-vc14.sln /p:Platform=x64 /p:Configuration=Release
IF ERRORLEVEL 1 (SET LIBODB_RELEASE_BUILD=1 & set BUILD_ERROR=1)

set ERRORLEVEL=
msbuild libodb-vc14.sln /p:Platform=x64 /p:Configuration=Debug
IF ERRORLEVEL 1 (SET LIBODB_DEBUG_BUILD=1 & set BUILD_ERROR=1)

mkdir %SQLITE3DIR%
cd /D %~dp0
copy build-sqlite3-msvc.cmd %SQLITE3DIR%
cd /D %SQLITE3DIR%

set ERRORLEVEL=
call build-sqlite3-msvc.cmd
IF ERRORLEVEL 1 (SET SQLITE_DEBUG_BUILD=1 & set BUILD_ERROR=1)

mkdir %LIBSQLITEDIR%
copy %~dp0libodb-sqlite-vc14.sln %LIBSQLITEDIR%
copy %~dp0libodb-sqlite-vc14.vcxproj %LIBSQLITEDIR%\odb\sqlite
cd /D %LIBSQLITEDIR%

set ERRORLEVEL=
msbuild libodb-sqlite-vc14.sln /p:Platform=x64 /p:Configuration=Release
IF ERRORLEVEL 1 (SET LIBSQLITE_RELEASE_BUILD=1 & set BUILD_ERROR=1)

set ERRORLEVEL=
msbuild libodb-sqlite-vc14.sln /p:Platform=x64 /p:Configuration=Debug
IF ERRORLEVEL 1 (SET LIBSQLITE_DEBUG_BUILD=1 & set BUILD_ERROR=1)

IF %DOWNLOAD_ODB% 				NEQ 0 (ECHO Download and Extract of '%ODBZIPFILE%' - FAIL)
IF %DOWNLOAD_LIBODB% 			NEQ 0 (ECHO Download and Extract of '%LIBODBZIPFILE%' - FAIL)
IF %DOWNLOAD_LIBSQLITE%			NEQ 0 (ECHO Download and Extract of '%ODBSQLITEBZIPFILE%' - FAIL)
IF %DOWNLOAD_SQLITE%			NEQ 0 (ECHO Download and Extract of '%SQLITEZIPFILE%' - FAIL)
IF %LIBODB_DEBUG_BUILD% 		NEQ 0 (ECHO MSBuild of libodb Debug project - FAIL)
IF %LIBODB_RELEASE_BUILD%		NEQ 0 (ECHO MSBuild of libodb Release project - FAIL)
IF %SQLITE_BUILD%				NEQ 0 (ECHO Build of sqlite3 project - FAIL)
IF %LIBSQLITE_RELEASE_BUILD%	NEQ 0 (ECHO MSBuild of libodb-sqlite Release project - FAIL)
IF %LIBSQLITE_DEBUG_BUILD% 		NEQ 0 (ECHO MSBuild of libodb-sqlite Debug project - FAIL)

cd /D %~dp0
call DisplayDate.cmd
IF %BUILD_ERROR% NEQ 0 (ECHO STATUS: FAIL & ENDLOCAL & EXIT /B 1)
ENDLOCAL
ECHO STATUS: SUCCESS
