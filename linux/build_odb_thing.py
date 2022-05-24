import sys, os, subprocess, pathlib, shutil, getopt, shlex
from pathlib import Path
from os.path import join, dirname, abspath
import contextlib

@contextlib.contextmanager
def chdir(path):
    """Changes working directory and returns to previous on exit."""
    prev_cwd = Path.cwd()
    os.chdir(path)
    try:
        yield
    finally:
        os.chdir(prev_cwd)

def build_odb(deps_dir, version):
     #deps_dir = abspath(sys.argv[1])
     #version = sys.argv[2]
     #thing = sys.argv[3]
    build_odb_thing(deps_dir, version, "compiler")
    build_odb_thing(deps_dir, version, "debug")
    build_odb_thing(deps_dir, version, "release")

def build_odb_thing(deps_dir, version, thing):
    build_dir = create_bpkg_build_dir(deps_dir, version, thing)
    with chdir(build_dir):
        if thing == "compiler":
            run("bpkg build odb@https://pkg.cppget.org/1/beta --yes --trust-yes")
            run("bpkg test odb")
            run("bpkg install odb")
        elif (thing == "debug") or (thing == "release"):
            run("bpkg add https://pkg.cppget.org/1/beta")
            run("bpkg fetch --trust-yes")
            run("bpkg build --yes libodb")
            run("bpkg build --yes libodb-sqlite")
            # run("bpkg build libodb-pgsql")
            # run("bpkg build libodb-mysql")
            run("bpkg install --all --recursive")
        else:
            raise RuntimeError(f"Don't know how build odb-thing: {thing}")
    

def create_bpkg_build_dir(deps_dir, version, thing):
    # os.environ['PATH'] = "/home/jamie/git/polaris-dependencies/tmp/gcc-9.4.0/build2-build/tmp/gcc-9.4.0/build2/bin" + os.pathsep + os.environ['PATH']

    install_dir = join(deps_dir, f"odb-{version}-{thing}")
    build_dir = join(deps_dir, f"build-odb-{version}-{thing}")
    lib_dir=join(install_dir, 'lib')
    mkdir_p(lib_dir)
    mkdir_p(build_dir)


    opt_level="-O3"
    if thing == "debug":
        opt_level = "-O0"

    cmd = f"bpkg create -d {build_dir} cc --wipe "
    cmd += "config.cxx=g++ "
    cmd += f"config.cc.coptions={opt_level} "
    cmd += "config.cxx.coptions=-std=c++17 "
    cmd += f"config.bin.rpath={lib_dir} "
    cmd += f"config.install.root={install_dir} "
    if thing == "debug":
        cmd += "config.cc.coptions=-g "
    run(cmd)
    return build_dir

    with chdir(build_dir): 
        print(os.getcwd())
        run("bpkg build odb@https://pkg.cppget.org/1/beta --yes --trust-yes")
        run("bpkg test odb")
        run("bpkg install odb")

def run(x):
    print(f"x = {x}")
    subprocess.run(shlex.split(x))

def mkdir_p(x):
    pathlib.Path(x).mkdir(parents=True, exist_ok=True)

# CXX=g++
# gcc_ver=$(sh $filedir/../gcc_ver.sh $CXX)

# mkdir -p $gcc_ver-compiler

# install_root=$1
# install_path=$install_root/odb-2.5.0-compiler
# lib_path=$install_path/lib
# build_folder=build-odb-2.5.0-$gcc_ver-compiler
# plugin_dir=/blues/gpfs/software/centos7/spack-latest/opt/spack/linux-centos7-x86_64/gcc-6.5.0/gcc-10.2.0-z53hda3/lib/gcc/x86_64-pc-linux-gnu/10.2.0/plugin/include
# #BPKG_BIN=$install_root/build2/bin/bpkg
# mkdir -p $install_path
# cd $install_root
# bpkg create -d $build_folder cc  --wipe         \
#   config.cxx=$CXX                  		\
#   config.cc.coptions=-O3          		\
#   config.cxx.coptions=-std=c++17	  	\
#   config.cxx.coptions=-I${plugin_dir}	   	\
#   config.bin.rpath=$lib_path 			\
#   config.install.root=$install_path

# cd $build_folder
# bpkg build odb@https://pkg.cppget.org/1/beta --yes --trust-yes
# bpkg test odb
# bpkg install odb 



# if __name__ == "__main__":
#     main()