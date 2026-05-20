# adas-interfaces

Central contract repository for the ADAS platform.

## What is here

- `proto/` — Protobuf data type definitions (generates C++ and Python)
- `cpp/` — C++ abstract interfaces (behavioral contracts)
- `cpp/proto_stubs.hpp` — Temporary concrete placeholder types until generated protobuf C++ is wired into the build
- `adapters/` — Shared adapter base classes (when added)
- `cmake/AdasInterfacesConfig.cmake` — `find_package(AdasInterfaces)` for sibling component builds (set `AdasInterfaces_DIR` to this `cmake/` directory)

## Rules

- All cross-boundary data types MUST be defined here
- Component-internal types stay in their own repos
- Changes require 2+ architecture team approvals
- Protobuf backward compatibility enforced (no field removal/renumbering)
