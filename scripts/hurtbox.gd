class_name Hurtbox extends Area2D
signal been_hit(damage_amount:int)
@export var is_players:bool

func _init() -> void:
	set_collision_mask_value(2,true)
	set_collision_mask_value(1,false)
	set_collision_layer_value(1,false)
	#area_entered.connect(emit_hit)
	
func emit_hit(hb:Area2D):
	
	if is_players != hb.is_players:
		been_hit.emit(hb.damage)
		#print("aaaaaaaa")
