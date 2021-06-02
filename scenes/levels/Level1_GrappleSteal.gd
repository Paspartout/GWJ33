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

func _ready():
	player.controllable = false
	camera_player_attachement.update_position = false
	$Camera.current = true
	$Animations/AnimationPlayer.play("Hover")


func _on_AnimationPlayer_animation_finished(anim_name):
	player.controllable = true
	if anim_name == "Hover":
		$Camera.current = false
		camera_player_attachement.update_position = true
		camera.current = true
