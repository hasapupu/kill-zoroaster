class_name IntroCuts extends Cutscene

func do_cutscene():
	await show_dialogue("res://dialogue/intro.dialogue")
	done.emit()
