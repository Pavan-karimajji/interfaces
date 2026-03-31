#pragma once

namespace adas { namespace lane { class LaneModel; } }
namespace adas { namespace common { class VehicleState; } }
namespace adas { namespace control { class ControlCommand; } }

namespace adas { namespace functions {

class ILKAController {
public:
    virtual ~ILKAController() = default;
    virtual adas::control::ControlCommand evaluate(
        const adas::lane::LaneModel& lane,
        const adas::common::VehicleState& vehicle_state) = 0;
};

}} // namespace adas::functions
