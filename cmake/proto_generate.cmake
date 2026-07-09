# CMake function to generate protobuf C++ sources using preinstalled/Conan-provided protobuf.
include_guard(GLOBAL)

find_package(protobuf REQUIRED)
find_package(protobuf_BUILD QUIET)

if(TARGET protobuf::protobuf AND NOT TARGET protobuf::libprotobuf)
    add_library(protobuf::libprotobuf ALIAS protobuf::protobuf)
endif()

if(TARGET protobuf_BUILD::protoc)
    set(_ADAS_PROTOC_TARGET protobuf_BUILD::protoc)
elseif(TARGET protobuf::protoc)
    set(_ADAS_PROTOC_TARGET protobuf::protoc)
else()
    message(FATAL_ERROR
        "Missing protoc target. Expected protobuf_BUILD::protoc (Conan tool_requires) "
        "or protobuf::protoc."
    )
endif()

function(adas_generate_protos TARGET_NAME)
    cmake_parse_arguments(PROTO "" "IMPORT_DIR;OUT_DIR;PYTHON_OUT_DIR" "FILES" ${ARGN})

    if(NOT PROTO_IMPORT_DIR)
        set(PROTO_IMPORT_DIR "${CMAKE_CURRENT_SOURCE_DIR}/proto")
    endif()
    if(NOT PROTO_OUT_DIR)
        set(PROTO_OUT_DIR "${CMAKE_CURRENT_BINARY_DIR}/generated")
    endif()

    file(MAKE_DIRECTORY "${PROTO_OUT_DIR}")
    if(PROTO_PYTHON_OUT_DIR)
        file(MAKE_DIRECTORY "${PROTO_PYTHON_OUT_DIR}")
    endif()

    set(GENERATED_SRCS)
    set(GENERATED_HDRS)
    set(GENERATED_PY)

    foreach(proto_file IN LISTS PROTO_FILES)
        get_filename_component(abs_proto "${proto_file}" ABSOLUTE)
        get_filename_component(proto_name "${proto_file}" NAME_WE)

        # Determine the relative path of the proto file to preserve folder structure
        file(RELATIVE_PATH rel_proto "${PROTO_IMPORT_DIR}" "${abs_proto}")
        get_filename_component(rel_dir "${rel_proto}" DIRECTORY)

        if(rel_dir)
            set(out_dir_full "${PROTO_OUT_DIR}/${rel_dir}")
            set(rel_prefix "${rel_dir}/")
        else()
            set(out_dir_full "${PROTO_OUT_DIR}")
            set(rel_prefix "")
        endif()

        file(MAKE_DIRECTORY "${out_dir_full}")

        set(src_out "${PROTO_OUT_DIR}/${rel_prefix}${proto_name}.pb.cc")
        set(hdr_out "${PROTO_OUT_DIR}/${rel_prefix}${proto_name}.pb.h")

        add_custom_command(
            OUTPUT "${src_out}" "${hdr_out}"
            COMMAND $<TARGET_FILE:${_ADAS_PROTOC_TARGET}>
            ARGS --proto_path "${PROTO_IMPORT_DIR}"
                 --cpp_out "${PROTO_OUT_DIR}"
                 "${abs_proto}"
            DEPENDS "${abs_proto}" ${_ADAS_PROTOC_TARGET}
            COMMENT "Running C++ protocol buffer compiler on ${rel_proto}"
            VERBATIM
        )

        list(APPEND GENERATED_SRCS "${src_out}")
        list(APPEND GENERATED_HDRS "${hdr_out}")

        # Opt-in Python bindings (e.g. for the CARLA bridge, modules/df/src/platform/carla) —
        # same .proto files, same protoc, just a second output language. Skipped entirely
        # unless a caller passes PYTHON_OUT_DIR, so C++-only consumers pay zero extra cost.
        if(PROTO_PYTHON_OUT_DIR)
            set(py_out_dir_full "${PROTO_PYTHON_OUT_DIR}/${rel_dir}")
            file(MAKE_DIRECTORY "${py_out_dir_full}")
            set(py_out "${PROTO_PYTHON_OUT_DIR}/${rel_prefix}${proto_name}_pb2.py")

            add_custom_command(
                OUTPUT "${py_out}"
                COMMAND $<TARGET_FILE:${_ADAS_PROTOC_TARGET}>
                ARGS --proto_path "${PROTO_IMPORT_DIR}"
                     --python_out "${PROTO_PYTHON_OUT_DIR}"
                     "${abs_proto}"
                DEPENDS "${abs_proto}" ${_ADAS_PROTOC_TARGET}
                COMMENT "Running Python protocol buffer compiler on ${rel_proto}"
                VERBATIM
            )

            list(APPEND GENERATED_PY "${py_out}")
        endif()
    endforeach()

    # Associate generated sources/headers with the target
    target_sources(${TARGET_NAME} PRIVATE ${GENERATED_SRCS} ${GENERATED_HDRS})

    # Expose the output directory so generated headers can be included (e.g. #include "common/common.pb.h")
    target_include_directories(${TARGET_NAME} PUBLIC "${PROTO_OUT_DIR}")

    # Python bindings aren't compiled sources — a custom target is the only way to make
    # `cmake --build` produce them (they're not linked into TARGET_NAME itself).
    if(PROTO_PYTHON_OUT_DIR)
        add_custom_target(${TARGET_NAME}_python_protos ALL DEPENDS ${GENERATED_PY})
    endif()
endfunction()
