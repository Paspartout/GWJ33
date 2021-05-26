extends Control

onready var options := $Options
onready var main_menu := $MainMenu
onready var rain_particles := $Background/CPUParticles2D

func _ready():
	rain_particles.emitting = false
	options.connect("quit", self, "_on_options_quit")
	MusicPlayer.play()

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

func _on_options_quit():
	options.hide()
	main_menu.show()

func _on_Timer_timeout():
	rain_particles.emitting = true
