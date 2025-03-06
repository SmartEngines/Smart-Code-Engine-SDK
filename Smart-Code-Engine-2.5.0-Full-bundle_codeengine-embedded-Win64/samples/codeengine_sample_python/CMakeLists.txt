cmake_minimum_required(VERSION 3.0)
set(CMAKE_SKIP_BUILD_RPATH FALSE)
set(CMAKE_BUILD_WITH_INSTALL_RPATH FALSE)
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)

project(pycodeengine)

find_library(CODEENGINE_LIBRARY codeengine HINTS ${LIBRARY_PATH})

include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../../include/codeengine)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../../include/secommon)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../../include)

find_package(PythonInterp)
find_package(PythonLibs)

INCLUDE_DIRECTORIES(${PYTHON_INCLUDE_DIRS})

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fpermissive -std=c++11")

find_package(SWIG 4.1.1 EXACT REQUIRED)
include(${SWIG_USE_FILE})

# set(CMAKE_SKIP_RPATH TRUE)

set(MY_SWIG_FILE codeengine.i)
set_property(SOURCE ${MY_SWIG_FILE} PROPERTY CPLUSPLUS ON INCLUDE_DIRECTORIES ../../include)

SWIG_ADD_MODULE(pycodeengine python  ${MY_SWIG_FILE})

set_target_properties(${SWIG_MODULE_pycodeengine_REAL_NAME} PROPERTIES PREFIX "")

set_property(TARGET _pycodeengine PROPERTY SWIG_USE_TARGET_INCLUDE_DIRECTORIES TRUE)

set_property(TARGET _pycodeengine PROPERTY GENERATED_COMPILE_OPTIONS "-fPIC")

set_property(TARGET _pycodeengine PROPERTY LINK_OPTIONS "-Wl,--enable-new-dtags")

target_link_libraries(_pycodeengine ${CODEENGINE_LIBRARY})
target_link_libraries(_pycodeengine ${PYTHON_LIBRARIES})

SWIG_LINK_LIBRARIES(pycodeengine ${CODEENGINE_LIBRARY})
target_link_libraries(_pycodeengine ${PYTHON_LIBRARIES})

set(CMAKE_INSTALL_PREFIX "${CMAKE_CURRENT_SOURCE_DIR}/../../")
set(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/bin")

install(TARGETS _pycodeengine
        RUNTIME DESTINATION bin
        LIBRARY DESTINATION bin
)

SET(CMAKE_EXE_LINKER_FLAGS "-Wl,--enable-new-dtags")

install(
  CODE "FILE(GLOB python_files \"${CMAKE_CURRENT_BINARY_DIR}/*.py\")"
  CODE "FILE(INSTALL \${python_files} DESTINATION \${CMAKE_INSTALL_PREFIX}/bindings/python)"
)

