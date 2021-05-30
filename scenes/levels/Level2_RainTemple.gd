tool
extends Level

func _ready():	
	if game == null:
		MusicPlayer.start_playing()
		MusicPlayer.play_next()

func _respawn():
	._respawn()
	player.has_grappling_hook = true

func _on_End_body_entered(body):
	game.load_next_level()
