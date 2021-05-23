extends Control

onready var main_menu = get_parent().get_node("CenterContainer/MenuPanel")

const MASTER = 0
const MUSIC = 1
const SFX = 2

func db_to_percent(db: float) -> float:
	var val = db * 1.25 + 100
	return val

func percent_to_db(percent: float) -> float:
	var val = (100.0-percent)/100.0 * -80.0
	return val

onready var master_slider = $SoundSettings/MasterSlider
onready var music_slider = $SoundSettings/MusicSlider
onready var sound_slider = $SoundSettings/SoundSlider

var master_volume: float
var music_volume: float
var sound_volume: float

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		_on_Back_pressed()

func _ready():
	visible = false
	update_slider()

func update_slider():
	master_volume = db_to_percent(AudioServer.get_bus_volume_db(MASTER))
	music_volume = db_to_percent(AudioServer.get_bus_volume_db(MUSIC))
	sound_volume = db_to_percent(AudioServer.get_bus_volume_db(SFX))
	
	master_slider.value = master_volume
	music_slider.value = music_volume
	sound_slider.value = sound_volume
	
	$SoundSettings/MasterValue.text = "%.0d %%" % master_volume
	$SoundSettings/MusicValue.text = "%.0d %%" % music_volume
	$SoundSettings/SoundValue.text = "%.0d %%" % sound_volume

func show():
	visible = true

func _on_Back_pressed():
	$Sounds/OptionSelect.play(1.11)
	visible = false
	main_menu.visible = true

func _on_MasterSlider_value_changed(value):
	AudioServer.set_bus_volume_db(MASTER, percent_to_db(value))
	update_slider()

func _on_MusicSlider_value_changed(value):
	AudioServer.set_bus_volume_db(MUSIC, percent_to_db(value))
	update_slider()

func _on_SoundSlider_value_changed(value):
	AudioServer.set_bus_volume_db(SFX, percent_to_db(value))
	update_slider()


