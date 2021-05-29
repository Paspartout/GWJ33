extends Control

signal quit

onready var back = $Options/VBoxContainer/Back

func _ready():
	visible = false
	back.connect("pressed", self, "_on_Back_pressed")

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		_on_Back_pressed()

func show():
	visible = true
	

func _on_Back_pressed():
	if visible: 
		$Options/Sounds/OptionSelect.play(1.11)
	visible = false
	emit_signal("quit")
