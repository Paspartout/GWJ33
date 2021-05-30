tool
extends Level

func _ready():
	pass

func _respawn():
	._respawn()
	player.has_grappling_hook = true


# TODO: Refactor these similar to the checkpoints
func _on_CameraSwitchDown_body_entered(body):
	if self.current_camera_bounds_index != 1:
		self.current_camera_bounds_index = 1

func _on_CameraSwitchUp_body_entered(body):
	if self.current_camera_bounds_index != 0:
		self.current_camera_bounds_index = 0
