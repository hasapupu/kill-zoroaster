@tool
extends Resource
class_name ShakeProfile

## Drop one of the built-in presets from addons/camera_shake/presets/
## or create your own via File → New Resource → ShakeProfile.

# ── Offset ────────────────────────────────────────────────────────────────────

## Maximum pixel radius of the shake offset.
@export_range(0.0, 500.0, 0.1, "suffix:px") var intensity: float = 30.0

# ── Rotation ──────────────────────────────────────────────────────────────────

## Maximum rotation added by the shake (degrees).
@export_range(0.0, 45.0, 0.01, "suffix:°") var rotation_intensity: float = 2.0

# ── Timing ────────────────────────────────────────────────────────────────────

## How fast the trauma value drains per second.
## Expected duration ≈ initial_trauma / decay_rate.
@export_range(0.1, 20.0, 0.01, "suffix:trauma/s") var decay_rate: float = 2.0

## Controls the shape of the intensity curve over time.
## shake_amount = trauma ^ exponent
## 1.0 → linear decay
## 2.0 → stays strong then drops (cinematic feel, default)
## 3-4 → very snappy, drops quickly at the end
@export_range(1.0, 4.0, 0.01) var trauma_exponent: float = 2.0

## How much trauma to inject when shake() is called (0..1).
## Values below 1.0 let you trigger a softer version of the preset.
@export_range(0.0, 1.0, 0.01) var initial_trauma: float = 1.0

# ── Noise ─────────────────────────────────────────────────────────────────────

## Speed at which the noise oscillates. Higher = more frantic.
@export_range(1.0, 100.0, 0.1, "suffix:Hz") var frequency: float = 15.0

# ── Envelope (optional) ───────────────────────────────────────────────────────

## Optional curve that multiplies shake_amount over the shake's lifetime (0 → 1).
## Leave empty to rely purely on trauma decay.
## Example: an attack-sustain-release shape for a rumble that builds up.
@export var envelope: Curve
