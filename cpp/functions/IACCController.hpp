#pragma once

namespace adas { namespace perception { class TrackList; } }
namespace adas { namespace lane { class LaneModel; } }
namespace adas { namespace common { class VehicleState; } }
namespace adas { namespace control { class ControlCommand; } }

namespace adas { namespace functions {

class IACCController {
public:
    virtual ~IACCController() = default;
    virtual adas::control::ControlCommand evaluate(
        const adas::perception::TrackList& tracks,
        const adas::lane::LaneModel& lane,
        const adas::common::VehicleState& vehicle_state,
        float set_speed_mps) = 0;
};

}} // namespace adas::functions
