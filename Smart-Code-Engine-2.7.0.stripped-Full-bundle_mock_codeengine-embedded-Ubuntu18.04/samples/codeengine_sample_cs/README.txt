# You can use this autobuild system instead of prebuilt .cs and .so if any troubles occured
#
# DESCRIPTION: 
#   This script is designed to locally build C# integration module for codeengine library.
#
# MOTIVATION:
#   Version of the C# module development libraries has to exactly correspond to the version
#   of the C# runtime libraries. Thus if the C# modules built on external SDK build machines
#   is different from the version used on client's machine, the C# integration module will not
#   be operational. The local build will guarantee that the C# versions match.
#
# REQUIREMENTS:
#   cmake - version 3.0 or higher. Required for building the C# module.
#   gcc/g++ - version 4.8.5 or higher. These are required for running Smart Code Engine native
#      libraries anyway, and for building the wrapping C# module. 
#      If you are running CentOS 6, the compilers can be installed using devtoolset-2 
#      (see https://gist.github.com/giwa/b1fb1e44dc0a7d270881).
#      Don't forget to switch environments using 'scl enable devtoolset-2 bash'.
#   mono: module-development libraries should be available
#
# HOWTO:
#   1. Run this script from its local directory with one parameter - the path to the directory
#      containing libcodeengine.so installed in your system ("../../bin" if you simply are using 
#      the unpacked SDK).
#   2. When this script is finished, you need to build a solution: xbuild <SOLUTION_NAME>
#      For building only one project, write the project name after the solution: 
#      xbuild <SOLUTION_NAME> /t:<PROJECT_NAME>
#   3. After building the project the compiled module will be placed in ../../bin 
#      directory, and the C# bindings will be placed in ../../bindings/csharp directory.
#   4. Check the sample: $ mono codeengine_sample_cs.exe <path_to_image>
#
# OVERVIEW:
#   - First, the script unpacks, configures the sources with a local install prefix, 
#     builds and installs SWIG (not in the system, simply in the local folder).
#     SWIG sources (exact version v4.1.1 is required) is placed here, it also can
#     be downloaded from https://downloads.sourceforge.net/project/swig/swig/swig-4.1.1/swig-4.1.1.tar.gz
#   - Next, a module build directory is created and the module is built according
#     to the CMake script provided. Local SWIG build will be used to generate the 
#     wrapper, and $1-st argument of this script will be used to find the 
#     libidengine.so library to link with.
