tool
class_name Level
extends Node2D

var game: Game
var player

export var player_scene: PackedScene = preload("res://scenes/Player.tscn")
export var level_bounds: Rect2 = Rect2() setget set_level_bounds
export var level_bounds_offset: Rect2 = Rect2(0, 0, 0, 0)
export var make_bounds_from_tilemap = false setget set_bounds_from_tilemap
export var draw_level_bounds = false setget set_draw_level_bounds

onready var dialog = $UI/DialogBackground
onready var dialog_box = $UI/DialogBackground/DialogBox
onready var checkpoints = $Checkpoints
onready var tiles = $Tiles
onready var test_cam := $TestCamera

var checkpoint_index = 0
var current_checkpoint: Node2D

func _draw():
	if Engine.editor_hint and draw_level_bounds:
		if level_bounds != null:
			draw_rect(level_bounds, Color.chocolate, false, 3)

func set_bounds_from_tilemap(enabled: bool):
	if enabled and Engine.editor_hint:
		self.level_bounds = get_map_bounds()

		test_cam.limit_bottom = level_bounds.position.y + level_bounds.size.y
		test_cam.limit_top = level_bounds.position.y
		test_cam.limit_left = level_bounds.position.x
		test_cam.limit_right = level_bounds.position.x + level_bounds.size.x

func set_draw_level_bounds(value: bool):
	draw_level_bounds = value
	update()

func set_level_bounds(value: Rect2):
	level_bounds = value
	if Engine.editor_hint:
		print("setting_level_bounds")
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
	rect.position += level_bounds_offset.position
	rect.size += level_bounds_offset.size

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
	_reset_items()
	var camera := Camera2D.new()
	camera.current = true
	camera.drag_margin_h_enabled = true
	camera.drag_margin_v_enabled = true
	
	camera.limit_bottom = level_bounds.position.y + level_bounds.size.y
	camera.limit_top = level_bounds.position.y
	camera.limit_left = level_bounds.position.x
	camera.limit_right = level_bounds.position.x + level_bounds.size.x

	camera.drag_margin_bottom = 0.2
	camera.drag_margin_top = 0.07
	camera.drag_margin_left = 0.2
	camera.drag_margin_right= 0.2
	camera.smoothing_enabled = true
	camera.smoothing_speed = 6

	player.add_child(camera)
	player.position = current_checkpoint.position
	player.connect("death", self, "_on_player_died")

func _on_player_died():
	yield(get_tree().create_timer(2.0), "timeout")
	player.queue_free()
	respawn()

func _reset_items():
	for item in $Items.get_children():
		if item is Area2D:
			item.visible = true
			item.set_deferred("monitorable", true)

func _on_LightingTimer_timeout():
	$Effects/ColorRect/AnimationPlayer.play("Lightning")
