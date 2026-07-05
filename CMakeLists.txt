cmake_minimum_required(VERSION 3.22)
project(adas-interfaces VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)

# Proto generation
include(cmake/proto_generate.cmake)

# Define static library
add_library(adas-interfaces STATIC)

# Generate proto sources and associate them with adas-interfaces target
adas_generate_protos(adas-interfaces
    FILES
        proto/common/common.proto
        proto/common/veh_dyn.proto
        proto/isp/frame.proto
        proto/perception/detection.proto
        proto/perception/object.proto
        proto/perception/free_space.proto
        proto/functions/fcw.proto
        proto/functions/comp_state.proto
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

# Install headers
install(DIRECTORY cpp/ DESTINATION include/adas-interfaces)
install(DIRECTORY proto/ DESTINATION share/adas-interfaces/proto)
