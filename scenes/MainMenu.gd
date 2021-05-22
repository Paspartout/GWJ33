extends Control

onready var options = $Options
onready var main_menu = $CenterContainer/MenuPanel

func _on_Play_pressed() -> void:
	get_tree().change_scene("res://scenes/game.tscn")

func _on_Exit_pressed() -> void:
	get_tree().quit()

func _on_Options_pressed():
	options.show()
	main_menu.hide()
