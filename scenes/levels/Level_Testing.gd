tool
extends Level

func _ready():
	pass

func respawn():
	.respawn()
	player.has_grappling_hook = true

func _on_CameraSwitch_body_entered(body):
	_set_camera_bounds(camera_boundaries[1])

# TODO: Make checkpoints more generic/clean this up
func _on_FirstCheckpoint_body_entered(body):
	print("Hi")
	$Checkpoints/FirstCheckpoint.monitoring = false
	checkpoint_index = 1

func _on_SecondCheckpoint_body_entered(body):
	checkpoint_index = 2
	$Checkpoints/FirstCheckpoint.monitoring = false
