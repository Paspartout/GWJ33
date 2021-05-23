class_name ChaserGuard
extends KinematicBody2D

export var gravity: float = 10
export var speed: float = 50

var velocity = Vector2.ZERO
var player = null

onready var sus_timer = $SuspicionTimer

enum ChaserState {Idle, Chasing, Returning}
var state = ChaserState.Idle

onready var sprite = $Sprite
onready var detection_area = $DetectionArea

signal death

func _ready():
	sprite.playing = true

func _physics_process(_delta):
	if player:
		var player_direction = global_position.direction_to(player.global_position) * speed
		sprite.flip_h = player_direction.x > 0
		velocity.x = player_direction.x

	velocity.y += gravity
	velocity = move_and_slide(velocity)
	_update_animation()

func _on_Detection_body_entered(body):
	state = ChaserState.Chasing
	player = body
	sus_timer.start()

func _on_Detection_body_exited(_body):
	state = ChaserState.Idle
	player = null
	velocity = Vector2.ZERO
	sus_timer.stop()

func _update_animation():
	match state:
		ChaserState.Idle:
			sprite.animation = "Idle"
		ChaserState.Chasing:
			sprite.animation = "Walk"
		ChaserState.Returning:
			sprite.animation = "Walk"
		ChaserState.Death:
			sprite.animation = "Death"
			yield(sprite, "animation_finished")
			sprite.hide()
			queue_free()

func _turn_around():
	speed *= -1
	detection_area.position.x *= -1
	# light_cone.flip_h = !light_cone.flip_h

func kill():
	emit_signal("death")
	queue_free()

func _on_SuspicionTimer_timeout():
	var Players = get_tree().get_nodes_in_group("Players")
	if !Players.empty():
		Players[0].kill()
