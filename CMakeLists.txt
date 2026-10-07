# Advance Wars: builds the C that gbarecomp generates from your ROM into gen/.
# build.cmd runs both steps (translate, then this); gen/ is never committed.
# A build farm sends the checkout with gen/ already in it and builds here.
cmake_minimum_required(VERSION 3.16)
project(advancewars C)

if(NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/gen/CMakeLists.txt")
    message(FATAL_ERROR "gen/ is empty: run build.cmd first (it translates game/aw.gba)")
endif()

# AWRE.exe lands in build/<config>/ rather than build/gen/<config>/
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}")
add_subdirectory(gen)
