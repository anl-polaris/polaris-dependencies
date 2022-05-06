@ECHO OFF
SETLOCAL

set hour=%time:~0,2%
if "%hour:~0,1%" == " " set hour=0%hour:~1,1%
set min=%time:~3,2%
if "%min:~0,1%" == " " set min=0%min:~1,1%
set secs=%time:~6,2%
if "%secs:~0,1%" == " " set secs=0%secs:~1,1%

set year=%date:~-4%
:: On WIN2008R2 e.g. I needed to make your 'set month=%date:~3,2%' like below ::otherwise 00 appears for MONTH

set month=%date:~4,2%
if "%month:~0,1%" == " " set month=0%month:~1,1%
set day=%date:~7,2%
if "%day:~0,1%" == " " set day=0%day:~1,1%

echo %year%-%month%-%day% %hour%:%min%:%secs%

ENDLOCAL