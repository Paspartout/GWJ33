extends Control

onready var master_slider: HSlider = $MasterSlider
onready var music_slider: HSlider = $MusicSlider
onready var sound_slider: HSlider = $SoundSlider

const MASTER_BUS = 0
const MUSIC_BUS = 1
const SOUND_BUS = 2

var master_volume: float
var music_volume: float
var sound_volume: float

func _ready():
	master_slider.connect("value_changed", self, "_on_MasterSlider_value_changed")
	music_slider.connect("value_changed", self, "_on_MusicSlider_value_changed")
	sound_slider.connect("value_changed", self, "_on_SoundSlider_value_changed")
	_update_slider()
	connect("visibility_changed", self, "_on_visibility_changed")

func _on_visibility_changed():
	if visible:
		master_slider.grab_focus()
	
func _update_slider():
	master_volume = db2linear(AudioServer.get_bus_volume_db(MASTER_BUS))
	music_volume = db2linear(AudioServer.get_bus_volume_db(MUSIC_BUS))
	sound_volume = db2linear(AudioServer.get_bus_volume_db(SOUND_BUS))
	
	master_slider.value = master_volume * 100.0
	music_slider.value = music_volume * 100.0
	sound_slider.value = sound_volume * 100.0
	
	$MasterValue.text = "%.0d %%" % (master_volume * 100.0)
	$MusicValue.text = "%.0d %%" % (music_volume * 100.0)
	$SoundValue.text = "%.0d %%" % (sound_volume * 100.0)

func _on_MasterSlider_value_changed(value):
	AudioServer.set_bus_volume_db(MASTER_BUS, linear2db(value/100.0))
	_update_slider()

func _on_MusicSlider_value_changed(value):
	AudioServer.set_bus_volume_db(MUSIC_BUS, linear2db(value/100.0))
	_update_slider()

func _on_SoundSlider_value_changed(value):
	AudioServer.set_bus_volume_db(SOUND_BUS, linear2db(value/100.0))
	_update_slider()
