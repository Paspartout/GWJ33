class_name PatrollerGuard
extends KinematicBody2D

var velocity: Vector2 = Vector2.ZERO
var idle = false
export var speed = 50
export var gravity: float = 10
onready var moveTimer = $MoveTimer
onready var idleTimer = $IdleTimer
onready var sprite = $Sprite
onready var detection_area = $DetectionArea
onready var light_cone: Sprite = $DetectionArea/LightCone

enum PatrollerState {Idle, Walk, Death}
var patroller_state = PatrollerState.Walk

func _ready():
	pass

func _physics_process(delta):
	if not patroller_state == PatrollerState.Death:
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

		move_and_slide(velocity, Vector2.UP)
	_upload_animation()

func _upload_animation():
	match patroller_state:
		PatrollerState.Idle:
			sprite.animation = "Idle"
		PatrollerState.Walk:
			sprite.animation = "Walk"
		PatrollerState.Death:
			idle = true
			sprite.animation = "Death"
			moveTimer.stop()
			idleTimer.stop()
			$SuspicionTimer.stop()
			yield(sprite,"animation_finished")
			sprite.hide()
			$CollisionShape2D.hide()
			$DetectionArea/CollisionShape2D.hide()
			queue_free()

func _on_MoveTimer_timeout():
	idle = true
	moveTimer.stop()
	idleTimer.start()
	patroller_state = PatrollerState.Idle

func _on_IdleTimer_timeout():
	idle = false
	speed *= -1
	detection_area.position.x *= -1
	light_cone.flip_h = !light_cone.flip_h
	moveTimer.start()
	idleTimer.stop()
	patroller_state = PatrollerState.Walk

func kill():
	patroller_state = PatrollerState.Death

func _on_DetectionArea_body_entered(body):
	if body.get_name() == "Player":
		$SuspicionTimer.start()

func _on_SuspicionTimer_timeout():
	var Players = get_tree().get_nodes_in_group("Players")
	if !Players.empty():
		Players[0].kill()

func _on_DetectionArea_body_exited(body):
	$SuspicionTimer.stop()

func _on_Sprite_animation_finished():
	if patroller_state == PatrollerState.Death:
		queue_free()
