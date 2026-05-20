# Minimal package config so find_package(AdasInterfaces) works in dev trees
# without Conan. Set: cmake -DAdasInterfaces_DIR=<path/to/interfaces/cmake>
include_guard(GLOBAL)

get_filename_component(_adas_interfaces_root "${CMAKE_CURRENT_LIST_DIR}/.." ABSOLUTE)

if(NOT TARGET AdasInterfaces::AdasInterfaces)
  add_library(AdasInterfaces::AdasInterfaces INTERFACE IMPORTED GLOBAL)
  set_target_properties(AdasInterfaces::AdasInterfaces PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${_adas_interfaces_root}/cpp")
endif()

set(AdasInterfaces_FOUND TRUE)
