extends Control

onready var game: Game = get_tree().root.get_node_or_null("Game")

func _ready():
	set_visible(false)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		set_visible(!get_tree().paused) 
		get_tree().paused = !get_tree().paused 

func set_visible(is_visible):
	for node in get_children():
		node.visible = is_visible

func _on_Continue_pressed():
	get_tree().paused = false
	set_visible(false)

func _on_Menu_pressed():
	get_tree().change_scene("res://Scenes/MainMenu.tscn")
	get_tree().paused = false
	set_visible(false)

func _on_Fullscreen_pressed() -> void:
	get_tree().paused = false
	set_visible(false)
	OS.window_fullscreen = !OS.window_fullscreen

