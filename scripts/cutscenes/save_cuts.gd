class_name SaveCuts extends Cutscene

func do_cutscene():
	await  show_dialogue("res://dialogue/save.dialogue")
	event_man.save()
	done.emit()
