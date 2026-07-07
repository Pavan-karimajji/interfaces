from conan import ConanFile
from conan.tools.cmake import CMake, CMakeDeps, CMakeToolchain, cmake_layout
from pathlib import Path
import re


class InterfacesConan(ConanFile):
    name = "adas-interfaces"
    package_type = "static-library"

    settings = "os", "arch", "compiler", "build_type"
    requires = ("protobuf/3.21.12",)
    tool_requires = ("protobuf/3.21.12",)

    default_options = {
        "protobuf/*:shared": False,
        "protobuf/*:with_zlib": False,
    }

    exports_sources = "CMakeLists.txt", "cmake/*", "cpp/*", "proto/*"

    def set_version(self):
        cmakelists = Path(self.recipe_folder) / "CMakeLists.txt"
        content = cmakelists.read_text(encoding="utf-8")
        match = re.search(r"project\(\s*adas-interfaces\s+VERSION\s+([0-9]+\.[0-9]+\.[0-9]+)", content, re.IGNORECASE)
        if not match:
            raise RuntimeError("Could not extract VERSION from CMakeLists.txt")
        self.version = match.group(1)

    def layout(self):
        cmake_layout(self)
        # cpp/ and generated/ don't match cmake_layout()'s include/ default -
        # editable-mode consumers resolve headers/libs relative to these,
        # independent of package()/install() (which only run for a real
        # `conan create`, not for editable mode - see plan.md item 1).
        self.cpp.source.includedirs = ["cpp"]
        self.cpp.build.includedirs = ["generated"]

    def generate(self):
        tc = CMakeToolchain(self)
        tc.generate()
        deps = CMakeDeps(self)
        deps.build_context_activated = ["protobuf"]
        deps.build_context_suffix = {"protobuf": "_BUILD"}
        deps.generate()

    def build(self):
        cmake = CMake(self)
        cmake.configure()
        cmake.build()

    def package(self):
        cmake = CMake(self)
        cmake.install()

    def package_info(self):
        self.cpp_info.libs = ["adas-interfaces"]
        self.cpp_info.set_property("cmake_target_name", "AdasInterfaces::AdasInterfaces")
        self.cpp_info.set_property("cmake_file_name", "AdasInterfaces")
