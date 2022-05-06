set install_dir=%1\build2

bpkg create -d odb-2.5.0-compiler cc  --wipe -V^
  config.cxx=g++^
  config.cc.coptions=-O2^
  config.install.root=%install_dir%

cd odb-2.5.0-compiler

bpkg build odb@https://pkg.cppget.org/1/beta --yes --trust-yes
bpkg test odb 
bpkg install odb

where odb
odb --version

cd ..