class_name Cutscene extends Node
signal done
var event_man : EventManager

func wait_for_action(act):
	while Input.is_action_just_pressed(act):
		await get_tree().process_frame

func show_dialogue(path:String):
	DialogueManager.show_example_dialogue_balloon(load(path),"start")
	await DialogueManager.dialogue_ended
	await wait_for_action("ui_accept")

func setup_vars():
	pass
func do_cutscene():
	pass
