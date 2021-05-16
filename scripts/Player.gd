extends KinematicBody2D

export var max_speed: float = 300
export var acceleration: float = 20
export var decelleartion: float = 0.85
export var air_resistance: float = 0.85
export var gravity: float = 10
export var jump_strength: float = 300
export var number_of_jumps: int = 2

# wall_jump_vertical_force is the pushback and wall_jump_vertical_force is the actual jump height
export var wall_jump_vertical_force: float = 60
export var wall_jump_horizontal_bounce: float = 500
var jumps = 2
# movement vars
var velocity: Vector2 = Vector2.ZERO

onready var grapple: GrapplingHook = $Items/GrapplingHook
#wall jump vars
onready var left_wall_raycast = $WallRaycasts/LeftWalls
onready var right_wall_raycast = $WallRaycasts/RightWalls

func _ready():
	pass

func _input(event):
	#if next_to_wall() and velocity.y > 30:
		#velocity.y = 25
		#meant to do wall sliding but doesnt work

	if event.is_action_pressed("jump") and jumps > 0:
		velocity.y = -jump_strength
		jumps -= 1 
		if not is_on_floor() and next_to_right_wall():
			velocity.x += wall_jump_horizontal_bounce
			velocity.y -= wall_jump_vertical_force
			jumps -= 1
		if not is_on_floor() and next_to_left_wall():
			velocity.x -= wall_jump_horizontal_bounce
			velocity.y -= wall_jump_vertical_force
			jumps -= 1
		else:
			# Cancel jump if releasing jump key
			if event.is_action_released("jump") and velocity.y < -jump_strength/2:
				velocity.y = -jump_strength/2

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
		jumps = number_of_jumps
	else:
		velocity.y += gravity

	if is_on_ceiling():
		velocity.y = 0

	move_and_slide(velocity, Vector2.UP)


func next_to_wall():
	return next_to_right_wall() or next_to_left_wall()

func next_to_right_wall():
	return $WallRaycasts/RightWalls/RayCast2D2.is_colliding()

func next_to_left_wall():
	return $WallRaycasts/LeftWalls/RayCast2D2.is_colliding()


