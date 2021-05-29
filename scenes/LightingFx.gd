extends Control

export var min_delay: int = 3
export var max_delay: int = 10
export var randomize_seed: bool = true
export var raondom_seed: int = 42
export var enabled: bool = true setget _set_enabled

onready var anim: AnimationPlayer = $AnimationPlayer
onready var timer: Timer = $LightingTimer

var _is_ready = false

func _ready():
	anim.connect("animation_finished", self, "thunder_finished")
	timer.connect("timeout", self, "lighting")
	if randomize_seed:
		randomize()
	else:
		rand_seed(randomize_seed)
	if enabled:
		thunder_finished(null)
	_is_ready = true

func _set_enabled(new_enabled):
	enabled = new_enabled
	if _is_ready:
		if enabled:
			thunder_finished(null)
		else:
			anim.stop()
			timer.stop()

func lighting():
	anim.play("Lightning")

func thunder_finished(_anim):
	timer.wait_time = randi() % (max_delay-min_delay) + min_delay
	timer.start()
