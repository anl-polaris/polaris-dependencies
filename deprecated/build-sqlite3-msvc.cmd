@echo off
:: Release DLL
cl.exe sqlite3.c -O2 -DSQLITE_API=__declspec(dllexport) -DSQLITE_ENABLE_UNLOCK_NOTIFY -DSQLITE_ENABLE_FTS4 -DSQLITE_ENABLE_RTREE -DSQLITE_ENABLE_COLUMN_METADATA -link -dll -out:sqlite3_vc140_3_11_0.dll

:: Debug DLL
cl.exe sqlite3.c -Od -Zi -DSQLITE_API=__declspec(dllexport) -DSQLITE_ENABLE_UNLOCK_NOTIFY -DSQLITE_ENABLE_FTS4 -DSQLITE_ENABLE_RTREE -DSQLITE_ENABLE_COLUMN_METADATA -link -dll -out:sqlite3_vc140_gd_3_11_0.dll

:: Release Static Lib
cl.exe sqlite3.c /c /MD /Os -DSQLITE_ENABLE_UNLOCK_NOTIFY -DSQLITE_ENABLE_FTS4 -DSQLITE_ENABLE_RTREE -DSQLITE_ENABLE_COLUMN_METADATA /Folibsqlite3_vc140_3_11_0.obj
lib.exe  /OUT:libsqlite3_vc140_3_11_0.lib libsqlite3_vc140_3_11_0.obj

:: Debug Static Lib
cl.exe sqlite3.c /c /MDd /Od /Zi -DSQLITE_ENABLE_UNLOCK_NOTIFY -DSQLITE_ENABLE_FTS4 -DSQLITE_ENABLE_RTREE -DSQLITE_ENABLE_COLUMN_METADATA /Folibsqlite3_vc140_gd_3_11_0.obj
lib.exe  /OUT:libsqlite3_vc140_gd_3_11_0.lib libsqlite3_vc140_gd_3_11_0.obj
