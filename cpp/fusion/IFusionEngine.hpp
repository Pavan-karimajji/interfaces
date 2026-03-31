#pragma once

namespace adas { namespace perception { class TrackList; } }
namespace adas { namespace fusion { class SceneModel; } }

namespace adas { namespace fusion {

/// @brief Interface for sensor fusion (future — 1V1R product)
class IFusionEngine {
public:
    virtual ~IFusionEngine() = default;
    virtual SceneModel fuse(const adas::perception::TrackList& camera_tracks) = 0;
    // Future: overload with radar input for 1V1R
};

}} // namespace adas::fusion
