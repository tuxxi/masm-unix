cmake_minimum_required(VERSION 2.8)

project(masm_unix)

set(OUTPUT_DIR ${CMAKE_CURRENT_SOURCE_DIR}/lib)

set(SOURCES_DIR ${CMAKE_CURRENT_SOURCE_DIR}/src)
set(JWASM_DIR ${SOURCES_DIR}/JWasm)
set(ALONG32_DIR ${SOURCES_DIR}/Along32)
set(OBJCONV_DIR ${SOURCES_DIR}/objconv)

# include JWASM's CMake module
add_subdirectory(${JWASM_DIR})
#include objconv's CMake module
add_subdirectory(${OBJCONV_DIR})


# tell CMake to build binaries into the correct dir
set_target_properties(objconv PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${OUTPUT_DIR})
set_target_properties(jwasm PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${OUTPUT_DIR})

# include Along32's makefile and build by default
add_custom_target(
   Along32 ALL
   COMMAND make
   WORKING_DIRECTORY ${ALONG32_DIR}/src
)
# copy libAlong32.a to the output dir
add_custom_command(TARGET Along32 POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy
    ${ALONG32_DIR}/src/libAlong32.a ${OUTPUT_DIR}/libAlong32.a
)