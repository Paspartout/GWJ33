tool
extends Level

func _ready():
	pass

func _respawn():
	._respawn()
	player.has_grappling_hook = true

func _on_CameraSwitch_body_entered(body):
	_set_camera_bounds(camera_boundaries[1])
