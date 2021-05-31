tool
extends Level

func _on_End_body_entered(body):
	game.load_next_level()
	
func _on_item_pickup(item: Area2D):
	show_dialog([
		"Congratulations! You stole the grapling hook!",
		"Aim using the mouse and shoot using the left mouse button.",
	])
	player.has_grappling_hook = true
	item.visible = false
	item.set_deferred("monitorable", false)
