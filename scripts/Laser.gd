extends Node2D

const MAX_LENGTH = 2080

onready var beam = $Beam
onready var end = $End
onready var raycast = $RayCast2D

func _physics_process(delta):
	if raycast.is_colliding():
		end.global_position = raycast.get_collision_point()
	else:
		end.global_position = raycast.cast_to
	beam.rotation = raycast.cast_to.angle()
	beam.region_rect.end.x = end.position.length()
	var mouse_position = get_local_mouse_position()
	var max_cast_to = mouse_position.normalized() * MAX_LENGTH
	raycast.cast_to = max_cast_to
	


#func _ready():
	#$AnimationPlayer.play("Rotation")
