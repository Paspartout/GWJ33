tool
class_name Level
extends Node2D

var game: Game
var player

export var player_scene: PackedScene = preload("res://scenes/Player.tscn")
export var level_bounds: Rect2 = Rect2()
export var bounds_from_tilemap: bool setget set_bounds_from_tilemap

onready var dialog = $UI/DialogBackground
onready var dialog_box = $UI/DialogBackground/DialogBox
onready var checkpoints = $Checkpoints
onready var tiles = $Tiles

var checkpoint_index = 0
var current_checkpoint: Node2D

func _draw():
	if Engine.editor_hint:
		if level_bounds != null:
			draw_rect(level_bounds, Color.chocolate, false, 3)

func set_bounds_from_tilemap(enabled: bool):
	bounds_from_tilemap = enabled
	if enabled and Engine.editor_hint:
		level_bounds = get_map_bounds()
		update()

func _ready():
	if Engine.editor_hint:
		return
	dialog.visible = false
	game = get_tree().root.get_node_or_null("Game")
	dialog_box.connect("finished", self, "_on_dialog_finished")
	if not game:
		push_warning("Level run independently, no scene switching will work")
	respawn()

func get_map_bounds() -> Rect2:
	var rect := Rect2()
	for tilemap in tiles.get_children():
		rect = rect.merge(tilemap.get_used_rect())
	rect.position += Vector2(1, 1)
	rect.size -= Vector2(2, 1)
	rect.position *= 16
	rect.size *= 16
	return rect

func show_dialog(dialog_text: Array):
	# TODO: Could use animation player for fancy transitions
	get_tree().paused = true
	dialog.visible = true
	dialog_box.dialog = dialog_text
	dialog_box.start()

func _on_dialog_finished():
	get_tree().paused = false
	dialog.visible = false

func respawn():
	current_checkpoint = checkpoints.get_child(checkpoint_index)
	player = player_scene.instance()
	add_child(player)
	var camera := Camera2D.new()
	camera.current = true
	camera.drag_margin_h_enabled = true
	camera.drag_margin_v_enabled = true
	
	camera.limit_bottom = level_bounds.size.y - 16
	camera.limit_top = level_bounds.position.y
	camera.limit_left = level_bounds.position.x
	camera.limit_right = level_bounds.size.x - 64

	player.add_child(camera)
	player.position = current_checkpoint.position
	player.connect("death", self, "_on_player_died")

func _on_player_died():
	yield(get_tree().create_timer(2.0), "timeout")
	player.queue_free()
	respawn()

func _on_Timer_timeout():
	$Effects/ColorRect.visible = true
	$Effects/ColorRect/AnimationPlayer.play("Lightning")
	$Effects/ColorRect/AudioStreamPlayer.play()
