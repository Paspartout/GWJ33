extends KinematicBody2D

var velocity: Vector2 = Vector2.ZERO
var idle = false
export var speed = 50
export var gravity: float = 10
onready var moveTimer = $MoveTimer
onready var idleTimer = $IdleTimer
onready var sprite = $Sprite
onready var detectionArea = $DetectionArea

func _ready():
	# TODO: maybe connect a signal to manage death?
	pass
	
func _physics_process(delta):
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
		sprite.flip_h = true
	else:
		sprite.flip_h = false
	
	move_and_slide(velocity, Vector2.UP)


func _on_MoveTimer_timeout():
	idle = true
	moveTimer.stop()
	idleTimer.start()

func _on_IdleTimer_timeout():
	idle = false
	speed *= -1
	$CollisionShape2D.position.x *= -1
	detectionArea.get_node("CollisionShape2D").position.x *= -1
	moveTimer.start()
	idleTimer.stop()



func _on_DetectionArea_body_entered(body):
	if body.get_name() == "Player":
		$SuspicionTimer.start()
		

func _on_SuspicionTimer_timeout():
	var Players = get_tree().get_nodes_in_group("Players")
	if !Players.empty():
		Players[0].kill()
	




func _on_DetectionArea_body_exited(body):
	$SuspicionTimer.stop()
