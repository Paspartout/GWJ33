class_name GrapplingHook

extends Node2D

export var player_path: NodePath
export var grapple_indicator_path: NodePath

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
			var grapple_velocity = grapple_direction * 100
			# TODO: Different way to apply velocity?
			# player.velocity += grapple_velocity
			return grapple_velocity
	return Vector2.ZERO

func stop():
	grapple_state = GrappleState.Loose
	grapple_indicator.hide()

func shoot():
	if grapple_state == GrappleState.Pulling:
		stop()
		return
	var mouse_pos =  get_viewport().get_mouse_position()
	var direction = (mouse_pos - player.position).normalized() * 1000
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

