cmake_minimum_required(VERSION 3.22)
project(adas-interfaces VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)

# Proto generation
include(cmake/proto_generate.cmake)

# Define static library
add_library(adas-interfaces STATIC)

# Opt-in Python protobuf bindings for Python hosts (e.g. the CARLA bridge,
# modules/df/tools/carla) — OFF by default so plain C++ builds/presets
# are unaffected. Output lands in build/generated_py.
option(ADAS_GENERATE_PYTHON_PROTO "Also generate Python protobuf bindings" OFF)
set(_ADAS_PROTO_PYTHON_ARGS)
if(ADAS_GENERATE_PYTHON_PROTO)
    set(_ADAS_PROTO_PYTHON_ARGS PYTHON_OUT_DIR "${CMAKE_CURRENT_BINARY_DIR}/generated_py")
endif()

# Generate proto sources and associate them with adas-interfaces target
adas_generate_protos(adas-interfaces
    ${_ADAS_PROTO_PYTHON_ARGS}
    FILES
        proto/common/common.proto
        proto/common/signal_header.proto
        proto/common/comp_state.proto
        proto/isp/frame.proto
        proto/perception/detection.proto
        proto/perception/free_space.proto
        proto/PerceptionCore__Outputs/gen_object.proto
        proto/PerceptionCore__Outputs/gen_object_list.proto
        proto/VehSigProvider__Outputs/veh_dyn.proto
        proto/Aeb__Outputs/aeb_outputs.proto
)

# Export its public header search path (for internal usage inside the subdirectory)
target_include_directories(adas-interfaces PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/cpp
)

# Link against Protobuf
target_link_libraries(adas-interfaces PUBLIC protobuf::libprotobuf)
if(TARGET protobuf::libprotobuf)
    get_target_property(_adas_pb_includes protobuf::libprotobuf INTERFACE_INCLUDE_DIRECTORIES)
    if(_adas_pb_includes)
        target_include_directories(adas-interfaces PUBLIC ${_adas_pb_includes})
    endif()
endif()

# Install the compiled library (needed for a real `conan create` package;
# editable mode - what we actually use today, plan.md item 1 - bypasses this
# entirely and resolves straight from the build tree instead).
install(TARGETS adas-interfaces
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
)

# Install headers
install(DIRECTORY cpp/ DESTINATION include/adas-interfaces)
install(DIRECTORY proto/ DESTINATION share/adas-interfaces/proto)
