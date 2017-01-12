cmake_minimum_required(VERSION 3.0)
project(qzxing)

# Generate compile_commands.json for use by YCM
set(CMAKE_EXPORT_COMPILE_COMMANDS 1)

find_package(Qt5Core REQUIRED)
find_package(Qt5Gui REQUIRED)
find_package(Qt5Widgets REQUIRED)
find_package(Qt5Quick REQUIRED)
find_package(Qt5Multimedia REQUIRED)

set(QZXING_LIBRARIES
  Qt5::Core
  Qt5::Gui
  Qt5::Widgets
  Qt5::Quick
  Qt5::Multimedia
)

set(CMAKE_AUTOMOC ON)
set(CMAKE_INCLUDE_CURRENT_DIR ON)

# Set c++11 support
include(CheckCXXCompilerFlag)
CHECK_CXX_COMPILER_FLAG("-std=c++11" COMPILER_SUPPORTS_CXX11)
CHECK_CXX_COMPILER_FLAG("-std=c++0x" COMPILER_SUPPORTS_CXX0X)
if (COMPILER_SUPPORTS_CXX11)
  set(my_cxx_flags "-std=c++11")
elseif (COMPILER_SUPPORTS_CXX0X)
  set(my_cxx_flags "-std=c++0x")
else()
  message(STATUS "The compiler ${CMAKE_CXX_COMPILER} has no C++11 support. \
    Please use a different C++ compiler.")
endif()
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${my_cxx_flags}")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${my_cxx_flags}")

add_subdirectory(src)
