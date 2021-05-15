extends KinematicBody2D

# movement vars
var velocity: Vector2 = Vector2.ZERO

export var max_speed: float = 300
export var acceleration: float = 20
export var decelleartion: float = 0.85
export var gravity: float = 10
export var jump_strength: float = 300

onready var grapple: GrapplingHook = $Items/GrapplingHook
export var grapple_indicator_path: NodePath
#wall jump vars
onready var left_wall_raycast = $WallRaycasts/LeftWalls
onready var right_wall_raycast = $WallRaycasts/RightWalls

# wall jump is the pushback and jump wall is the actual jump height
var wall_jump = 500
var jump_Wall = 60
var jumps = 2


func _ready():
	grapple.grapple_indicator = get_node(grapple_indicator_path)

func _input(event):
	#if next_to_wall() and velocity.y > 30:
		#velocity.y = 25
		#meant to do wall sliding but doesnt work


	if event.is_action_pressed("jump") and jumps > 0:
		velocity.y = -jump_strength
		jumps -= 1 
		print(jumps)
		if not is_on_floor() and next_to_right_wall():
			velocity.x += wall_jump
			velocity.y -= jump_Wall
			jumps -= 1
		if not is_on_floor() and next_to_left_wall():
			velocity.x -= wall_jump
			velocity.y -= jump_Wall
			jumps -= 1
		else:
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
		pass
	else:
		velocity.y += gravity
		
	if is_on_ceiling():
		velocity.y = 0
	
	if is_on_floor():
		jumps = 2
	
	
	move_and_slide(velocity, Vector2.UP)
	

func next_to_wall():
	return next_to_right_wall() or next_to_left_wall()

func next_to_right_wall():
	return $WallRaycasts/RightWalls/RayCast2D2.is_colliding()

func next_to_left_wall():
	return $WallRaycasts/LeftWalls/RayCast2D2.is_colliding()


