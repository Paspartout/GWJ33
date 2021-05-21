extends Control

var dialog = [
	'Text line numeber 1',
	'Text line number 2 ',
	'This is longer text and it is very long remember that this text is very long btw'
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
	dialog_index += 1


func _on_Tween_tween_completed(object, key):
	finished = true
