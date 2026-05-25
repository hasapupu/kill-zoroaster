@tool
extends EditorPlugin

const CAMERA_SHAKE_SCRIPT := preload("res://addons/camera_shake/camera_shake.gd")
const SHAKE_PROFILE_SCRIPT := preload("res://addons/camera_shake/shake_profile.gd")
const ICON := preload("res://addons/camera_shake/icons/CameraShake.svg")

func _enter_tree() -> void:
	add_custom_type("CameraShake", "Node", CAMERA_SHAKE_SCRIPT, ICON)
	add_custom_type("ShakeProfile", "Resource", SHAKE_PROFILE_SCRIPT, null)

func _exit_tree() -> void:
	remove_custom_type("CameraShake")
	remove_custom_type("ShakeProfile")
