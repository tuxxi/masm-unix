cmake_minimum_required (VERSION 3.0.2)
  
project(jwasm)

include_directories(H)
add_definitions(-D__UNIX__ -DNDEBUG -DDEBUG_OUT)


FILE(GLOB all_c_files *.c)
LIST(REMOVE_ITEM all_c_files ${CMAKE_CURRENT_SOURCE_DIR}/trmem.c)

add_executable(jwasm ${all_c_files})
# disable all warnings because JWasm is pretty hairy ..
target_compile_options(jwasm PUBLIC -Wno-everything -O3)
