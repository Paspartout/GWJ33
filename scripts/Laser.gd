extends Node2D

export var MAX_LENGTH = 50

onready var beam = $Beam
onready var end = $End
onready var raycast = $RayCast2D
export (String, "Half Rotation", "Full Rotation", "On - Off") var animation

func _physics_process(_delta):
	if raycast.is_colliding():
		end.global_position = raycast.get_collision_point()
	else:
		end.global_position = raycast.cast_to
	beam.rotation = raycast.cast_to.angle()
	beam.region_rect.end.x = end.position.length()
	var max_cast_to = raycast.cast_to.normalized() * MAX_LENGTH
	raycast.cast_to = max_cast_to
	


func _ready():
	# FIXME: make lasers collide with new tiles
	# TODO: add delay for animations to not play simultaneously
	$AnimationPlayer.play(animation)
