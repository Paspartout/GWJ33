extends KinematicBody2D

onready var BreakTimer = $BreakTimer
onready var RespawnTimer = $Respawn
export var respawnable = true

func _on_Area2D_body_entered(body):
	if body.get_name() == "Player":
		$BreakTimer.start()
		

func _on_BreakTimer_timeout():
	$Respawn.start()
	$Area2D/CollisionShape2D.disabled = true
	$CollisionShape2D.disabled = true
	$Sprite.visible = false

func _on_Respawn_timeout():
	if respawnable == true:
		$Area2D/CollisionShape2D.disabled = false
		$CollisionShape2D.disabled = false
		$Sprite.visible = true
	
