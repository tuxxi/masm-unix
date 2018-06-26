cmake_minimum_required(VERSION 3.0.2)

project(objconv)

include_directories(${PROJECT_SOURCE_DIR}/src)

file(GLOB SRC_FILES ${PROJECT_SOURCE_DIR}/src/*.cpp)

add_executable(objconv ${SRC_FILES})
set (CMAKE_CXX_FLAGS -O2)
# disable warnings t
target_compile_options(objconv PUBLIC -Wno-everything -O3)
