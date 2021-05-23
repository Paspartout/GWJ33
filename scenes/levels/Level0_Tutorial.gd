extends Level

func _on_End_body_entered(_body):
	print("ENDD")
	game.load_next_level()
