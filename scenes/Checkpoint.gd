class_name Checkpoint
extends Area2D

signal cleared

func _on_Checkpoint_body_entered(body):
	emit_signal("cleared")
	set_deferred("monitoring", false)
