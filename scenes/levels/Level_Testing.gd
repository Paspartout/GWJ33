tool
extends Level

func _ready():
	pass

func _respawn():
	._respawn()
	player.has_grappling_hook = true

func _on_CameraSwitch_body_entered(body):
	self.current_camera_bounds_index = 1
