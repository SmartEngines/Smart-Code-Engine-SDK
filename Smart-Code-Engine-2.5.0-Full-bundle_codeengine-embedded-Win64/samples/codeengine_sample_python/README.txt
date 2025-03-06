# You can use this autobuild system instead of prebuilt .pyd and .dll if any troubles occured
#
# DESCRIPTION: 
#   This script is designed to locally build Python integration module for codeengine library.
# 
# MOTIVATION:
#   Version of the Python module development libraries has to exactly correspond to the version
#   of the Python runtime libraries. Thus if the Python modules built on external SDK build machines
#   is different from the version used on client's machine, the Python integration module will not
#   be operational. The local build will guarantee that the Python versions match.
#
# REQUIREMENTS:
#   cmake - version 3.0 or higher. Required for building the Python module.
#   gcc/g++ - version 4.8 or higher. These are required for running Smart Code Engine native
#      libraries anyway, and for building the wrapping Python module. 
#   python-dev: module-development libraries should be available
#
# HOWTO:
#   1. Run build_python_x86.py or build_python_x64.py script from its local directory without any parameters 
#   2. When this script is finished, the compiled module will be placed in ../../bin 
#      directory, and the python bindings will be placed in ../../bindings/python directory. 
#   3. Check the sample: $ python codeengine_sample.py
#
# OVERVIEW:
#   - First, the script unpacks, configures the sources with a local install prefix, 
#     builds and installs SWIG (not in the system, simply in the local folder).
#     SWIG sources (exact version v4.1.1 is required) is placed here
#   - Next, a module build directory is created and the module is built according
#     to the CMake script provided. Local SWIG build will be used to generate the 
#     wrapper.
#     Keep in mind that the built _pycodeengine.pyd Python module should be placed 
#     in the same directory with codeengine.dll, path to this directory should be explicitly 
#     added to your script.