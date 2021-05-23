extends Control

onready var game: Game = get_tree().root.get_node_or_null("Game")

export(Array, String) var dialog = [
	'You: This is a cutscene wow',
	'Villan: yeah this is a cutscene',
	'This is a long Block of text in the cutscene and after this you will go to the next scene!'
]

var dialog_index = 0
var finished = false

onready var indicator = $Indicator
onready var label = $RichTextLabel
onready var tween = $Tween
onready var sound = $Sounds/DialogSound

func _ready():
	tween.connect("tween_all_completed", self, "_on_tween_completed")
	show_next_line()

func _process(_delta):
	indicator.visible = finished
	if Input.is_action_just_pressed("ui_accept"):
		show_next_line()

func show_next_line():
	if dialog_index < dialog.size():
		# display next line
		if dialog_index != 0:
			sound.play(1.09)
		finished = false
		label.bbcode_text = dialog[dialog_index]
		label.percent_visible = 0
		tween.interpolate_property(
			label, "percent_visible", 0, 1, 1,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
		)
		tween.start()
	else:
		# finished
		if game:
			game.load_next_level()
		queue_free()

	dialog_index += 1

func _on_tween_completed():
	finished = true
