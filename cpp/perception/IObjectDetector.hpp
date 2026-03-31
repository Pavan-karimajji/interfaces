#pragma once
#include <vector>

// Forward declarations — actual types generated from proto
namespace adas { namespace isp { class ProcessedFrame; } }
namespace adas { namespace perception { class DetectionList; } }

namespace adas { namespace perception {

/// @brief Interface for object detection components
/// Implement this in your detector (ML-based, classical, etc.)
class IObjectDetector {
public:
    virtual ~IObjectDetector() = default;

    /// @brief Run detection on a processed camera frame
    /// @param frame Processed frame from ISP pipeline
    /// @return List of detected objects with class, bbox, confidence
    virtual DetectionList detect(const adas::isp::ProcessedFrame& frame) = 0;
};

}} // namespace adas::perception
