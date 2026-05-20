class_name AreaLoadCuts extends Cutscene

@export var game_scene_to_load : GameScene

func  do_cutscene():
	event_man.load_new_scene(game_scene_to_load)
	done.emit()
