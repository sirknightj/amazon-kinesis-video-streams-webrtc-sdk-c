cmake_minimum_required(VERSION 3.6.3)
project(kvs-webrtc-cmake-validation-tests LANGUAGES C)

# CTest-based compile-time validation tests.
#
# These verify that CMake rejects invalid combinations at configure time.
# Each test spawns a cmake configure subprocess against the main project root.
#
# Usage:
#   mkdir build-cmake-tests && cd build-cmake-tests
#   cmake ../tst/cmake-validation
#   ctest --output-on-failure

enable_testing()

set(PROJECT_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/../..")
set(SDP_TEST_CMAKE_ARGS -DBUILD_DEPENDENCIES=OFF -DBUILD_SAMPLE=OFF -DBUILD_TEST=OFF)

# Each test gets its own -B directory so they can run in parallel without
# clobbering each other's CMakeCache or open-source install paths.
# The build directory is wiped before each run to ensure a clean configure,
# and preserved after so artifacts can be inspected on failure.

set(SDP_TEST_BUILD_ROOT "${CMAKE_CURRENT_BINARY_DIR}/sdp_tests")

# Helper script that removes the build dir then runs cmake configure
configure_file(
  "${CMAKE_CURRENT_SOURCE_DIR}/run_cmake_test.cmake.in"
  "${CMAKE_CURRENT_BINARY_DIR}/run_cmake_test.cmake"
  @ONLY)

# Tests that expect cmake configure to FAIL
add_test(NAME sdp_buffer_size_below_minimum
  COMMAND ${CMAKE_COMMAND} -DTEST_BUILD_DIR=${SDP_TEST_BUILD_ROOT}/below_min
    -DTEST_CMAKE_ARGS=${SDP_TEST_CMAKE_ARGS} -DTEST_EXTRA_ARGS=-DKVS_SDP_BUFFER_SIZE=16
    -DTEST_SOURCE_DIR=${PROJECT_ROOT} -P ${CMAKE_CURRENT_BINARY_DIR}/run_cmake_test.cmake)
set_tests_properties(sdp_buffer_size_below_minimum PROPERTIES WILL_FAIL TRUE)

add_test(NAME sdp_buffer_size_above_maximum
  COMMAND ${CMAKE_COMMAND} -DTEST_BUILD_DIR=${SDP_TEST_BUILD_ROOT}/above_max
    -DTEST_CMAKE_ARGS=${SDP_TEST_CMAKE_ARGS} -DTEST_EXTRA_ARGS=-DKVS_SDP_BUFFER_SIZE=50000
    -DTEST_SOURCE_DIR=${PROJECT_ROOT} -P ${CMAKE_CURRENT_BINARY_DIR}/run_cmake_test.cmake)
set_tests_properties(sdp_buffer_size_above_maximum PROPERTIES WILL_FAIL TRUE)

add_test(NAME sdp_buffer_size_non_numeric
  COMMAND ${CMAKE_COMMAND} -DTEST_BUILD_DIR=${SDP_TEST_BUILD_ROOT}/non_numeric
    -DTEST_CMAKE_ARGS=${SDP_TEST_CMAKE_ARGS} -DTEST_EXTRA_ARGS=-DKVS_SDP_BUFFER_SIZE=abc
    -DTEST_SOURCE_DIR=${PROJECT_ROOT} -P ${CMAKE_CURRENT_BINARY_DIR}/run_cmake_test.cmake)
set_tests_properties(sdp_buffer_size_non_numeric PROPERTIES WILL_FAIL TRUE)

add_test(NAME sdp_buffer_size_negative
  COMMAND ${CMAKE_COMMAND} -DTEST_BUILD_DIR=${SDP_TEST_BUILD_ROOT}/negative
    -DTEST_CMAKE_ARGS=${SDP_TEST_CMAKE_ARGS} -DTEST_EXTRA_ARGS=-DKVS_SDP_BUFFER_SIZE=-1
    -DTEST_SOURCE_DIR=${PROJECT_ROOT} -P ${CMAKE_CURRENT_BINARY_DIR}/run_cmake_test.cmake)
set_tests_properties(sdp_buffer_size_negative PROPERTIES WILL_FAIL TRUE)

# Tests that expect cmake configure to SUCCEED
add_test(NAME sdp_buffer_size_valid_minimum
  COMMAND ${CMAKE_COMMAND} -DTEST_BUILD_DIR=${SDP_TEST_BUILD_ROOT}/valid_min
    -DTEST_CMAKE_ARGS=${SDP_TEST_CMAKE_ARGS} -DTEST_EXTRA_ARGS=-DKVS_SDP_BUFFER_SIZE=2048
    -DTEST_SOURCE_DIR=${PROJECT_ROOT} -P ${CMAKE_CURRENT_BINARY_DIR}/run_cmake_test.cmake)

add_test(NAME sdp_buffer_size_valid_maximum
  COMMAND ${CMAKE_COMMAND} -DTEST_BUILD_DIR=${SDP_TEST_BUILD_ROOT}/valid_max
    -DTEST_CMAKE_ARGS=${SDP_TEST_CMAKE_ARGS} -DTEST_EXTRA_ARGS=-DKVS_SDP_BUFFER_SIZE=40000
    -DTEST_SOURCE_DIR=${PROJECT_ROOT} -P ${CMAKE_CURRENT_BINARY_DIR}/run_cmake_test.cmake)

add_test(NAME sdp_buffer_size_valid_default
  COMMAND ${CMAKE_COMMAND} -DTEST_BUILD_DIR=${SDP_TEST_BUILD_ROOT}/valid_default
    -DTEST_CMAKE_ARGS=${SDP_TEST_CMAKE_ARGS} -DTEST_EXTRA_ARGS=
    -DTEST_SOURCE_DIR=${PROJECT_ROOT} -P ${CMAKE_CURRENT_BINARY_DIR}/run_cmake_test.cmake)
