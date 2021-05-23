class_name PatrollerGuard
extends Enemy

var velocity: Vector2 = Vector2.ZERO
var idle = false
export var speed = 50
export var gravity: float = 10

onready var move_timer = $MoveTimer
onready var idle_timer = $IdleTimer
onready var sus_timer = $SuspicionTimer
onready var tween = $Tween

onready var sprite = $Sprite
onready var detection_area = $DetectionArea
onready var light_cone: Sprite = $DetectionArea/LightCone
onready var sus_indicator: CanvasItem = $SusLabel

enum PatrollerState {Idle, Walk, Death}
var patroller_state = PatrollerState.Walk
var player

func _ready():
	sus_indicator.visible = false

func _physics_process(_delta):
	_update_animation()
	if patroller_state == PatrollerState.Death:
		return
	if idle:
		velocity.x = 0
	else:
		velocity.x = speed

	if is_on_floor():
		pass
	else:
		velocity.y += gravity
		
	if is_on_ceiling():
		velocity.y = 0
		
	if speed < 0:
		sprite.flip_h = false
	else:
		sprite.flip_h = true

	velocity = move_and_slide(velocity, Vector2.UP)

func _update_animation():
	match patroller_state:
		PatrollerState.Idle:
			sprite.animation = "Idle"
		PatrollerState.Walk:
			sprite.animation = "Walk"
		PatrollerState.Death:
			idle = true
			sprite.animation = "Death"
			move_timer.stop()
			idle_timer.stop()
			sus_timer.stop()
			yield(sprite, "animation_finished")
			sprite.hide()
			queue_free()

func _on_MoveTimer_timeout():
	idle = true
	move_timer.stop()
	idle_timer.start()
	patroller_state = PatrollerState.Idle

func _on_IdleTimer_timeout():
	idle = false
	_turn_around()
	move_timer.start()
	idle_timer.stop()
	patroller_state = PatrollerState.Walk

func kill():
	patroller_state = PatrollerState.Death

func _turn_around():
	speed *= -1
	detection_area.position.x *= -1
	light_cone.flip_h = !light_cone.flip_h

func _on_DetectionArea_body_entered(body):
	sus_indicator.visible = true
	player = body
	sus_timer.start()
	tween.interpolate_property(
		sus_indicator, "modulate", Color.white, Color.red, sus_timer.wait_time,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
	)
	tween.start()

func _on_DetectionArea_body_exited(_body):
	sus_indicator.visible = false
	sus_timer.stop()

func _on_SuspicionTimer_timeout():
	player.kill()

func _on_Sprite_animation_finished():
	if patroller_state == PatrollerState.Death:
		queue_free()
