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
set a=%a:\=\%
echo %a%
set BASEDIR=%a%

set FILEDIR=%~dp0..\

IF NOT EXIST %BASEDIR% (mkdir %BASEDIR%)

:: Download and expand source files
set SCRIPTSDIR=%cd%
set TENSORFLOWSRC=%BASEDIR%\tensorflow_src
set TFLITEDIR=%BASEDIR%\tflite-2.4.0

rmdir /s /q %TENSORFLOWSRC%
rmdir /s /q %TFLITEDIR%

git clone https://github.com/tensorflow/tensorflow.git %TENSORFLOWSRC%
cd %TENSORFLOWSRC%
git checkout r2.5

copy %SCRIPTSDIR%\tflite\tflite_cmake.txt %TENSORFLOWSRC%\tensorflow\lite\CMakeLists.txt
copy %SCRIPTSDIR%\tflite\session_edit.h %TENSORFLOWSRC%\tensorflow\core\public\session.h
copy %SCRIPTSDIR%\tflite\session_options_edit.h %TENSORFLOWSRC%\tensorflow\core\public\session_options.h

mkdir %TFLITEDIR%
cd %TFLITEDIR%

cmake -G "Visual Studio 16 2019" ..\tensorflow_src\tensorflow\lite
cmake --build . -j --config Debug
cmake --build . -j --config Release

mkdir %TFLITEDIR%\include
mkdir %TFLITEDIR%\include\flatbuffers
xcopy %TFLITEDIR%\flatbuffers\include\flatbuffers\* %TFLITEDIR%\include\flatbuffers /E/H
mkdir %TFLITEDIR%\include\absl
xcopy %TFLITEDIR%\abseil-cpp\absl\* %TFLITEDIR%\include\absl  /E/H
mkdir %TFLITEDIR%\include\tensorflow\lite
xcopy %TENSORFLOWSRC%\tensorflow\lite\* %TFLITEDIR%\include\tensorflow\lite  /E/H

rmdir /s /q %TENSORFLOWSRC%

