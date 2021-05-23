extends Control

onready var game: Game = get_tree().root.get_node_or_null("Game")

export(Array, String) var dialog = [
	'You: This is a cutscene wow',
	'Villan: yeah this is a cutscene',
	'This is a long Block of text in the cutscene and after this you will go to the next scene!'
]
export var autostart: bool = false

signal finished

var dialog_index = 0
var finished = false
var active = false

onready var indicator = $Indicator
onready var label = $RichTextLabel
onready var tween = $Tween
onready var sound = $Sounds/DialogSound

func _ready():
	tween.connect("tween_all_completed", self, "_on_tween_completed")
	if autostart:
		start()

func _input(event):
	if active and event.is_action_pressed("ui_accept"):
		advance_line()

func start():
	active = true
	advance_line()

func advance_line():
	if dialog_index < dialog.size():
		# display next line
		if dialog_index != 0:
			sound.play(1.09)
		indicator.visible = false
		label.bbcode_text = dialog[dialog_index]
		label.percent_visible = 0
		tween.interpolate_property(
			label, "percent_visible", 0, 1, 1,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
		)
		tween.start()
	else:
		emit_signal("finished")

	dialog_index += 1

func _on_tween_completed():
	indicator.visible = true
