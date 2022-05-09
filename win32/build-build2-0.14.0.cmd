set deps_dir=%1
set FILEDIR=%~dp0..\
mkdir %deps_dir%\build2-build
mkdir %deps_dir%\build2
cd /D %deps_dir%\build2-build
%FILEDIR%utils\wget --show-progress=off https://download.build2.org/0.14.0/build2-install-mingw-0.14.0.bat
build2-install-mingw-0.14.0.bat --yes --trust 70:64:FE:E4:E0:F3:60:F1:B4:51:E1:FA:12:5C:E0:B3:DB:DF:96:33:39:B9:2E:E5:C2:68:63:4C:A6:47:39:43 %deps_dir%\build2
cd /D %FILEDIR%