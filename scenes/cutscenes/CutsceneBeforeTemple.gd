extends ColorRect

onready var game: Game = get_tree().root.get_node_or_null("Game")

func _ready():
	MusicPlayer.play_next()

func _on_DialogBox_finished():
	game.load_next_level()
