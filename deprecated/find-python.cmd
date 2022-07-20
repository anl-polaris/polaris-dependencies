@echo off
IF NOT "%MYPYTHONPATH%" == "" ( ECHO %MYPYTHONPATH% & EXIT /B 0 )
REM SET MYPYTHONPATH=
REM echo Python interpreter accessible through the system PATH:
REM where python
REM if not errorlevel 1 (
    REM python -c "from __future__ import print_function; import sys; print(sys.version)"
	REM FOR /F "tokens=* USEBACKQ" %%F IN (`where python`) DO ( IF NOT "%MYPYTHONPATH%" == "" (SET MYPYTHONPATH=%%F) )
REM )
REM IF NOT "%MYPYTHONPATH%" == "" (ECHO %MYPYTHONPATH% & EXIT /B 0)
echo ---
echo PythonCore registered installation:
reg query HKLM\Software\Python\PythonCore\2.7\InstallPath /ve >nul 2>&1
if errorlevel 1 (
    echo No "HKLM\Software\Python\PythonCore\2.7" registry key found
) else (
	for /f "skip=2 tokens=1,2*" %%i in ('reg query HKLM\Software\Python\PythonCore\2.7\InstallPath /ve 2^>nul') do set "handler=%%k"
	if "%handler%"=="(value not set)" (
		echo No install path set for python 2.7
	) else (
		set MYPYTHONPATH=%handler%python.exe
	)
)
IF NOT "%MYPYTHONPATH%" == "" ( ECHO %MYPYTHONPATH% & EXIT /B 0 )
:: Not found
EXIT /B 1