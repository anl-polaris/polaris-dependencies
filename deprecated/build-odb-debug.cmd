set install_dir=%1

bpkg create -d odb-msvc-debug cc  --wipe -V^
  config.cxx=cl^
  "config.cc.coptions=/Od /MDd /Zi"^
  config.cc.loptions=/DEBUG^
  config.install.root=%install_dir%\odb-2.5.0-debug
  
cd odb-msvc-debug
bpkg add https://pkg.cppget.org/1/beta --trust-yes
bpkg fetch --trust-yes
bpkg build --yes libodb
bpkg build --yes libodb-sqlite
bpkg install --all --recursive

cd ..