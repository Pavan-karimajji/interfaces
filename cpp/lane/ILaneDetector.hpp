#pragma once

namespace adas { namespace isp { class ProcessedFrame; } }
namespace adas { namespace lane { class LaneModel; } }

namespace adas { namespace lane {

class ILaneDetector {
public:
    virtual ~ILaneDetector() = default;
    virtual LaneModel detect_lanes(const adas::isp::ProcessedFrame& frame) = 0;
};

}} // namespace adas::lane
