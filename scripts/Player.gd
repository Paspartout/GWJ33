extends KinematicBody2D

export var max_speed: float = 250
export var acceleration: float = 20
export var decelleartion: float = 0.7
export var air_resistance: float = 0.6
export var gravity: float = 15
export var jump_strength: float = 300
export var number_of_double_jumps: int = 1
export var show_debug_info: bool = false

signal death

# wall_jump_vertical_force is the pushback and wall_jump_vertical_force is the actual jump height
export var wall_jump_vertical_force: float = 180
export var wall_jump_horizontal_bounce: float = 300

var jumps = 1
var movement_velocity: Vector2 = Vector2.ZERO
var velocity: Vector2 = Vector2.ZERO
var last_enemy_found

onready var grapple: GrapplingHook = $Items/GrapplingHook
onready var sprite: AnimatedSprite = $Sprite
#wall jump vars
onready var left_top_wall_raycast: RayCast2D = $WallRaycasts/Left/Top
onready var left_bottom_wall_raycast: RayCast2D = $WallRaycasts/Left/Bottom
onready var right_top_wall_raycast: RayCast2D = $WallRaycasts/Right/Top
onready var right_bottom_wall_raycast: RayCast2D = $WallRaycasts/Right/Bottom
onready var debug_label = $DebugLabel

func _ready():
	debug_label.visible = show_debug_info

func _input(event):
	if event.is_action_pressed("jump"):
		if not is_on_floor() and next_to_right_wall():
			velocity.y -= wall_jump_vertical_force
			velocity.x -= wall_jump_horizontal_bounce
			grapple.stop()
		elif not is_on_floor() and next_to_left_wall():
			velocity.y -= wall_jump_vertical_force
			velocity.y -= wall_jump_vertical_force
			velocity.x += wall_jump_horizontal_bounce
			grapple.stop()
		else:
			if jumps > 0:
				velocity.y = -jump_strength
				position.y -= 1 # Workaround https://godotengine.org/qa/49493/jumping-on-raising-platform
				jumps -= 1

			# Cancel jump if releasing jump key
			if event.is_action_released("jump") and velocity.y < -jump_strength/2:
				velocity.y = -jump_strength/2

var walk_velocity: Vector2 = Vector2.ZERO

func _physics_process(delta):
	var input_x = Input.get_action_strength("right") - Input.get_action_strength("left")
	
	if input_x != 0.0:
		velocity.x += acceleration * input_x
	else:
		velocity.x *= decelleartion

	# TODO: More generic item system
	if grapple.is_in_use():
		velocity += grapple.pull()
		velocity = velocity.clamped(700)
	else:
		velocity.x = clamp(velocity.x, -max_speed, max_speed)
		velocity.y = clamp(velocity.y, -500, 500)	

	if next_to_wall() and velocity.y > 30:
		velocity.y = 30

	if is_on_floor():
		jumps = number_of_double_jumps
	else:
		velocity.y += gravity
	#debug_label.text = "j: %d, g: %s" % [jumps, "true" if is_on_floor() else "false"]
	debug_label.text = "vel: (%d, %d)" % [velocity.x, velocity.y]
	
	if is_on_ceiling():
		velocity.y = 0
		
	velocity = move_and_slide_with_snap(velocity, Vector2.DOWN, Vector2.UP)
	
	_update_animation(input_x)
	
	if Input.is_action_pressed("Action") && $KillOptions/RichTextLabel.visible == true:
		# FIXME: if there's a wall between player and enemy, the enemy is still killed
		var enemy_to_kill = get_parent().get_node("Enemies").get_node(last_enemy_found)
		if enemy_to_kill.is_in_group("enemies"):
			enemy_to_kill.queue_free()


func _update_animation(input_x):
	# Update animation
	if input_x != 0:
		sprite.flip_h = input_x < 0

	if is_on_floor():
		sprite.animation = "Run" if input_x != 0 else "Idle"
	elif next_to_right_wall():
		sprite.animation = "WallJump"
		sprite.flip_h = true
	elif next_to_left_wall():
		sprite.animation = "WallJump"
		sprite.flip_h = false
	else:
		sprite.animation = "Jump"


func next_to_wall():
	return next_to_right_wall() or next_to_left_wall()

func next_to_right_wall():
	return right_top_wall_raycast.is_colliding() or right_bottom_wall_raycast.is_colliding()

func next_to_left_wall():
	return left_top_wall_raycast.is_colliding() or left_bottom_wall_raycast.is_colliding()


func kill():
	emit_signal("death")
	queue_free()


func _on_Area2D_body_entered(body):
	last_enemy_found = body.name
	$KillOptions/RichTextLabel.visible = true
	$"KillOptions/Action Key".visible = true
	debug_label.visible = false


func _on_Area2D_body_exited(body):
	$KillOptions/RichTextLabel.visible = false
	$"KillOptions/Action Key".visible = false
	debug_label.visible = show_debug_info
