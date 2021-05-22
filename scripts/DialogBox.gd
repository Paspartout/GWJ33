extends Control

var dialog = [
	'You: This is a cutscene wow',
	'Villan: yeah this is a cutscene',
	'This is a long Block of text in the cutscene and after this you will go to the next scene!'
]

var dialog_index = 0
var finished = false

func _ready():
	load_dialog()

func _process(delta):
	$"Indicator".visible = finished
	if Input.is_action_just_pressed("ui_accept"):
		load_dialog()

func load_dialog():
	if dialog_index < dialog.size():
		finished = false
		$TextureRect/RichTextLabel.bbcode_text = dialog[dialog_index]
		$TextureRect/RichTextLabel.percent_visible = 0
		$Tween.interpolate_property(
			$TextureRect/RichTextLabel, "percent_visible", 0, 1, 1,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
		)
		$Tween.start()
	else:
		queue_free()
		get_tree().change_scene("res://scenes/Level2.tscn")
	dialog_index += 1


func _on_Tween_tween_completed(object, key):
	finished = true
