class_name PlayerChara extends Chara

var trav_distance = 80
var coll_distance = 16
var dashing:=false
var dash_dir:Vector2
var dash_dist = 700
const  max_hp = 100
var hp = 100
var dash_start_pos:= Vector2.ZERO
var dash_time:= .1
@onready var dash_timer:Timer = get_node("DashTimer")
var cs_node:CameraShake
var damageable := true
@onready var inv_timer:Timer = get_node("InvTimer")
@onready var inv_shader:Shader = preload("res://scripts/shaders/blinking.gdshader")
@onready var def_shader:= Shader.new()
@onready var sprite:Sprite2D = get_node("Sprite2D")
@export var hit_sfx:AudioFile
@export var dash_sfx:AudioFile
var inventory:Array
signal died

func _init() -> void:
	has_rhythm_process = true

func chara_process_rpg():
	if hp > max_hp: 
		hp = max_hp
	var dir = Input.get_vector("left","right","up","down").normalized()
	if dashing:		
		velocity = dash_dir * dash_dist
		move_and_slide()
		return
	elif  Input.is_action_just_pressed("dash"):
		dashing = true
		dash_dir = dir
		dash_start_pos = global_position
		dash_timer.wait_time = dash_time
		dash_timer.start()
		Audio.play_audio(dash_sfx)
		return
	dir *= trav_distance
	velocity = dir
	move_and_slide()
		
func chara_process_rhythm():
	var dir = Input.get_vector("left","right","up","down").normalized()
	await  get_tree().process_frame
	while dir.is_zero_approx():
		await get_tree().process_frame
		dir = Input.get_vector("left","right","up","down").normalized()
	rhythm_turn_done.emit(global_position+(dir * 16))

func _on_dash_timer_timeout() -> void:
	dashing = false

func emit_hit(damage_amount):
	if damageable:
		hp -= damage_amount
		damageable = false
		var shmat = ShaderMaterial.new()
		shmat.shader = inv_shader
		sprite.material = shmat
		Audio.play_audio(hit_sfx)
		inv_timer.start()
		been_hit.emit()

func _on_inv_timer_timeout() -> void:
	damageable = true
	var shmat = ShaderMaterial.new()
	shmat.shader = def_shader
	sprite.material = shmat

func _process(delta: float) -> void:
	if hp <= 0:
		died.emit()
