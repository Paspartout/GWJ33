tool
extends Level

func _ready():
	checkpoint_index += 1
	
	if game == null:
		MusicPlayer.start_playing()
		MusicPlayer.play_next()

func respawn():
	.respawn()
	player.has_grappling_hook = true

func _on_End_body_entered(body):
	game.load_next_level()
