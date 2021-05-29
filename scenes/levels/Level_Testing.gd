tool
extends Level

func _ready():
	pass

func respawn():
	.respawn()
	player.has_grappling_hook = true
