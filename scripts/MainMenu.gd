extends Control

func _on_Play_pressed():
	$Sounds/OptionSelect.play(1.11)
	get_tree().change_scene("res://scenes/game.tscn")
	



func _on_Exit_pressed():
	$Sounds/OptionSelect.play(1.11)
	yield($Sounds/OptionSelect, "finished")
	get_tree().quit()


func _on_Options_pressed():
	$Sounds/OptionSelect.play(1.11)
	yield($Sounds/OptionSelect, "finished")
	get_tree().change_scene("res://Options.tscn")

