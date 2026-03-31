cmake_minimum_required(VERSION 3.22)
project(adas-interfaces VERSION 1.0.0 LANGUAGES CXX)

# Proto generation (when protoc is available)
# include(cmake/proto_generate.cmake)

# Install headers
install(DIRECTORY cpp/ DESTINATION include/adas-interfaces)
install(DIRECTORY proto/ DESTINATION share/adas-interfaces/proto)
