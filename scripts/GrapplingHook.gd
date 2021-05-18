class_name GrapplingHook

extends Node2D

const CROSHAIR: Texture = preload("res://graphics/crosshair.png")

export var player_path: NodePath
export var grapple_indicator_path: NodePath
export var max_grapple_distance: float = 350
export var grapple_acceleration: float = 100
export var grapple_speed: float = 50

enum GrappleState {Loose, Shooting, Hooked, Pulling}
var grapple_state = GrappleState.Loose
var grapple_pos: Vector2
var grapple_velocity: Vector2 = Vector2.ZERO
var grapple_direction: Vector2 = Vector2.ZERO

var grapple_indicator: Node2D
var direction_indicator: Node2D

onready var player = get_node(player_path)

onready var grapple_timer: Timer = $Timer
onready var grapple_cast: RayCast2D = $GrappleRayCast
onready var rope: Line2D = $Rope


func _ready():
	grapple_timer.connect("timeout", self, "stop", [], CONNECT_ONESHOT)

	grapple_indicator = Sprite.new()
	grapple_indicator.hframes = 2
	grapple_indicator.frame = 0
	grapple_indicator.texture = CROSHAIR
	player.get_parent().call_deferred("add_child", grapple_indicator)
	
	direction_indicator = Sprite.new()
	direction_indicator.hframes = 2
	direction_indicator.frame = 0
	direction_indicator.texture = CROSHAIR
	call_deferred("add_child", direction_indicator)

func _input(event):
	# TODO: Maybe move somewhere different
	if event.is_action_pressed("graple"):
		shoot()


func _physics_process(_delta):
	
	var input_vec = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	)
	
	if input_vec != Vector2.ZERO:
		grapple_direction = input_vec.normalized()

	grapple_cast.cast_to = grapple_direction * max_grapple_distance
	direction_indicator.position = grapple_direction.normalized() * 20
	
	if grapple_cast.is_colliding():
		direction_indicator.frame = 1
		grapple_indicator.frame = 1
	else:
		direction_indicator.frame = 0
		grapple_indicator.frame = 0

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

	if grapple_cast.is_colliding():
		grapple_pos = grapple_cast.get_collision_point()
		
		#print("Hit", grapple_pos)
		grapple_indicator.global_position = grapple_pos
		grapple_indicator.show()
		rope.show()
		grapple_state = GrappleState.Pulling
		grapple_timer.start()

func is_in_use():
	return grapple_state != GrappleState.Loose 
