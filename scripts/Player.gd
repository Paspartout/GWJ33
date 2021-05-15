extends KinematicBody2D

var velocity: Vector2 = Vector2.ZERO

export var max_speed: float = 300
export var acceleration: float = 20
export var decelleartion: float = 0.85
export var gravity: float = 10
export var jump_strength: float = 300

func _ready():
	pass # Replace with function body.

func _input(event):
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = -jump_strength

func _physics_process(delta):
	var input_x = Input.get_action_strength("right") - Input.get_action_strength("left")
	
	if input_x != 0.0:
		velocity.x += acceleration * input_x
	else:
		velocity.x *= decelleartion
	
	velocity.x = clamp(velocity.x, -max_speed, max_speed)
	velocity.y += gravity
	
	move_and_slide(velocity, Vector2.UP)
