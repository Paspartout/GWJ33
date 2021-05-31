tool
extends Level

func _ready():
	if game == null:
		MusicPlayer.start_playing()
		MusicPlayer.play_next()

func _on_End_body_entered(body):
	game.load_next_level()

func _post_respawn():
	player.has_grappling_hook = true
