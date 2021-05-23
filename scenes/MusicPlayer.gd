extends AudioStreamPlayer

var tracks = [
	preload("res://music/Departure.ogg"),
	preload("res://music/StandWithUs.ogg")
]

func start_playing():
	stream = tracks[0]
	play()

func play_next():
	# TODO: Fade/Proper transition using tween probably
	stream = tracks[1]
	play()
