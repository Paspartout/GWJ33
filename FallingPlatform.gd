extends KinematicBody2D



func _on_Area2D_body_entered(body):
	if body.get_name() == "Player":
		$Timer.start()
		


func _on_Timer_timeout():
	queue_free()
