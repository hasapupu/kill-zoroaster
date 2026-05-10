class_name GameScene extends Resource

@export var charas : Dictionary
@export var env_path : String
@export var player_path : String
@export var player_pos : Vector2
@export var scene_type : EventManager.game_type
@export var rpg_vars : Dictionary = {"in_cutscene":false}
@export var rhythm_vars : Dictionary = {"blocked_tiles":[],"npc_area_tiles":{Vector2(32,32):"res://scenes/test_npc_cuts.tscn"},"queued_cuts": null,"in_cutscene":false}
