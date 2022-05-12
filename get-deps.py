import sys, os, subprocess, pathlib, shutil, getopt
from compiler_version import get_linux_compiler, get_windows_compiler

# python ./get-deps.py -c {compiler} -d {depsdir}
# python ./get-deps.py -d {depsdir} -c {compiler} 
# python ./get-deps.py --dependencies {depsdir} --compiler {compiler} 

def main():
    setup_variables()
    build_dep("log4cpp", "1.1.3")
    build_dep("tflite", "2.4.0")
    build_dep("glpk", "4.65")
    build_dep("boost", "1.71.0")
    build_dep("rapidjson", "1.1.0")    
    build_dep("odb", "2.5.0")
    build_dep("gtest", "1.11.0")
    
    if operatingSystem == "win32":
        copy_files()

    summarise()

def setup_variables():
    # What OS are we using?
    global operatingSystem
    if sys.platform == "linux" or sys.platform == "linux2":
        operatingSystem = "linux"
    elif sys.platform == "win32":
        operatingSystem = "win32"
    elif sys.platform == "darwin":
        print(f"POLARIS does not support MacOS")
        quit()
    else:
        print(f"Platform {sys.platform} not supported")
        quit()
        
    # polarisdeps directory for our git repository, ie. where get-deps lives
    global working_directory
    working_directory=os.getcwd()
        
    # set default values for directory and compiler before checking input
    if "POLARIS_DEPS_DIR" in os.environ:
        base_directory=os.environ["POLARIS_DEPS_DIR"]
    else:
        if operatingSystem == "linux":
            print("Defaulting the dependency directory to /opt/polaris/deps")        
            base_directory="/opt/polaris/deps"
        else:            
            print("Defaulting the dependency directory to C:\\opt\\polaris\\deps\\")        
            base_directory="C:\\opt\\polaris\deps\\"
    
    # compiler should be able to call MSVC on Windows
    global compiler
    if operatingSystem == "linux":
        compiler="gcc"
    else:
        compiler="15"
        
    # Grab command line arguments (if any)
    argv = sys.argv[1:]  
    opts, args = getopt.getopt(argv, "c:d:",["compiler =", "dependencies ="])
    for opt, arg in opts:
        if opt in ['-c', '--compiler']:
            compiler=arg
            print(f"Compiler input = {arg}")
        elif opt in ['-d', '--dependencies']:
            base_directory=arg
            print(f"Dependencies input = {arg}")
    
    global compiler_version
    if operatingSystem == "linux":
        compiler_version=get_linux_compiler(compiler)
    else:
        compiler_version=get_windows_compiler(compiler)
    if compiler_version == "":
        print("No compiler found")
        quit()
        
    global verbose
    global deps_directory
    global logs_directory
    global status_directory
    
    verbose=0    
    deps_directory=os.path.normpath(f"{base_directory}/{compiler_version}/")
    logs_directory=os.path.normpath(f"{deps_directory}/builds/")
    status_directory=os.path.normpath(f"{deps_directory}/build_status/")

    print(f"Building in: {deps_directory}")
    
    if not os.path.exists(deps_directory):
        pathlib.Path(deps_directory).mkdir(parents=True, exist_ok=True)
    if not os.path.exists(logs_directory):
        os.mkdir(logs_directory)
    if not os.path.exists(status_directory):
        os.mkdir(status_directory)

def build_dep(dep, version):
    log_file=os.path.normpath(logs_directory+f"/{dep}_{version}_build.log")
    if os.path.exists(status_directory+f"/{dep}-{version}-success"):
        print(f"Build of {dep} {version}  - SUCCESS (already built)")
        return

    # Should call cmd scripts on Windows
    print(f"Building {dep}-{version}")
    if verbose == 0:
        f=open(log_file, "w")
        if operatingSystem == "linux":
            output=subprocess.run([f"{working_directory}/linux/build-{dep}-{version}.sh", f"{deps_directory}", f"{compiler}"], 
                stdout=f, stderr=subprocess.STDOUT)
        else:
            command = [f"{working_directory}\\win32\\build-{dep}-{version}.cmd", f"{deps_directory}"]
            output=subprocess.run(command, shell=True, stdout=f, stderr=subprocess.STDOUT)
        status=output.returncode
        f.close()
    else:
        f=open(log_file, "w")
        if operatingSystem == "linux":
            output=subprocess.run([f"{working_directory}/linux/build-{dep}-{version}.sh", f"{deps_directory}", f"{compiler}"], 
                shell=True, stdout=f, stderr=subprocess.STDOUT)
        else:
            command = [f"{working_directory}\\win32\\build-{dep}-{version}.cmd", f"{deps_directory}"]
            output=subprocess.run(command, shell=True, stdout=f, stderr=subprocess.STDOUT)
        status=output.returncode
        f.close()
    if status != 0:
        print(f"Build of {dep} {version}  - FAIL")
        fp = open(f"{status_directory}/{dep}-{version}-fail", 'w')
        fp.close()
    else:
        print(f"Build of {dep} {version}  - SUCCESS")
        if os.path.exists(f"{status_directory}/{dep}-{version}-fail"):
            os.remove(f"{status_directory}/{dep}-{version}-fail")
        fp = open(f"{status_directory}/{dep}-{version}-success", 'w')
        fp.close()

def copy_files():
    if not os.path.exists(f"{deps_directory}/bin/"):
        os.makedirs(f"{deps_directory}/bin/")        
    bin_folders=[f"{deps_directory}/bin/Release/", f"{deps_directory}/bin/RelWithDebug/", f"{deps_directory}/bin/Debug/"]
    for folder in bin_folders:
        if not os.path.exists(folder):
            os.makedirs(folder)
        # Split up odb by Rel or Debug
        if "Rel" in folder:
            if os.path.exists(f"{deps_directory}/odb-2.5.0-release/bin/") and os.path.exists(f"{status_directory}/odb-2.5.0-success"):
                shutil.copytree(f"{deps_directory}/odb-2.5.0-release/bin/", f"{deps_directory}/bin/Release/", dirs_exist_ok=True)
                shutil.copytree(f"{deps_directory}/odb-2.5.0-release/bin/", f"{deps_directory}/bin/RelWithDebug/", dirs_exist_ok=True)
        else:
            if os.path.exists(f"{deps_directory}/odb-2.5.0-debug/bin/") and os.path.exists(f"{status_directory}/odb-2.5.0-success"):
                shutil.copytree(f"{deps_directory}/odb-2.5.0-debug/bin/", f"{deps_directory}/bin/Debug/", dirs_exist_ok=True)           
        # Copy glpk and tflite regardless of version
        if os.path.isfile(f"{deps_directory}/glpk-4.65/w64/glpk_4_65.dll") and os.path.exists(f"{status_directory}/glpk-4.65-success"):
            shutil.copy(f"{deps_directory}/glpk-4.65/w64/glpk_4_65.dll", f"{folder}/glpk_4_65.dll")    
        # TFLite has some weird permissions issue, adding checks to avoid issues...
        if os.path.exists(f"{deps_directory}/tflite-2.4.0/tensorflow/lite/") and os.path.exists(f"{status_directory}/tflite-2.4.0-success"):
            if not os.path.exists(f"{folder}/tensorflowlite.dll"):
                shutil.copy(f"{deps_directory}/tflite-2.4.0/tensorflow/lite/tensorflowlite.dll", f"{folder}/tensorflowlite.dll")
            if not os.path.exists(f"{folder}/tensorflowlite.dll.if.lib"):
                shutil.copy(f"{deps_directory}/tflite-2.4.0/tensorflow/lite/tensorflowlite.dll.if.lib", f"{folder}/tensorflowlite.dll.if.lib")
            if not os.path.exists(f"{folder}/tensorflowlite.pdb"):
                shutil.copy(f"{deps_directory}/tflite-2.4.0/tensorflow/lite/tensorflowlite.pdb", f"{folder}/tensorflowlite.pdb")
    

def summarise():
    print("\n--------------------------")  
    print("        Summary")
    print("--------------------------\n")
    print(f"Checking status files from {status_directory}")
    for filename in os.listdir(status_directory):
        name_list=filename.split('-')
        lib=name_list[0]
        version=name_list[1]
        status=name_list[2]
        if status == "success":
          symbol="✔"
        else:
          symbol="✘"
        print(f"{symbol}  {lib} {version} {status}")

if __name__ == "__main__":
    main()