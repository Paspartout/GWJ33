class_name Game
extends Node

export(Array, PackedScene) var levels: Array
export var current_level: int = 0

onready var current_level_node = $Level

func _ready():
	load_next_level()

func load_next_level():
	# TODO: Add transition here?
	assert(levels.size() > 0)
	for c in current_level_node.get_children():
		c.queue_free()
	var next_level = levels[current_level].instance()
	current_level_node.call_deferred("add_child", next_level)
	current_level += 1

func respawn():
	# TODO
	pass
