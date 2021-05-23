extends Control

onready var options = $Options
onready var main_menu = $CenterContainer/MenuPanel

func _ready():
	$CPUParticles2D.emitting = true
func _on_Play_pressed() -> void:
	$Sounds/OptionSelect.play(1.11)
	get_tree().change_scene("res://scenes/game.tscn")

func _on_Exit_pressed() -> void:
	$Sounds/OptionSelect.play(1.11)
	yield($Sounds/OptionSelect, "finished")
	get_tree().quit()

func _on_Options_pressed():
	options.show()
	main_menu.hide()
	$Sounds/OptionSelect.play(1.11)
