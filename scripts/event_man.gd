class_name EventManager extends Node

enum game_type {RPG,RHYTHM,TURN_BASED,OTHER}
@export var curr_charas := []
var curr_game_type: game_type = game_type.RHYTHM
@onready var env = get_node("Env")
@onready var cam = get_node("Camera2D")
@onready var y_sort_parent = get_node("YSort")
@export var default_scene:GameScene
@export var default_music :AudioFile
@onready var music := Audio.play_audio(default_music)
@export var intro_cuts_path: String
var is_savefile_empty := true
@export var inventory : Array = ["res://item/test_item.tres"]
@onready var inv_pref:PackedScene = preload("res://scenes/inventory.tscn")
var inv_active := false

var rpg_vars = {"in_cutscene":false}
var rhythm_vars = {"blocked_tiles":[],"npc_area_tiles":{Vector2(32,32):"res://scenes/test_npc_cuts.tscn"},"queued_cuts": null,"in_cutscene":false}

func _ready() -> void:
	var loaded_savefile := ResourceLoader.load("user://default.tres") as GameScene
	is_savefile_empty = loaded_savefile == null
	if is_savefile_empty:
		ResourceSaver.save(default_scene,"user://default.tres")
		loaded_savefile = ResourceLoader.load("user://default.tres")
	default_scene = loaded_savefile
	inventory = loaded_savefile.inventory
	print(default_scene)
		

func save():
	default_scene.rpg_vars = rpg_vars
	default_scene.rpg_vars["in_cutscene"]=false
	default_scene.rhythm_vars = rhythm_vars
	default_scene.rhythm_vars["in_cutscene"]=false
	default_scene.scene_type = curr_game_type
	default_scene.env_path = env.get_child(0).scene_file_path
	default_scene.inventory = inventory
	default_scene.charas.clear()
	for i in curr_charas:
		if i is not PlayerChara:
			default_scene.charas[i.scene_file_path] = i.global_position
		else:
			default_scene.player_pos = i.global_position
	default_scene.room_music = music.audio_file
	ResourceSaver.save(default_scene,"user://default.tres")
	

func load_default_scene():
	if is_savefile_empty:
		await play_cutscene_rpg(intro_cuts_path)
		pass
	print(default_scene)
	load_new_scene(default_scene)

func quit():
	get_tree().quit()

func apply_cs():
	get_node("Camera2D/CameraShake").add_trauma(2)
	print("aaaaaaaaaaahhhhhhhhhhhhhhhhhhhhhh")

func load_new_scene(scene_to_load : GameScene):
	print(scene_to_load)
	for i in y_sort_parent.get_children():
		i.queue_free()
	for i in env.get_children():
		i.queue_free()
	curr_charas.clear()
	Audio.play_audio(scene_to_load.room_music)
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
	new_playa.been_hit.connect(apply_cs)
	curr_charas.append(new_playa)
	if scene_to_load.room_music.id != music.audio_file.id:
		music = Audio.play_audio(scene_to_load.room_music)
	curr_game_type = scene_to_load.scene_type

func play_cutscene_rpg(curr_cut_path:String):
	var cut_res = load(curr_cut_path) as PackedScene
	var curr_cut:Cutscene = cut_res.instantiate()
	add_child(curr_cut)
	rpg_vars["in_cutscene"] = true
	curr_cut.event_man = self
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
						
					#await get_tree().create_timer(.2).timeout
			await  get_tree().process_frame
			rhythm_process()
	

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("menu") and inv_active == false and rpg_vars["in_cutscene"] == false and rhythm_vars["in_cutscene"] == false:
		show_inv()
	if Input.is_action_just_pressed("quit") and inv_active and rpg_vars["in_cutscene"] == false and rhythm_vars["in_cutscene"] == false:
		close_inv()
	match curr_game_type:
		game_type.RPG:
			if rpg_vars["in_cutscene"] == false :
				for i:Chara in curr_charas:
					i.chara_process_rpg()
					
func show_inv():
	inv_active = true
	var inv_node = inv_pref.instantiate()
	cam.add_child(inv_node)
	rpg_vars["in_cutscene"] = true
	rhythm_vars["in_cutscene"] = true
	var il : ItemList = inv_node.get_child(0)
	il.grab_focus()
	for i in inventory:
		var dasd = load(i) as Item
		il.add_item(dasd.name)
	if inventory.size() > 0:
		il.select(0)
	il.item_activated.connect(use_item)
	

func close_inv():
	inv_active = false
	cam.get_node("NinePatchRect").queue_free()
	rpg_vars["in_cutscene"] = false
	rhythm_vars["in_cutscene"] = false
	
func use_item(it_index:int):
	var it = load(inventory[it_index])
	for i in curr_charas:
		if i is PlayerChara:
			i.hp += it.heal_amount
			break
	if it.used_up:
		inventory.remove_at(it_index)
	if curr_game_type == game_type.RHYTHM:
		await play_cutscene_rhythm(it.my_cuts_path)
	else:
		await play_cutscene_rpg(it.my_cuts_path)
	close_inv()
