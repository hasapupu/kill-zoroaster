class_name EventManager extends Node

enum game_type {RPG,RHYTHM,TURN_BASED,OTHER}
@export var curr_charas := []
var curr_game_type: game_type = game_type.RHYTHM
@onready var env = get_node("Env")
@onready var cam = get_node("Camera2D")
@onready var y_sort_parent = get_node("YSort")
@export var default_scene:GameScene

var rpg_vars = {"in_cutscene":false}
var rhythm_vars = {"blocked_tiles":[],"npc_area_tiles":{Vector2(32,32):"res://scenes/test_npc_cuts.tscn"},"queued_cuts": null,"in_cutscene":false}

#deb
func _ready() -> void:
	load_new_scene(default_scene)
	rhythm_process()
#deb end

func load_new_scene(scene_to_load : GameScene):
	for i in y_sort_parent.get_children():
		i.queue_free()
	for i in env.get_children():
		i.queue_free()
	curr_charas.clear()
	
	for i in scene_to_load.rhythm_vars.keys():
		rhythm_vars[i] = scene_to_load.rhythm_vars[i]
	for i in scene_to_load.rpg_vars.keys():
		rpg_vars[i] = scene_to_load.rpg_vars[i]
	
	var new_env = load(scene_to_load.env_path).instantiate()
	env.add_child(new_env)
	for i in scene_to_load.charas.keys():
		var coords = scene_to_load.charas[i]
		var new_chara = load(i).instantiate()
		y_sort_parent.add_child(new_chara)
		new_chara.global_position = coords
		if new_chara is NPChara:
			new_chara.event_man = self
		curr_charas.append(new_chara)
	var new_playa = load(scene_to_load.player_path).instantiate()
	new_playa.global_position = scene_to_load.player_pos
	y_sort_parent.add_child(new_playa)
	curr_charas.append(new_playa)
	curr_game_type = scene_to_load.scene_type

func play_cutscene_rpg(curr_cut_path:String):
	var cut_res = load(curr_cut_path) as PackedScene
	var curr_cut:Cutscene = cut_res.instantiate()
	add_child(curr_cut)
	rpg_vars["in_cutscene"] = true
	curr_cut.setup_vars()
	curr_cut.do_cutscene()
	await curr_cut.done
	rpg_vars["in_cutscene"] = false
	curr_cut.queue_free()

func play_cutscene_rhythm(curr_cut_path:String):
	var cut_res = load(curr_cut_path) as PackedScene
	var curr_cut:Cutscene = cut_res.instantiate()
	add_child(curr_cut)
	rhythm_vars["in_cutscene"] = true
	curr_cut.setup_vars()
	curr_cut.do_cutscene()
	await curr_cut.done
	rhythm_vars["in_cutscene"] = false
	curr_cut.queue_free()
	
func rhythm_process():
	match curr_game_type:
		game_type.RHYTHM:
			if rhythm_vars["in_cutscene"] == false:
				for i in curr_charas:
					var dir := Vector2.ZERO
					if i.has_rhythm_process:
						i.chara_process_rhythm()
						dir = await i.rhythm_turn_done
					if !dir.is_zero_approx():
						if dir in rhythm_vars["blocked_tiles"]:
							pass
						elif dir in rhythm_vars["npc_area_tiles"]:
							play_cutscene_rhythm(rhythm_vars["npc_area_tiles"][dir])
							break
						else:
							var tween = get_tree().create_tween()
							tween.tween_property(i,"global_position",dir,.3)
							await tween.finished
						
					await get_tree().create_timer(.2).timeout
			await  get_tree().process_frame
			rhythm_process()
	

func _process(delta: float) -> void:
	match curr_game_type:
		game_type.RPG:
			if rpg_vars["in_cutscene"] == false:
				for i:Chara in curr_charas:
					i.chara_process_rpg()
