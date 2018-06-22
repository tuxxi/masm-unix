cmake_minimum_required(VERSION 2.8)

project(objconv)
set (CMAKE_CXX_FLAGS -O2)

include_directories(${PROJECT_SOURCE_DIR}/src)

file(GLOB SRC_FILES ${PROJECT_SOURCE_DIR}/src/*.cpp)

add_executable(objconv ${SRC_FILES})