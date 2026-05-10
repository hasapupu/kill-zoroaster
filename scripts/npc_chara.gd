class_name NPChara extends Chara
#chai tea

@export var my_cuts_path : String
@onready var my_area = get_node("Area2D")
var event_man : EventManager

func chara_process_rpg():
	var bodies = my_area.get_overlapping_bodies()
	if bodies.size() > 0:
		for i in bodies:
			if i.is_in_group("player_body"):
				if Input.is_action_just_pressed("ui_accept"):
					event_man.play_cutscene_rpg(my_cuts_path)

func chara_process_rhythm():
	#await get_tree().create_timer(.1).timeout
	rhythm_turn_done.emit(Vector2.ZERO)
