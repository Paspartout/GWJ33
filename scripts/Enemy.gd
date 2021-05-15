extends KinematicBody2D

var velocity: Vector2 = Vector2.ZERO
var follow = Vector2.ZERO
var moveLeft = false
export var speed = 50
export var gravity: float = 10
onready var timer = $MoveTimer
onready var sprite = $Sprite
onready var detectionArea = $DetectionArea

func _ready():
	pass
	
func _physics_process(delta):
	var input_x = Input.get_action_strength("right") - Input.get_action_strength("left")
	
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
	speed *= -1
	print(detectionArea.position)
	$CollisionShape2D.position.x *= -1
	detectionArea.get_node("CollisionShape2D").position.x *= -1
