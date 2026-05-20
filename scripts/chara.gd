class_name Chara extends CharacterBody2D
signal rhythm_turn_done(dir:Vector2)

@export var rpg_basesprite: Texture2D
@export var rhythm_basesprite: Texture2D
@export var turn_basesprite:Texture2D

@export var has_rhythm_process = false

func chara_process_rpg():
	pass

func chara_process_rhythm():
	await get_tree().process_frame
	rhythm_turn_done.emit(Vector2.ZERO)

func chara_process_turn():
	pass

func chara_process_other():
	pass
