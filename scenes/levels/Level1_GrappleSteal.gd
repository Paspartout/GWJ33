tool
extends Level

func _on_End_body_entered(body):
	game.load_next_level()
