class_name Cutscene extends Node
signal done
var event_man : EventManager

func wait_for_action(act):
	while Input.is_action_just_pressed(act):
		await get_tree().process_frame

func setup_vars():
	pass
func do_cutscene():
	pass
