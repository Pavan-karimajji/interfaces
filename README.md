# adas-interfaces

Central contract repository for the ADAS platform.

## What's here
- `proto/` — Protobuf data type definitions (generates C++ and Python)
- `cpp/` — C++ abstract interfaces (behavioral contracts)
- `adapters/` — Shared adapter base classes
- `cmake/` — Shared build configs and toolchain files

## Rules
- All cross-boundary data types MUST be defined here
- Component-internal types stay in their own repos
- Changes require 2+ architecture team approvals
- Protobuf backward compatibility enforced (no field removal/renumbering)
