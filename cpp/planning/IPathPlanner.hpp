#pragma once

namespace adas { namespace fusion { class SceneModel; } }
namespace adas { namespace planning { class Trajectory; } }

namespace adas { namespace planning {

class IPathPlanner {
public:
    virtual ~IPathPlanner() = default;
    virtual Trajectory plan(const adas::fusion::SceneModel& scene) = 0;
};

}} // namespace adas::planning
