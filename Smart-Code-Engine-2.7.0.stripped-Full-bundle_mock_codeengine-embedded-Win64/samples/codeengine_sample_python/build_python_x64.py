#  Copyright (c) 2016-2025, Smart Engines Service LLC
#  All rights reserved.

from zipfile import ZipFile
import os
import sys
import subprocess

with ZipFile('SWIG-4.1.1_Windows.zip', 'r') as zipObj:
   zipObj.extractall()
root = sys.path[0]
swig_executable="-DSWIG_EXECUTABLE=" + os.path.join(root, "SWIG", "bin", "swig")
swig_dir="-DSWIG_DIR=" + os.path.join(root, "SWIG","share","swig","4.1.1")
library_path="-DLIBRARY_PATH=" + os.path.join(root, "..","..","lib")

os.mkdir("build")
os.chdir("build")

subprocess.run(["CMAKE","-G", "Visual Studio 15 2017 Win64", "..",swig_executable,swig_dir,library_path ])
subprocess.run(["cmake", "--build", ".", "--config", "Debug", "--target", "INSTALL"])
subprocess.run(["cmake", "--build", ".", "--config", "Release", "--target", "INSTALL"])
