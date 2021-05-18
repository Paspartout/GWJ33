extends Node

func _ready():
	var Player: Node2D = get_tree().get_nodes_in_group("Players")[0]
	Player.connect("death", self , "game_over")
	
	
func game_over():
	print("game over")
