###########################################################################
# macro to simplyfy the adding of a submodule
###########################################################################
macro(addPythonModule)

    set(options "")
    set(oneValueArgs NESTED_NAME)
    set(multiValueArgs SOURCES LIBRRARIES)
    cmake_parse_arguments(ADD_PY_MOD "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )

    # get name of the module
    string(REPLACE "/" ";" MOD_NESTING_LIST "${ADD_PY_MOD_NESTED_NAME}")
    list(LENGTH MOD_NESTING_LIST nesting_len)
    LIST(GET MOD_NESTING_LIST ${LENGTH}-1 MODULE_NAME)


    #Create the binding library
    pybind11_add_module(_${MODULE_NAME}
        ${ADD_PY_MOD_SOURCES}
    )
    #if (APPLE AND NOT ${CMAKE_BUILD_TYPE} MATCHES Debug)
    if(CMAKE_CXX_COMPILER_ID MATCHES "GNU" OR CMAKE_CXX_COMPILER_ID MATCHES "Clang")
      target_compile_options(_${MODULE_NAME} PRIVATE "-fvisibility=default")
    endif()

    #endif()
    set_target_properties(_${MODULE_NAME}  PROPERTIES PREFIX "")

    #message(STATUS ********Module: ${MODULE_NAME})
    #message(STATUS ********Libs: ${ADD_PY_MOD_LIBRRARIES})

    # link additional libraries
    target_link_libraries(_${MODULE_NAME}
        PUBLIC
        ${PYTHON_LIBRARIES}
        ${ADD_PY_MOD_LIBRRARIES}
    )

    # create module dir
    #file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/python/${ADD_PY_MOD_NESTED_NAME})

    # copy the module file
    ADD_CUSTOM_COMMAND(
        TARGET _${MODULE_NAME}
        POST_BUILD
        COMMAND ${CMAKE_COMMAND} ARGS -E copy_if_different $<TARGET_FILE:_${MODULE_NAME}>
        ${CMAKE_BINARY_DIR}/_custom_malis.so
        COMMENT "Copying target ${MODULE_NAME} to temporary module directory")

    # add_dependencies(malis_impl _${MODULE_NAME})
endmacro()


# build the pybind module
addPythonModule(
    NESTED_NAME
        custom_malis
    SOURCES
        malis.cxx
        custom_malis.cxx
)



# copy the __init__.py
#add_custom_command(
#    TARGET custom_malis
#    POST_BUILD
#    COMMAND ${CMAKE_COMMAND} -E copy
#    ${CMAKE_CURRENT_SOURCE_DIR}/__init__.py
#    ${CMAKE_BINARY_DIR}/__init__.py
#)
