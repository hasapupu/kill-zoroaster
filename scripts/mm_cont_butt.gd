extends Button

@onready var ev_man : EventManager = owner.owner

func _process(delta) -> void:
	if ev_man.is_savefile_empty:
		text = "New Game"
	else:
		text = "Continue"
