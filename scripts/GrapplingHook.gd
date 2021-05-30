class_name GrapplingHook

extends Node2D

const CROSHAIR: Texture = preload("res://graphics/other/crosshair.png")
const HOOK_END: PackedScene = preload("res://scenes/HookEnd.tscn")
enum GrappleState {Loose, Shooting, Hooked, Pulling}

export var player_path: NodePath
export var grapple_indicator_path: NodePath
export var max_grapple_distance: float = 100
export var grapple_acceleration: float = 100
export var grapple_speed: float = 50
export var enabled: bool = false setget set_enabled

var grapple_state = GrappleState.Loose
var grapple_pos: Vector2
var grapple_velocity: Vector2 = Vector2.ZERO
var grapple_direction: Vector2 = Vector2.ZERO
var hooking_velocity: Vector2 = Vector2.ZERO

var hook_end: KinematicBody2D
var grapple_indicator: Sprite

var direction_indicator: Node2D
var grapple_valid: bool = false
var joypad_control: bool = false

onready var player = get_node(player_path)

onready var grapple_timer: Timer = $Timer
onready var grapple_cast: RayCast2D = $GrappleRayCast
onready var rope: Line2D = $Rope


func set_enabled(new_enabled):
	enabled = new_enabled
	grapple_indicator.visible = enabled
	direction_indicator.visible = enabled

func _ready():
	grapple_timer.connect("timeout", self, "stop", [], CONNECT_ONESHOT)

	hook_end = HOOK_END.instance()
	hook_end.global_position = global_position
	grapple_indicator = hook_end.get_node("Sprite")
	player.get_parent().call_deferred("add_child", hook_end)

	direction_indicator = Sprite.new()
	direction_indicator.hframes = 2
	direction_indicator.frame = 0
	direction_indicator.texture = CROSHAIR
	direction_indicator.visible = enabled
	call_deferred("add_child", direction_indicator)

func _exit_tree():
	if hook_end:
		hook_end.queue_free()

func _input(event):
	# Toggle between mouse and joypad aiming based on latest input
	# TODO: Maybe move this into a singleton so we can show differnt button prompts and reuse this code
	if event is InputEventMouse:
		joypad_control = false
	elif event is InputEventJoypadMotion:
		if event.axis_value > 0.2:
			joypad_control = true
	elif event is InputEventJoypadButton:
		joypad_control = true

func _physics_process(_delta):
	if !enabled:
		return

	if joypad_control and Input.is_joy_known(0):
		var joy_direction := Vector2(
			Input.get_joy_axis(0, 2),
			Input.get_joy_axis(0, 3)
		)
		if joy_direction.length() > 0.5:
			grapple_direction = joy_direction.normalized()
	else:
		grapple_direction = get_local_mouse_position().normalized()

	grapple_cast.cast_to = grapple_direction * max_grapple_distance
	direction_indicator.position = grapple_direction.normalized() * 20

	if grapple_cast.is_colliding():
		var collider: TileMap = grapple_cast.get_collider()
		# check if we hit something that is grappable, layber 4 is ungrappable
		if !collider.get_collision_layer_bit(4):
			direction_indicator.frame = 1
			grapple_indicator.frame = 1
			if !grapple_valid and joypad_control:
				Input.start_joy_vibration(0, 0.05, 0, 0.1)
			grapple_valid = true
		else:
			grapple_valid = false
	else:
		direction_indicator.frame = 0
		grapple_indicator.frame = 0
		grapple_valid = false

func pull() -> Vector2:
	match grapple_state:
		GrappleState.Loose:
			pass # Do nothing
		GrappleState.Shooting:
			# TODO: Play/lerp shooting animation
			var grapple_direction = (grapple_pos - player.position).normalized()
			var grapple_velocity = grapple_direction * 70
			var collision = hook_end.move_and_collide(grapple_velocity)
			if collision:
				hooking_velocity = grapple_velocity
				grapple_state = GrappleState.Pulling
			rope.points[1] = to_local(hook_end.position)
		GrappleState.Pulling:
			var grapple_direction = (hook_end.position - player.position).normalized()
			var grapple_velocity = grapple_direction * grapple_speed
			rope.points[1] = to_local(hook_end.position)
		
			# TODO: Finetune for side hooking?
			if hooking_velocity.y < 0:
				print("Shooting up")
				hook_end.move_and_slide_with_snap(Vector2.UP, Vector2.UP, Vector2.DOWN)
			else:
				print("Shooting down")
				hook_end.move_and_slide_with_snap(Vector2.DOWN, Vector2.DOWN, Vector2.UP)

			return grapple_velocity
	return Vector2.ZERO

func stop():
	grapple_state = GrappleState.Loose
	grapple_indicator.hide()
	rope.hide()
	hook_end.global_position = global_position

func shoot():
	if grapple_state != GrappleState.Loose:
		stop()
		return

	if grapple_valid:
		hook_end.global_position = global_position
		if joypad_control:
			Input.start_joy_vibration(0, 0, 0.3, 0.05)
		grapple_pos = grapple_cast.get_collision_point()
		$Sounds/GrappleShoot.play()
		#grapple_indicator.global_position = grapple_pos
		grapple_indicator.show()
		rope.show()
		grapple_state = GrappleState.Shooting
		grapple_timer.start()

func is_in_use():
	return grapple_state != GrappleState.Loose 
