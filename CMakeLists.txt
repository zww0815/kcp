# CMake root file for KCP related apps
# Date  : 2018-05-28
# Author: Zeng wenwu(zww0815@foxmail.com)
#
#  CMake files for KCP
#  file for each app is under the related sub-dir
#

# CMake 最低版本号要求
cmake_minimum_required (VERSION 3.0)

# Append our module directory to CMake
# set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

option(ENABLE_TESTS            "Set to OFF|ON (default is OFF) to control build of KCP tests & samples"       OFF)
option(ENABLE_BUILD_KCP_STATIC "Set to OFF|ON (default is OFF) to control build of KCP as STATIC library"     OFF)
option(ENABLE_BUILD_KCP_MT     "Set to OFF|ON (default is OFF) to control build of KCP as /MT instead of /MD" OFF)

################################################################################################
# set project name
set(project_name "KCP")

project(${project_name})

################################################################################################
# Enable MT when build with VS
if(MSVC)
    if(ENABLE_BUILD_KCP_MT)
        set(CompilerFlags
            CMAKE_CXX_FLAGS
            CMAKE_CXX_FLAGS_DEBUG
            CMAKE_CXX_FLAGS_RELEASE
            CMAKE_CXX_FLAGS_RELWITHDEBINFO
            CMAKE_C_FLAGS
            CMAKE_C_FLAGS_DEBUG
            CMAKE_C_FLAGS_RELEASE
            )
        foreach(CompilerFlag ${CompilerFlags})
            string(REPLACE "/MD" "/MT" ${CompilerFlag} "${${CompilerFlag}}")
        endforeach()

        set(STATIC_POSTFIX "mt" CACHE STRING "Set static library postfix" FORCE)
    else(ENABLE_BUILD_KCP_MT)
        set(STATIC_POSTFIX "md" CACHE STRING "Set static library postfix" FORCE)
    endif(ENABLE_BUILD_KCP_MT)
      
    # if (ENABLE_MSVC_MP)
      # add_definitions(/MP)
    # endif()
    
else(MSVC)
    # Other compilers then MSVC don't have a static STATIC_POSTFIX at the moment
    set(STATIC_POSTFIX "" CACHE STRING "Set static library postfix" FORCE)
    set(CMAKE_C_FLAGS_DEBUG   "${CMAKE_C_FLAGS_DEBUG}   -D_DEBUG")
    set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -D_DEBUG")
endif(MSVC)


################################################################################################
# set compiler references
if(WIN32)
	message("-- set WIN32 build result output directories ...")

	set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${PROJECT_SOURCE_DIR}/release/win32/lib)
	set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${PROJECT_SOURCE_DIR}/release/win32/lib)
	set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${PROJECT_SOURCE_DIR}/release/win32/bin)
	
	# set install directory
	set(CMAKE_INSTALL_PREFIX ${PROJECT_SOURCE_DIR}/install/win32)

	#
	# To use MFC, the CMAKE_MFC_FLAG variable must be set as follows:
	#
	# 0: Use Standard Windows Libraries
	# 1: Use MFC in a Static Library
	# 2: Use MFC in a Shared DLL
	SET(CMAKE_MFC_FLAG 1)
else(WIN32)
    message("-- set linux build result output directories ...")

	set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${PROJECT_SOURCE_DIR}/release/linux/lib)
	set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${PROJECT_SOURCE_DIR}/release/linux/lib)
	set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${PROJECT_SOURCE_DIR}/release/linux/bin)
	
	# set install directory
	set(CMAKE_INSTALL_PREFIX ${PROJECT_SOURCE_DIR}/install/linux)
endif(WIN32)


################################################################################################
set(KCP_TARGET_NAME kcp)
set(KCP_SRC_FILES ikcp.c ikcp.h)

if(WIN32)
    source_group("Include" FILES *.cpp *.c)
    source_group("Source" FILES *.h)
    add_library(${KCP_TARGET_NAME} STATIC ${KCP_SRC_FILES})
    SET_PROPERTY(TARGET ${KCP_TARGET_NAME} PROPERTY FOLDER "lib")
else(WIN32)
    if(ENABLE_BUILD_KCP_STATIC)
        add_library(${KCP_TARGET_NAME} STATIC ${KCP_SRC_FILES})
    else(ENABLE_BUILD_KCP_STATIC)
        add_library(${KCP_TARGET_NAME} SHARED ${KCP_SRC_FILES})
    endif(ENABLE_BUILD_KCP_STATIC)
endif(WIN32)


if(ENABLE_TESTS)
    source_group("Include" FILES *.cpp *.c)
    source_group("Source" FILES *.h)

    set(KCP_TEST_TARGET_NAME kcp_test)
    set(KCP_TEST_SRC_FILES test.cpp test.h)
    add_executable(${KCP_TEST_TARGET_NAME} ${KCP_TEST_SRC_FILES})
    SET_PROPERTY(TARGET ${KCP_TEST_TARGET_NAME} PROPERTY FOLDER "test")
endif(ENABLE_TESTS)

set(CMAKE_DEBUG_POSTFIX "d")

# Enable group feature in VS
SET_PROPERTY(GLOBAL PROPERTY USE_FOLDERS ON)


################################################################################################
# Macros for simplified installation
#
#  KCP_INSTALL - Install the given target
#    Usage: KCP_INSTALL(target_name)
#      INPUT:
#           target_name             the name of the target.
#    Example: KCP_INSTALL(kcp)
macro(KCP_INSTALL target_name)
    # install release binaries
    install (
        TARGETS "${target_name}" EXPORT "${target_name}Targets"
        RUNTIME DESTINATION "${CMAKE_INSTALL_PREFIX}/Release" CONFIGURATIONS Release
        LIBRARY DESTINATION "${CMAKE_INSTALL_PREFIX}/Release" CONFIGURATIONS Release
        ARCHIVE DESTINATION "${CMAKE_INSTALL_PREFIX}/Release" CONFIGURATIONS Release
    )

    # install debug binaries
    install (
        TARGETS "${target_name}" EXPORT "${target_name}Targets"
        RUNTIME DESTINATION "${CMAKE_INSTALL_PREFIX}/Debug" CONFIGURATIONS Debug
        LIBRARY DESTINATION "${CMAKE_INSTALL_PREFIX}/Debug" CONFIGURATIONS Debug
        ARCHIVE DESTINATION "${CMAKE_INSTALL_PREFIX}/Debug" CONFIGURATIONS Debug
    )

    # install the targets pdb
    if (MSVC)
        get_property(type TARGET ${target_name} PROPERTY TYPE)
        if ("${type}" STREQUAL "SHARED_LIBRARY" OR "${type}" STREQUAL "EXECUTABLE")
            install(
                FILES $<TARGET_PDB_FILE:${target_name}>
                DESTINATION "${CMAKE_INSTALL_PREFIX}/Debug"
                COMPONENT Devel
                OPTIONAL
                CONFIGURATIONS Debug
                )
        endif()
    endif()
endmacro()


################################################################################################
# Install target
KCP_INSTALL(${KCP_TARGET_NAME})
install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/ikcp.h DESTINATION "${CMAKE_INSTALL_PREFIX}/include/" CONFIGURATIONS Release)

if(ENABLE_TESTS)
    KCP_INSTALL(${KCP_TEST_TARGET_NAME})
endif(ENABLE_TESTS)
