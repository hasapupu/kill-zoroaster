class_name TestItemCuts extends Cutscene

func do_cutscene():
	await show_dialogue("res://dialogue/test_item.dialogue")
	done.emit()
