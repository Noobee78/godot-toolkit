class_name Player extends CharacterBody3D


@export var max_speed := 8.0
@export var acceleration := 40.0
@export var deceleration := 60.0

# Gravity
@export var gravity := 32.0
@export var jump_velocity := 13.0

# Teleport
@export var teleport_distance := 8.0
@export var ground_teleport_cooldown := 0.6
@export var air_teleport_cooldown := 0.45
@export var teleport_momentum_boost := 1.35

@onready var teleport_ray: RayCast3D = $TeleportRay

var _teleport_timer := 0.0


func _physics_process(delta: float) -> void:
	# Cooldown timer
	if _teleport_timer > 0.0:
		_teleport_timer = maxf(_teleport_timer - delta, 0.0)
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta	
	else:
		if velocity.y < 0.0:
			velocity.y = 0.0

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# Horizontal movement (2.5D side-scroller: x only, z locked)
	var direction_x := Input.get_axis("move_left", "move_right")
	var target_speed := direction_x * max_speed
	
	if absf(target_speed) > 0.01:
		velocity.x = move_toward(velocity.x, target_speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, deceleration * delta)
		
	# Lock z axis for side-scroller feel
	global_position.z = 0.0
	velocity.z = 0.0
	
	if Input.is_action_just_pressed("teleport"):
		teleport(direction_x)
		
	move_and_slide()
	
func teleport(direction_x: float) -> void:
	var dir := direction_x
	
	if absf(dir) < 0.01:
		dir = signf(velocity.x)
	
	if absf(dir) < 0.01:
		dir = 1.0

	# --- Cooldown grounded/airborne dependent ---
	var cooldown := ground_teleport_cooldown if is_on_floor() else air_teleport_cooldown
	
	if _teleport_timer > 0.0:
		return
	
	_teleport_timer = cooldown

	# --- Compute teleport along X axis (side scroller) ---
	var desired_offset := Vector3(dir * teleport_distance, 0.0, 0.0)
	var final_offset := desired_offset

	if is_instance_valid(teleport_ray):
		teleport_ray.target_position = desired_offset
		teleport_ray.force_raycast_update()
		
		if teleport_ray.is_colliding():
			var hit_point: Vector3 = teleport_ray.get_collision_point()
			var from_point: Vector3 = teleport_ray.global_position
			var to_hit := hit_point - from_point
			
			# Stop slightly before the collision surface
			final_offset = to_hit - (to_hit.normalized() * 0.2)

	# Apply teleport
	global_position += final_offset

	# Apply momentum boost
	apply_teleport_momentum_boost(dir)


func apply_teleport_momentum_boost(direction: float) -> void:
	# Add burst in teleport direction. boost means 1.35 -> 35% of max_speed at burst
	velocity.x += direction * (max_speed * (teleport_momentum_boost - 1.0))
	
	# Clamp to never exceed max speed
	velocity.x = clampf(velocity.x, -max_speed, max_speed)
