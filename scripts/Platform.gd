extends Node2D

export (String, "Vertical", "Horizontal") var animation


# Called when the node enters the scene tree for the first time.
func _ready():
	$Platform/AnimationPlayer.play(animation)
