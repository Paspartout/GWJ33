extends AudioStreamPlayer

var tracks = [
	preload("res://music/Departure.ogg"),
	preload("res://music/StandWithUs.ogg"),
	preload("res://music/1-10_Rain.wav")
]

func start_playing():
	stream = tracks[0]
	$AudioStreamPlayer.play()
	play()

func play_next():
	# TODO: Fade/Proper transition using tween probably
	stream = tracks[1]
	play()
