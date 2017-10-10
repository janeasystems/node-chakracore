#-------------------------------------------------------------------------------------------------------
# Copyright (C) Microsoft. All rights reserved.
# Licensed under the MIT license. See LICENSE.txt file in the project root for full license information.
#-------------------------------------------------------------------------------------------------------

include(CheckCXXSourceCompiles)
include(CheckCXXSourceRuns)

if(CC_TARGET_OS_OSX OR CC_TARGET_OS_IOS)
    # by default this is disabled for osx
    # enable temporarily
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} \
        -Werror"
        )
endif()
if (CC_TARGET_OS_IOS)
  # Can't run the test when cross_compiling, so the flag is set manually.
  set(CLANG_HAS_DISABLE_TAIL_CALLS_CFG 1)
else()
  check_cxx_source_runs("
#include <stdlib.h>
#include <stdio.h>

__attribute__((disable_tail_calls))
int inc(int a) { return a + 1; }

int main(int argc, char **argv) {
  printf(\"%d\", inc(argc + 1));
  exit(0);
}" CLANG_HAS_DISABLE_TAIL_CALLS_CFG)
endif()

if(CLANG_HAS_DISABLE_TAIL_CALLS_CFG STREQUAL 1)
  add_definitions(-DCLANG_HAS_DISABLE_TAIL_CALLS=1)
  set(CXX_DO_NOT_OPTIMIZE_SIBLING_CALLS "")
else()
  set(CXX_DO_NOT_OPTIMIZE_SIBLING_CALLS "-fno-optimize-sibling-calls")
endif()

if(CC_TARGET_OS_OSX OR CC_TARGET_OS_IOS)
    # by default this is disabled for osx
    # disable back
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} \
        -Wno-error"
        )
endif()
