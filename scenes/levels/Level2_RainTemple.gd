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
