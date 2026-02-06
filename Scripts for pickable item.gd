# Script for pickable items. We don't use inheritance here, just composition: an item is any Area2D scene with a child sprite and this script attached. See gem.tscn and health_pack.tscn.

extends Area2D


func _ready() -> void:
	play_floating_animation()


func play_floating_animation() -> void:
	var tween := create_tween()
	tween.set_loops()
	tween.set_trans(Tween.TRANS_SINE)

	var sprite_2d := get_node("Sprite2D")
	var position_offset := Vector2(0.0, 4.0)
	var duration = randf_range(0.8, 1.2)
	sprite_2d.position = -1.0 * position_offset
	tween.tween_property(sprite_2d, "position", position_offset, duration)
	tween.tween_property(sprite_2d, "position",  -1.0 * position_offset, duration)

#Making collectible item pop then disappear
func _input_event(viewport: Viewport, event: InputEvent, shape_index: int) -> void:
	var event_is_mouse_clicked: bool = (
		event is InputEventMouseButton and
		event.button_index == MOUSE_BUTTON_LEFT and 
		event.is_pressed()
		)
		
	if event_is_mouse_clicked:
		start_pop_animation()
	
	# Make item pop before disappearing	
func start_pop_animation() -> void:
	# don't react to more clicks while popping
	set_process_input(false)
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.08).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(0.0, 0.0), 0.06).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.finished.connect(queue_free)
