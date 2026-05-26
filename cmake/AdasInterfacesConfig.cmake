# Minimal package config so find_package(AdasInterfaces) works in dev trees
# without Conan. Set: cmake -DAdasInterfaces_DIR=<path/to/interfaces/cmake>
include_guard(GLOBAL)

get_filename_component(_adas_interfaces_root "${CMAKE_CURRENT_LIST_DIR}/.." ABSOLUTE)
set(_adas_interfaces_binary_dir "${CMAKE_BINARY_DIR}/_deps/adas-interfaces")

if(NOT TARGET adas-interfaces)
  add_subdirectory("${_adas_interfaces_root}" "${_adas_interfaces_binary_dir}" EXCLUDE_FROM_ALL)
endif()

if(NOT TARGET AdasInterfaces::AdasInterfaces)
  add_library(AdasInterfaces::AdasInterfaces INTERFACE IMPORTED GLOBAL)
  if(TARGET adas-interfaces)
    target_link_libraries(AdasInterfaces::AdasInterfaces INTERFACE adas-interfaces)
  else()
    set_target_properties(AdasInterfaces::AdasInterfaces PROPERTIES
      INTERFACE_INCLUDE_DIRECTORIES "${_adas_interfaces_root}/cpp")
  endif()
endif()

set(AdasInterfaces_FOUND TRUE)
