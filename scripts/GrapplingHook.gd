class_name GrapplingHook

extends Node2D

export var player_path: NodePath
export var grapple_indicator_path: NodePath
export var max_grapple_distance: float = 1000
export var grapple_acceleration: float = 100
export var grapple_speed: float = 50

enum GrappleState {Loose, Shooting, Hooked, Pulling}
var grapple_state = GrappleState.Loose
var grapple_pos: Vector2
var grapple_velocity: Vector2 = Vector2.ZERO

onready var player = get_node(player_path)

onready var grapple_timer: Timer = $Timer
onready var grapple_cast: RayCast2D = $GrappleRayCast
onready var rope: Line2D = $Rope

var grapple_indicator: Node2D

func _ready():
	grapple_timer.connect("timeout", self, "stop", [], CONNECT_ONESHOT)

	# Setup temporary grapple indicator
	grapple_indicator = Sprite.new()
	grapple_indicator.scale = Vector2(0.2, 0.2)
	grapple_indicator.texture = preload("res://icon.png")
	player.get_parent().call_deferred("add_child", grapple_indicator)

func _input(event):
	# TODO: Maybe move somewhere different
	if event.is_action_pressed("graple"):
		shoot()

func pull() -> Vector2:
	match grapple_state:
		GrappleState.Loose:
			pass # Do nothing
		GrappleState.Shooting:
			# TODO: Play/lerp shooting animation
			pass
		GrappleState.Pulling:
			var grapple_direction = (grapple_pos - player.position).normalized()
			var grapple_velocity = grapple_direction * grapple_speed
			rope.points[1] = to_local(grapple_pos)
			return grapple_velocity
	return Vector2.ZERO

func stop():
	grapple_state = GrappleState.Loose
	grapple_indicator.hide()
	rope.hide()

func shoot():
	if grapple_state == GrappleState.Pulling:
		stop()
		return
	var mouse_pos = get_global_mouse_position()
	#var direction = (mouse_pos - player.position).normalized() * max_grapple_distance
	var direction = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	).normalized() * max_grapple_distance
	
	#print("Mouse pos", mouse_pos)
	#print("Grapple at", direction)
	grapple_cast.cast_to = direction
	grapple_cast.force_raycast_update()

	if grapple_cast.is_colliding():
		grapple_pos = grapple_cast.get_collision_point()
		print("Grapple pos", grapple_pos)
		

		#print("Hit", grapple_pos)
		grapple_indicator.global_position = grapple_pos
		grapple_indicator.show()
		rope.show()
		grapple_state = GrappleState.Pulling
		grapple_timer.start()

func is_in_use():
	return grapple_state != GrappleState.Loose 
