class_name Level
extends Node

var game: Game

onready var dialog = $UI/DialogBackground
onready var dialog_box = $UI/DialogBackground/DialogBox

func _ready():
	dialog.visible = false
	game = get_tree().root.get_node_or_null("Game")
	dialog_box.connect("finished", self, "_on_dialog_finished")
	if not game:
		push_warning("Level run independently, no scene switching will work")

func show_dialog(dialog_text: Array):
	# TODO: Could use animation player for fancy transitions
	get_tree().paused = true
	dialog.visible = true
	dialog_box.dialog = dialog_text
	dialog_box.start()
	
func _on_dialog_finished():
	get_tree().paused = false
	dialog.visible = false

func respawn():
	push_warning("Not overriden!")


func _on_Timer_timeout():
	$Effects/ColorRect.visible = true
	$Effects/ColorRect/AnimationPlayer.play("Lightning")
	$Effects/ColorRect/AudioStreamPlayer.play()

