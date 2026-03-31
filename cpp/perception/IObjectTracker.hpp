#pragma once

namespace adas { namespace perception { class DetectionList; class TrackList; } }

namespace adas { namespace perception {

/// @brief Interface for multi-object tracking
class IObjectTracker {
public:
    virtual ~IObjectTracker() = default;

    /// @brief Update tracks with new detections
    /// @param detections Latest detection list from detector
    /// @return Updated track list (confirmed + tentative + coasting)
    virtual TrackList update(const DetectionList& detections) = 0;

    /// @brief Reset all tracks (e.g., on sensor failure)
    virtual void reset() = 0;
};

}} // namespace adas::perception
