cmake_minimum_required(VERSION 3.1)

project(custom_malis)


####################
# set c++ 11 support
####################
include(CheckCXXCompilerFlag) 

# make sure the compiler supports c++11
# FIXME I think this won't work for MSVC
CHECK_CXX_COMPILER_FLAG("-std=c++11" HAS_CPP11_FLAG)
if(NOT HAS_CPP11_FLAG)
    message(FATAL_ERROR "Unsupported compiler -- custom_malis requires C++11 support!")
endif()

set(CMAKE_CXX_FLAG ${CMAKE_CXX_FLAG} "-std=c++11")

#-------------------------------------------------------------------------------------------------------------------
# Set a default build configuraton if none is specified. 'Release' produces the fastest code
#-------------------------------------------------------------------------------------------------------------------
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    message(STATUS "Setting build type to 'Release' as none was specified.")
    set(CMAKE_BUILD_TYPE Release CACHE STRING "Choose the type of build." FORCE)
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Release"
        "MinSizeRel" "RelWithDebInfo")
endif()
string(TOUPPER "${CMAKE_BUILD_TYPE}" U_CMAKE_BUILD_TYPE)


option(BUILD_CPP_TEST OFF)


#-------------------------------------------------------------------------------------------------------------------
# thread libs
#-------------------------------------------------------------------------------------------------------------------
find_package(Threads)


#-------------------------------------------------------------------------------------------------------------------
# rt lib
#-------------------------------------------------------------------------------------------------------------------
if(UNIX AND NOT APPLE)
  find_library(RT rt)
  set(LINK_RT true)
else()
  set(LINK_RT false)
endif()


#################
# google test
################

# add gtest external project and include the directories
add_subdirectory(external/googletest/googletest)
include_directories(${gtest_SOURCE_DIR/include} ${gtest_SOURCE_DIR})


##################
# nifty and pybind
##################

include_directories("${CMAKE_CURRENT_SOURCE_DIR}/external/nifty/include")
include_directories("${CMAKE_CURRENT_SOURCE_DIR}/external/nifty/externals/pybind11/include")

add_subdirectory("${CMAKE_CURRENT_SOURCE_DIR}/external/nifty/externals/pybind11")


###############
# include dirs
###############

file(GLOB_RECURSE headers include/*.hxx)
include_directories(include)

############
# src folder
############

add_subdirectory(src)
