class_name GrapplingHook

extends Node2D

export var player_path: NodePath
export var grapple_indicator_path: NodePath
export var max_grapple_distance: float = 1000
export var grapple_speed: float = 100

enum GrappleState {Loose, Shooting, Hooked, Pulling}
var grapple_state = GrappleState.Loose
var grapple_pos: Vector2

onready var player = get_node(player_path)
onready var grapple_indicator: Node2D
onready var grapple_timer: Timer = $Timer
onready var grapple_cast: RayCast2D = $GrappleRayCast

func _ready():
	grapple_timer.connect("timeout", self, "stop", [], CONNECT_ONESHOT)

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
			return grapple_velocity
	return Vector2.ZERO

func stop():
	grapple_state = GrappleState.Loose
	grapple_indicator.hide()

func shoot():
	if grapple_state == GrappleState.Pulling:
		stop()
		return
	var mouse_pos = get_global_mouse_position()
	var direction = (mouse_pos - player.position).normalized() * max_grapple_distance
	#print("Mouse pos", mouse_pos)
	#print("Grapple at", direction)
	grapple_cast.cast_to = direction
	grapple_cast.force_raycast_update()
	if grapple_cast.is_colliding():
		grapple_pos = grapple_cast.get_collision_point()
		#print("Hit", grapple_pos)
		grapple_indicator.global_position = grapple_pos
		grapple_indicator.show()
		grapple_state = GrappleState.Pulling
		grapple_timer.start()

