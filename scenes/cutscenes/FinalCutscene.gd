extends TextureRect

onready var game: Game = get_tree().root.get_node_or_null("Game")

func _on_DialogBox_finished():
	get_tree().change_scene("res://Scenes/MainMenu.tscn")

