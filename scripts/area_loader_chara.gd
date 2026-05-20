class_name LoadingZoneChara extends NPChara

@export var my_game_scene :GameScene

func chara_process_rpg():
	var bodies = my_area.get_overlapping_bodies()
	if bodies.size() > 0:
		for i in bodies:
			if i.is_in_group("player_body"):
				event_man.load_new_scene(my_game_scene)

func chara_process_rhythm():
	#await get_tree().create_timer(.1).timeout
	rhythm_turn_done.emit(Vector2.ZERO)
