#pragma once

namespace adas { namespace perception { class GenObjectList; } }
namespace adas { namespace common { class VehDyn; } }
namespace adas { namespace control { class ControlCommand; } }

namespace adas { namespace functions {

/// @brief Interface for Autonomous Emergency Braking
class IAEBController {
public:
    virtual ~IAEBController() = default;

    /// @brief Evaluate AEB activation based on current objects and vehicle state
    /// @return Control command (brake request if TTC below threshold)
    virtual adas::control::ControlCommand evaluate(
        const adas::perception::GenObjectList& objects,
        const adas::common::VehDyn& vehDyn) = 0;

    /// @brief Check if AEB is currently active
    virtual bool is_active() const = 0;
};

}} // namespace adas::functions
