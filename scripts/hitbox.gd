class_name Hitbox extends Area2D

@export var damage:int
@export var is_players:bool

func _ready() -> void:
	set_collision_mask_value(1,false)
	set_collision_layer_value(1,false)
	set_collision_layer_value(2,true)
