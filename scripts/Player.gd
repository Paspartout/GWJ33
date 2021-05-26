class_name Player
extends KinematicBody2D

export var max_speed: float = 250
export var acceleration: float = 20
export var decelleartion: float = 0.7
export var air_resistance: float = 0.6
export var gravity: float = 15
export var jump_strength: float = 300
export var number_of_double_jumps: int = 1
export var show_debug_info: bool = false
export var has_grappling_hook: bool = false setget _set_has_grappling_hook

signal death

# wall_jump_vertical_force is the pushback and wall_jump_vertical_force is the actual jump height
export var wall_jump_vertical_force: float = 180
export var wall_jump_horizontal_bounce: float = 300

var alive = true
var jumps = 1
var movement_velocity: Vector2 = Vector2.ZERO
var velocity: Vector2 = Vector2.ZERO
var enemey_in_range: Node2D = null

onready var grapple: GrapplingHook = $Items/GrapplingHook
onready var items: Node = $Items

onready var sprite: AnimatedSprite = $Sprite
#wall jump vars
onready var left_top_wall_raycast: RayCast2D = $WallRaycasts/Left/Top
onready var left_bottom_wall_raycast: RayCast2D = $WallRaycasts/Left/Bottom
onready var right_top_wall_raycast: RayCast2D = $WallRaycasts/Right/Top
onready var right_bottom_wall_raycast: RayCast2D = $WallRaycasts/Right/Bottom
onready var debug_label = $DebugLabel
onready var kill_hint = $StealthKillHint
onready var attack_area = $AttackArea
onready var attack_area_x = attack_area.position.x
onready var level

func _ready():
	debug_label.visible = show_debug_info
	var levels = get_tree().get_nodes_in_group("level")
	if levels.size() == 1:
		level = levels[0]
	else:
		push_warning("No level found! Things may break.")

func _input(event):
	if event.is_action_pressed("jump"):
		if not is_on_floor() and next_to_right_wall():
			velocity.y -= wall_jump_vertical_force
			velocity.x -= wall_jump_horizontal_bounce
			grapple.stop()
			$Sounds/SecondJump.play()
		elif not is_on_floor() and next_to_left_wall():
			velocity.y -= wall_jump_vertical_force
			velocity.y -= wall_jump_vertical_force
			velocity.x += wall_jump_horizontal_bounce
			grapple.stop()
			$Sounds/SecondJump.play()
		else:
			# TODO: find a way to know when 2nd jump is being used
			if jumps > 0:
				$Sounds/SecondJump.play()
				velocity.y = -jump_strength
				position.y -= 1 # Workaround https://godotengine.org/qa/49493/jumping-on-raising-platform
				jumps -= 1

			# Cancel jump if releasing jump key
			if event.is_action_released("jump") and velocity.y < -jump_strength/2:
				velocity.y = -jump_strength/2
	if has_grappling_hook and event.is_action_pressed("graple"):
		grapple.shoot()

var walk_velocity: Vector2 = Vector2.ZERO

func _physics_process(delta):
	if not alive:
		return
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
	
	if show_debug_info:
		#debug_label.text = "j: %d, g: %s" % [jumps, "true" if is_on_floor() else "false"]
		debug_label.text = "vel: (%d, %d)" % [velocity.x, velocity.y]
	
	if is_on_ceiling():
		velocity.y = 0
		
	velocity = move_and_slide_with_snap(velocity, Vector2.DOWN, Vector2.UP)
	
	_update_animation(input_x)
	
	if enemey_in_range and Input.is_action_pressed("Action"):
		if enemey_in_range.is_in_group("enemies"):
			$Sounds/Kill.play()
			enemey_in_range.kill()


func _update_animation(input_x):
	# Update animation
	if input_x != 0:
		sprite.flip_h = input_x < 0
		attack_area.position.x = -attack_area_x if input_x < 0 else attack_area_x

	if is_on_floor():
		if input_x != 0:
			if not $Sounds/Walking.is_playing():
				$Sounds/Walking.play(1)
			sprite.animation = "Run"
		else:
			sprite.animation = "Idle"
			$Sounds/Walking.stop()
	elif next_to_right_wall():
		sprite.animation = "WallJump"
		sprite.flip_h = true
		$Sounds/Walking.stop()
	elif next_to_left_wall():
		sprite.animation = "WallJump"
		sprite.flip_h = false
		$Sounds/Walking.stop()
	else:
		if velocity.y <= 0:
			sprite.animation = "Jump"
			$Sounds/Walking.stop()
		else:
			sprite.animation = "Landing"
			$Sounds/Walking.stop()


func next_to_wall():
	return next_to_right_wall() or next_to_left_wall()

func next_to_right_wall():
	return right_top_wall_raycast.is_colliding() or right_bottom_wall_raycast.is_colliding()

func next_to_left_wall():
	return left_top_wall_raycast.is_colliding() or left_bottom_wall_raycast.is_colliding()

func kill():
	if alive:
		alive = false
		visible = false
		$Sounds/Death.play()
		yield($Sounds/Death, "finished")
		emit_signal("death")

func get_jumps():
	return jumps

func _on_AttackArea_body_entered(body):
	enemey_in_range = body
	kill_hint.visible = true

func _on_AttackArea_body_exited(_body):
	enemey_in_range = null
	kill_hint.visible = false

func _on_ItemCollectionArea_area_entered(item: Area2D):
	$Sounds/Pickup.play()
	level.show_dialog([
		"Congratulations! You stole the grapling hook!",
		"Aim using the mouse and shoot using the left mouse button.",
		])
	self.has_grappling_hook = true
	item.visible = false
	item.set_deferred("monitorable", false)

func _set_has_grappling_hook(is_equipped: bool):
	has_grappling_hook = is_equipped
	grapple.enabled = is_equipped
