extends Control

onready var options := $Options

func _ready():
	hide()

func _input(event):
	if event.is_action_pressed("pause"):
		get_tree().paused = !get_tree().paused
		visible = !visible
		if visible:
			$CenterContainer/Panel/VBoxContainer/Continue.grab_focus()

func _on_Continue_pressed():
	get_tree().paused = false
	hide()

func _on_Menu_pressed():
	get_tree().change_scene("res://scenes/MainMenu.tscn")
	get_tree().paused = false
	hide()

func _on_Fullscreen_pressed() -> void:
	OS.window_fullscreen = !OS.window_fullscreen
	get_tree().paused = false
	hide()

func _on_Options_pressed():
	options.show()
