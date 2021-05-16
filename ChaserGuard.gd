extends KinematicBody2D

export var run_speed = 70
var velocity = Vector2.ZERO
var player = null
export var gravity =  30

func _physics_process(delta):
	if player:
		var player_direction = global_position.direction_to(player.global_position) * run_speed
		velocity.x = player_direction.x
	velocity.y += gravity
	velocity = move_and_slide(velocity)
func _on_Detection_body_entered(body):
	player = body

func _on_Detection_body_exited(body):
	player = null
	velocity = Vector2.ZERO
