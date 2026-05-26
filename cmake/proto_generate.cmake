# CMake function to find Protobuf or download it via FetchContent as fallback
include_guard(GLOBAL)

include(FetchContent)

option(ADAS_FETCH_PROTOBUF "Fetch and build Protobuf from source if not found locally" OFF)

# Prefer Conan/vcpkg package first (typically exposed as lowercase `protobuf`), then fall back.
find_package(protobuf QUIET)
if(TARGET protobuf::protobuf OR TARGET protobuf::libprotobuf)
    if(TARGET protobuf::protobuf AND NOT TARGET protobuf::libprotobuf)
        add_library(protobuf::libprotobuf ALIAS protobuf::protobuf)
    endif()
    if(TARGET protobuf_BUILD::protoc)
        set(Protobuf_PROTOC_EXECUTABLE $<TARGET_FILE:protobuf_BUILD::protoc>)
    elseif(TARGET protobuf::protoc)
        set(Protobuf_PROTOC_EXECUTABLE $<TARGET_FILE:protobuf::protoc>)
    elseif(DEFINED protobuf_PROTOC_EXECUTABLE)
        set(Protobuf_PROTOC_EXECUTABLE "${protobuf_PROTOC_EXECUTABLE}")
    else()
        message(FATAL_ERROR "Found protobuf package but missing protoc executable/target")
    endif()
    set(Protobuf_FOUND TRUE)
else()
    find_package(Protobuf QUIET)
endif()

if(NOT Protobuf_FOUND AND ADAS_FETCH_PROTOBUF)
    message(STATUS "Protobuf C++ libraries not found locally. Fetching Protobuf from GitHub because ADAS_FETCH_PROTOBUF=ON...")

    # Disable building tests and extra features to speed up compile time
    set(protobuf_BUILD_TESTS OFF CACHE BOOL "Build protobuf tests" FORCE)
    set(protobuf_BUILD_CONFORMANCE_TESTS OFF CACHE BOOL "Build protobuf conformance tests" FORCE)
    set(protobuf_BUILD_EXAMPLES OFF CACHE BOOL "Build protobuf examples" FORCE)
    set(protobuf_BUILD_PROTOC ON CACHE BOOL "Build protoc compiler" FORCE)
    set(protobuf_INSTALL OFF CACHE BOOL "Install protobuf" FORCE)
    set(protobuf_MSVC_STATIC_RUNTIME OFF CACHE BOOL "Use /MD runtime on MSVC" FORCE)

    FetchContent_Declare(
        protobuf
        GIT_REPOSITORY https://github.com/protocolbuffers/protobuf.git
        GIT_TAG v25.1
        GIT_SHALLOW TRUE
    )
    FetchContent_MakeAvailable(protobuf)

    # Alias the target names to match the find_package outputs
    if(TARGET libprotobuf AND NOT TARGET protobuf::libprotobuf)
        add_library(protobuf::libprotobuf ALIAS libprotobuf)
    endif()

    if(TARGET protoc)
        set(Protobuf_PROTOC_EXECUTABLE protoc)
    endif()

    set(Protobuf_FOUND TRUE)
endif()

if(NOT Protobuf_FOUND)
    message(FATAL_ERROR
        "Protobuf not found. Install prebuilt Protobuf (protoc + libprotobuf) and retry. "
        "If you want source fallback, configure with -DADAS_FETCH_PROTOBUF=ON."
    )
endif()

# If Conan provides the protoc target, force using it to avoid gencode/runtime version mismatch.
if(TARGET protobuf_BUILD::protoc)
    set(Protobuf_PROTOC_EXECUTABLE $<TARGET_FILE:protobuf_BUILD::protoc>)
elseif(TARGET protobuf::protoc)
    set(Protobuf_PROTOC_EXECUTABLE $<TARGET_FILE:protobuf::protoc>)
endif()

function(adas_generate_protos TARGET_NAME)
    cmake_parse_arguments(PROTO "" "IMPORT_DIR;OUT_DIR" "FILES" ${ARGN})
    
    if(NOT PROTO_IMPORT_DIR)
        set(PROTO_IMPORT_DIR "${CMAKE_CURRENT_SOURCE_DIR}/proto")
    endif()
    if(NOT PROTO_OUT_DIR)
        set(PROTO_OUT_DIR "${CMAKE_CURRENT_BINARY_DIR}/generated")
    endif()
    
    file(MAKE_DIRECTORY "${PROTO_OUT_DIR}")
    
    set(GENERATED_SRCS)
    set(GENERATED_HDRS)
    
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
            COMMAND ${Protobuf_PROTOC_EXECUTABLE}
            ARGS --proto_path "${PROTO_IMPORT_DIR}"
                 --cpp_out "${PROTO_OUT_DIR}"
                 "${abs_proto}"
            DEPENDS "${abs_proto}"
            COMMENT "Running C++ protocol buffer compiler on ${rel_proto}"
            VERBATIM
        )
        
        list(APPEND GENERATED_SRCS "${src_out}")
        list(APPEND GENERATED_HDRS "${hdr_out}")
    endforeach()
    
    # Associate generated sources/headers with the target
    target_sources(${TARGET_NAME} PRIVATE ${GENERATED_SRCS} ${GENERATED_HDRS})
    
    # Expose the output directory so generated headers can be included (e.g. #include "common/common.pb.h")
    target_include_directories(${TARGET_NAME} PUBLIC "${PROTO_OUT_DIR}")
endfunction()
