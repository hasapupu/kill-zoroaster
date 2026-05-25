## ExampleScene.gd
## Attach to a Node2D that has a Camera2D child with a CameraShake child.
##
## Scene tree:
##   Node2D  ← this script
##   └── Camera2D
##       └── CameraShake
extends Node2D

@onready var shake: CameraShake = $Camera2D/CameraShake

# Presets loaded from files.
var preset_explosion: ShakeProfile = preload("res://addons/camera_shake/presets/explosion.tres")
var preset_earthquake: ShakeProfile = preload("res://addons/camera_shake/presets/earthquake.tres")
var preset_impact: ShakeProfile    = preload("res://addons/camera_shake/presets/impact.tres")
var preset_jitter: ShakeProfile    = preload("res://addons/camera_shake/presets/jitter.tres")
var preset_rumble: ShakeProfile    = preload("res://addons/camera_shake/presets/rumble.tres")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):   # Space / Enter
		shake.shake(preset_explosion)
	elif event.is_action_pressed("ui_up"):
		shake.shake(preset_earthquake)
	elif event.is_action_pressed("ui_right"):
		shake.shake(preset_impact)
	elif event.is_action_pressed("ui_down"):
		shake.shake(preset_jitter)
	elif event.is_action_pressed("ui_left"):
		shake.shake(preset_rumble)

# ── Extending the API ─────────────────────────────────────────────────────────

# You can also compose shakes or add trauma gradually, e.g. per bullet hit:
func _on_bullet_hit() -> void:
	shake.add_trauma(0.25)  # stacks up; 4 hits = full trauma

# Or build a profile in code at runtime:
func _custom_shake_example() -> void:
	var p := ShakeProfile.new()
	p.intensity = 50.0
	p.rotation_intensity = 3.0
	p.decay_rate = 4.0
	p.frequency = 30.0
	p.initial_trauma = 0.9
	shake.shake(p)
