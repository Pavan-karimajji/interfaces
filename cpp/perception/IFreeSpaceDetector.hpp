#pragma once

namespace adas { namespace isp { class ProcessedFrame; } }
namespace adas { namespace perception { class FreeSpaceContour; } }

namespace adas { namespace perception {

class IFreeSpaceDetector {
public:
    virtual ~IFreeSpaceDetector() = default;
    virtual FreeSpaceContour detect_free_space(const adas::isp::ProcessedFrame& frame) = 0;
};

}} // namespace adas::perception
