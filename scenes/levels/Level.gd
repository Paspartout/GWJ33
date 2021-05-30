tool
class_name Level
extends Node2D

const PLAYER_SCENE: PackedScene = preload("res://scenes/Player.tscn")
const BOUNDARY_COLORS: Array = [Color.coral, Color.greenyellow, Color.aqua]

export(Rect2) var level_bounds_tile_offset: Rect2 = Rect2(0, 0, 0, 0)
export(Array, Rect2) var camera_boundaries = [] setget _set_camera_boundaries
export var make_bounds_from_tilemap = false setget _set_bounds_from_tilemap
export var draw_level_bounds = false setget _set_draw_level_bounds

export var current_checkpoint_index = 0
export var current_camera_bounds_index = 0 setget _set_current_camera_bounds_index

var game: Game
var player
var camera_player_attachement: RemoteTransform2D

onready var camera: Camera2D = $Camera
onready var dialog := $UI/DialogBackground
onready var dialog_box := $UI/DialogBackground/DialogBox
onready var checkpoints := $Checkpoints
onready var tiles := $Tiles

func _ready():
	if Engine.editor_hint:
		return
	dialog.visible = false
	game = get_tree().root.get_node_or_null("Game")
	dialog_box.connect("finished", self, "_on_dialog_finished")
	if not game:
		push_warning("Level run independently, no scene switching will work")
	_respawn()

	for checkpoint in checkpoints.get_children():
		if checkpoint is Checkpoint:
			checkpoint.connect("cleared", self, "_checkpoint_cleared", [checkpoint.get_index()], CONNECT_ONESHOT)

func _draw():
	# Draw the camera bounds if enabled
	if Engine.editor_hint and draw_level_bounds:
		var i := 0
		for bounds in camera_boundaries:
			draw_rect(bounds, BOUNDARY_COLORS[i % 3], false, 3)
			i += 1

func _get_configuration_warning():
	# This functions checks the level setup and warns the user about misconfiguration
	if checkpoints and checkpoints.get_child_count() < 1:
		return "No checkpoints setup yet!"
	return ""

func _set_bounds_from_tilemap(enabled: bool):
	if enabled and Engine.editor_hint:
		if camera_boundaries.size() < 1:
			camera_boundaries.append(Rect2())
		self.camera_boundaries[0] = _calculate_map_bounds()

func _set_draw_level_bounds(value: bool):
	draw_level_bounds = value
	update()

func _set_level_bounds(value: Rect2):
	camera_boundaries = value
	update()

func _set_camera_boundaries(value: Array):
	camera_boundaries = value
	update()

func _checkpoint_cleared(index: int):
	current_checkpoint_index = index

func _set_current_camera_bounds_index(index: int):
	current_camera_bounds_index = index
	if !Engine.editor_hint and is_inside_tree():
		_update_camera_bounds(camera_boundaries[current_camera_bounds_index])

func _calculate_map_bounds() -> Rect2:
	var rect := Rect2()
	for tilemap in tiles.get_children():
		rect = rect.merge(tilemap.get_used_rect())
	rect.position += level_bounds_tile_offset.position
	rect.size += level_bounds_tile_offset.size

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

func _update_camera_bounds(bounds: Rect2):
	camera.limit_bottom = bounds.position.y + bounds.size.y
	camera.limit_top = bounds.position.y
	camera.limit_left = bounds.position.x
	camera.limit_right = bounds.position.x + bounds.size.x

func _on_player_died():
	yield(get_tree().create_timer(0.5), "timeout")
	player.queue_free()
	_respawn()

func _respawn():
	# Create the player scene and the corresponding camera at the current checkpoint
	var current_checkpoint = checkpoints.get_child(current_checkpoint_index)
	player = PLAYER_SCENE.instance()
	add_child(player)
	player.position = current_checkpoint.position
	
	# Attach the camera to the player by using RemoteTransform2D
	# This can be disabled for e.g. cutscenes by setting update_position=false
	camera_player_attachement = RemoteTransform2D.new()
	player.add_child(camera_player_attachement)
	camera_player_attachement.remote_path = camera.get_path()
	camera_player_attachement.update_rotation = false
	camera_player_attachement.update_scale = false
	
	_update_camera_bounds(camera_boundaries[current_camera_bounds_index])
	player.connect("death", self, "_on_player_died")

	_reset_items()

func _reset_items():
	for item in $Items.get_children():
		if item is Area2D:
			item.visible = true
			item.set_deferred("monitorable", true)
