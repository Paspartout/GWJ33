extends Control

func _on_Play_pressed():
	get_tree().change_scene("res://scenes/game.tscn")
	



func _on_Exit_pressed():
	get_tree().quit()


func _on_Options_pressed():
	get_tree().change_scene("res://Options.tscn")

