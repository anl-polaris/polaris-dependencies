set install_dir=%1

bpkg create -d odb-msvc-release cc  --wipe -V^
  config.cxx=cl^
  "config.cc.coptions=/O2 /MD"^
  config.install.root=%install_dir%\odb-2.5.0-release
  
cd odb-msvc-release
bpkg add https://pkg.cppget.org/1/beta --trust-yes
bpkg fetch --trust-yes
bpkg build --yes libodb
bpkg build --yes libodb-sqlite
bpkg install --all --recursive

cd ..