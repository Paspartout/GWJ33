class_name Checkpoint
extends Area2D

signal cleared

export var has_camera_bounds: bool = false
export var camera_bounds: int = 0

func _on_Checkpoint_body_entered(body):
	emit_signal("cleared")
	set_deferred("monitoring", false)
