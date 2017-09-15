# test libraries
SET(TEST_LIBS
    gtest
    gtest_main
    pthread
)

add_executable(test_malis test_malis.cxx)
target_link_libraries(test_malis ${TEST_LIBS})
