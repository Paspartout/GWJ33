extends Level

func _ready():
	pass

func _on_End_body_entered(_body):
	game.load_next_level()
