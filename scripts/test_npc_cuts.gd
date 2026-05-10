class_name TestNPCCuts extends Cutscene

func do_cutscene():
	DialogueManager.show_example_dialogue_balloon(load("res://dialogue/test.dialogue"),"start")
	await DialogueManager.dialogue_ended
	await wait_for_action("ui_accept")

	done.emit()
