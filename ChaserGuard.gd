extends KinematicBody2D

var run_speed = 100
var velocity = Vector2.ZERO
var player = null
var gravity =  10

func _physics_process(delta):
	velocity.y += gravity
	
	velocity = Vector2.ZERO
	if player:
		velocity = global_position.direction_to(player.global_position) * run_speed
	velocity = move_and_slide(velocity)

func _on_Detection_body_entered(body):
	if body.get_name() == "Player":
		player = body

func _on_Detection_body_exited(body):
	player = null
