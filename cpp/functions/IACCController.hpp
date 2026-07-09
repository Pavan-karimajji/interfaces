#pragma once

namespace adas { namespace perception { class GenObjectList; } }
namespace adas { namespace lane { class LaneModel; } }
namespace adas { namespace common { class VehDyn; } }
namespace adas { namespace control { class ControlCommand; } }

namespace adas { namespace df {

class IACCController {
public:
    virtual ~IACCController() = default;
    virtual adas::control::ControlCommand evaluate(
        const adas::perception::GenObjectList& objects,
        const adas::lane::LaneModel& lane,
        const adas::common::VehDyn& vehDyn,
        float set_speed_mps) = 0;
};

}} // namespace adas::df
