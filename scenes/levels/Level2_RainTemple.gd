tool
extends Level

func _ready():
	var player: Player = get_tree().get_nodes_in_group("player")[0]
	player.has_grappling_hook = true
