#pragma once
// Temporary concrete types until protobuf-generated headers are wired into AdasInterfaces.
// Keep names aligned with .proto packages (adas.perception, adas.isp, adas.control, adas.common).

namespace adas { namespace isp {
struct ProcessedFrame {};
}}

namespace adas { namespace perception {
struct GenObjectList {};
struct FreeSpaceContour {};
}}

namespace adas { namespace common {
struct VehDyn {};
}}

namespace adas { namespace control {
struct ControlCommand {};
}}
