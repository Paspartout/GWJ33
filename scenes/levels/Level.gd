class_name Level
extends Node

var game: Game

func _ready():
	game = get_tree().root.get_node_or_null("Game")
	if not game:
		push_warning("Level run independently, no scene switching will work")
