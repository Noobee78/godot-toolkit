extends Node2D

const max_items_spawned := 3

var item_scenes := [
	preload("res://lessons/Scenes/gem.tscn"),
	preload("res://lessons/Scenes/health_pack.tscn")
]

var items_spawned := 0


func _ready() -> void:
	#var gem_scene := preload("res://lessons/Scenes/gem.tscn")
	#var gem_instance := gem_scene.instantiate()
	#add_child(gem_instance)
	get_node("Timer").timeout.connect(_on_timer_timeout)


func _on_timer_timeout() -> void:
	if items_spawned >= max_items_spawned:
		return
		
	var random_item_scene: PackedScene = item_scenes.pick_random()
	var item_instance := random_item_scene.instantiate()
	add_child(item_instance)

	items_spawned += 1
	item_instance.tree_exited.connect(_on_item_tree_exited)

	var viewport_size := get_viewport_rect().size
	var random_position := Vector2.ZERO
	random_position.x = randf_range(0.0, viewport_size.x)
	random_position.y = randf_range(0.0, viewport_size.y)
	item_instance.position = random_position
	
func _on_item_tree_exited() -> void:
	items_spawned -= 1

	if items_spawned < 0:
		items_spawned = 0
