extends KinematicBody2D

var velocity: Vector2 = Vector2.ZERO

export var max_speed: float = 300
export var acceleration: float = 20
export var decelleartion: float = 0.85
export var gravity: float = 10
export var jump_strength: float = 300

onready var grapple: GrapplingHook = $Items/GrapplingHook
export var grapple_indicator_path: NodePath

func _ready():
	grapple.grapple_indicator = get_node(grapple_indicator_path)

func _input(event):
	if is_on_floor():
		if event.is_action_pressed("jump"):
			velocity.y = -jump_strength
	else:
		if event.is_action_released("jump") and velocity.y < -jump_strength/2:
			velocity.y = -jump_strength/2

func _process(delta):
	# TODO: Rework for controller input
	pass

func _physics_process(delta):
	var input_x = Input.get_action_strength("right") - Input.get_action_strength("left")
	
	if input_x != 0.0:
		velocity.x += acceleration * input_x
	else:
		velocity.x *= decelleartion

	# TODO: More generic item system
	velocity += grapple.pull()

	velocity.x = clamp(velocity.x, -max_speed, max_speed)
	velocity.y = clamp(velocity.y, -max_speed, max_speed)

	if is_on_floor():
		pass
	else:
		velocity.y += gravity
		
	if is_on_ceiling():
		velocity.y = 0
	
	
	move_and_slide(velocity, Vector2.UP)
