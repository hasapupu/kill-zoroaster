class_name PlayerChara extends Chara

var trav_distance = 1
var coll_distance = 16
func _init() -> void:
	has_rhythm_process = true

func chara_process_rpg():
	var dir = Input.get_vector("left","right","up","down").normalized() * trav_distance
	var space_state = get_world_2d().direct_space_state
	var from = global_position
	var to = global_position + (dir * coll_distance) # your intended movement
	var params = PhysicsRayQueryParameters2D.new()
	params.from = from
	params.to = to
	var result = space_state.intersect_ray(params)
	if result:
		pass
	else:
		global_position += dir
		
func chara_process_rhythm():
	var dir = Input.get_vector("left","right","up","down").normalized()
	await  get_tree().process_frame
	while dir.is_zero_approx():
		await get_tree().process_frame
		dir = Input.get_vector("left","right","up","down").normalized()
	rhythm_turn_done.emit(global_position+(dir * 16))
	
