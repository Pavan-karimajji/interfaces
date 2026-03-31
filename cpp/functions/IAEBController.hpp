#pragma once

namespace adas { namespace perception { class TrackList; } }
namespace adas { namespace common { class VehicleState; } }
namespace adas { namespace control { class ControlCommand; } }

namespace adas { namespace functions {

/// @brief Interface for Autonomous Emergency Braking
class IAEBController {
public:
    virtual ~IAEBController() = default;

    /// @brief Evaluate AEB activation based on current tracks and vehicle state
    /// @return Control command (brake request if TTC below threshold)
    virtual adas::control::ControlCommand evaluate(
        const adas::perception::TrackList& tracks,
        const adas::common::VehicleState& vehicle_state) = 0;

    /// @brief Check if AEB is currently active
    virtual bool is_active() const = 0;
};

}} // namespace adas::functions
