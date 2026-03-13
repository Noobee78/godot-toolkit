extends Node3D

@onready var _hit_area: HurtBox3D = %HitArea
@onready var _mesh: MeshInstance3D = %Mesh


func _ready() -> void:
	_hit_area.took_hit.connect(
		func _on_hit(hit_position: Vector3) -> void:
			var hit_tween := create_tween()

			#ANCHOR: hit_detection_direction_1
			var hit_direction := hit_position.direction_to(global_transform.origin)
			hit_direction.y = 0.0
			hit_direction = hit_direction.normalized()
			#END: hit_detection_direction_1

			# We calculate the angle we need to hit on the y-axis to face the
			# hit (and make the capsule lean back)
			#ANCHOR:hit_detection_direction_2
			var angle_gap := atan2(hit_direction.x, hit_direction.z)
			rotation.y = angle_gap
			#END:hit_detection_direction_2

			hit_tween.parallel().tween_property(self, "rotation:x", 0.8, 0.15) \
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

			hit_tween.parallel().tween_property(_mesh.material_override, "emission_energy_multiplier", 2.5, 0.1)

			hit_tween.tween_property(self, "rotation:x", 0.0, 1.25) \
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)

			var emission_tween := hit_tween.parallel().tween_property(_mesh.material_override, "emission_energy_multiplier", 0.0, 0.2)
			emission_tween.set_delay(0.1)
	)
