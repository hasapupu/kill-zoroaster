@tool
extends Node
class_name CameraShake

## Trauma-based camera shake for Camera2D.
##
## Usage:
##   1. Add a CameraShake node as a child of your Camera2D.
##   2. Call shake(profile) with any ShakeProfile resource.
##   3. Or call add_trauma(0..1) for cumulative effects (e.g. per bullet hit).
##
## Trauma system:
##   shake_amount = trauma ^ profile.trauma_exponent
##   trauma decays at profile.decay_rate per second.
##   Traumas from multiple calls stack (capped at 1.0).

# ── Signals ───────────────────────────────────────────────────────────────────

## Emitted when a shake begins (trauma goes from 0 → above 0).
signal shake_started(profile: ShakeProfile)

## Emitted when trauma reaches zero.
signal shake_finished

# ── Properties ────────────────────────────────────────────────────────────────

## Master toggle. Disabling mid-shake cleanly restores the camera.
@export var enabled: bool = true:
	set(v):
		enabled = v
		if not v:
			_clear_shake()

# ── Private state ─────────────────────────────────────────────────────────────

var _camera: Camera2D
var _noise: FastNoiseLite

var _trauma: float = 0.0
var _noise_time: float = 0.0
var _elapsed: float = 0.0
var _expected_duration: float = 0.0

# The offset/rotation we applied last frame — subtracted before reapplying.
var _applied_offset: Vector2 = Vector2.ZERO
var _applied_rotation: float = 0.0

var _profile: ShakeProfile
var _is_shaking: bool = false

# ── Lifecycle ─────────────────────────────────────────────────────────────────

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	_camera = get_parent() as Camera2D
	if not _camera:
		push_error("CameraShake: must be a direct child of Camera2D.")
		return
	_setup_noise()

func _setup_noise() -> void:
	_noise = FastNoiseLite.new()
	_noise.seed = randi()
	_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	_noise.frequency = 0.5  # scaled per-profile via _noise_time * frequency

# ── API ────────────────────────────────────────────────────────────────

func shake(profile: ShakeProfile) -> void:
	if Engine.is_editor_hint() or not enabled or not profile:
		return
	_profile = profile
	_elapsed = 0.0
	_expected_duration = profile.initial_trauma / maxf(profile.decay_rate, 0.001)
	add_trauma(profile.initial_trauma)


func add_trauma(amount: float) -> void:
	if Engine.is_editor_hint() or not enabled:
		return
	var was_zero := _trauma <= 0.0
	_trauma = minf(_trauma + amount, 1.0)
	if was_zero and _trauma > 0.0:
		_noise_time = 0.0
		_is_shaking = true
		emit_signal("shake_started", _profile)

func stop() -> void:
	_trauma = 0.0
	_clear_shake()

func is_shaking() -> bool:
	return _trauma > 0.0

func get_trauma() -> float:
	return _trauma

# ── Processing ────────────────────────────────────────────────────────────────

func _process(delta: float) -> void:
	if Engine.is_editor_hint() or not _camera or not enabled:
		return

	# Undo last frame's contribution so external offset changes are preserved.
	_camera.offset -= _applied_offset
	_camera.rotation -= _applied_rotation

	if _trauma <= 0.0:
		_applied_offset = Vector2.ZERO
		_applied_rotation = 0.0
		if _is_shaking:
			_is_shaking = false
			emit_signal("shake_finished")
		return

	_elapsed += delta
	_noise_time += delta

	var decay: float = _profile.decay_rate if _profile else 2.0
	_trauma = maxf(_trauma - decay * delta, 0.0)

	# Base shake amount from trauma curve.
	var exponent: float = _profile.trauma_exponent if _profile else 2.0
	var shake_amount: float = pow(_trauma, exponent)

	# Optional envelope modulation.
	if _profile and _profile.envelope and _expected_duration > 0.0:
		var t := minf(_elapsed / _expected_duration, 1.0)
		shake_amount *= _profile.envelope.sample(t)

	# Per-profile values.
	var px_intensity: float = _profile.intensity if _profile else 30.0
	var rot_intensity: float = _profile.rotation_intensity if _profile else 2.0
	var freq: float = _profile.frequency if _profile else 15.0

	# Sample independent noise axes.
	var t := _noise_time * freq
	var ox: float = _noise.get_noise_2d(t, 0.0) * px_intensity * shake_amount
	var oy: float = _noise.get_noise_2d(0.0, t) * px_intensity * shake_amount
	var rot: float = deg_to_rad(_noise.get_noise_2d(t, t) * rot_intensity * shake_amount)

	_applied_offset = Vector2(ox, oy)
	_applied_rotation = rot

	_camera.offset += _applied_offset
	_camera.rotation += _applied_rotation

# ── Helpers ───────────────────────────────────────────────────────────────────

func _clear_shake() -> void:
	if _camera:
		_camera.offset -= _applied_offset
		_camera.rotation -= _applied_rotation
	_applied_offset = Vector2.ZERO
	_applied_rotation = 0.0
	if _is_shaking:
		_is_shaking = false
		emit_signal("shake_finished")
