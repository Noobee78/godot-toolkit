extends CharacterBody3D

@export var move_speed: float = 8.0
@export var acceleration: float = 18.0
@export var air_control: float = 0.4

@export var jump_velocity: float = 8.5
@export var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity") as float

@export var teleport_distance: float = 6.0
@export var teleport_cooldown: float = 0.6

# How fast the character rotates to face movement direction
@export var turn_speed: float = 12.0

# Cached camera pivot to move relative to camera
@onready var camera_pivot: Node3D = $CameraPivot

var _last_move_dir: Vector3 = Vector3.FORWARD
var _can_teleport: bool = true
var _teleport_timer: float = 0.0


func _physics_process(delta: float) -> void:
	# 1) Handle movement input (on XZ plane)
	var input_dir: Vector2 = _get_input_axis()

	# Convert 2D input into 3D movement relative to the camera
	var move_dir: Vector3 = Vector3.ZERO
	if input_dir.length() > 0.0:
		# Get camera basis
		var basis: Basis = camera_pivot.global_transform.basis
		var forward: Vector3 = -basis.z
		var right: Vector3 = basis.x

		# Build world-space direction from input
		move_dir = (right * input_dir.x) + (forward * input_dir.y)
		move_dir.y = 0.0
		move_dir = move_dir.normalized()
		_last_move_dir = move_dir

	# 2) Apply acceleration / deceleration on XZ
	var target_velocity: Vector3 = move_dir * move_speed
	var control_factor: float = acceleration if is_on_floor() else acceleration * air_control

	velocity.x = lerp(velocity.x, target_velocity.x, control_factor * delta)
	velocity.z = lerp(velocity.z, target_velocity.z, control_factor * delta)

	# 3) Gravity + jump
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_velocity

	# 4) Rotate character toward movement direction for “tight” feel
	if _last_move_dir.length_squared() > 0.0:
		var target_yaw: float = atan2(-_last_move_dir.x, -_last_move_dir.z)
		var current_yaw: float = rotation.y
		rotation.y = lerp_angle(current_yaw, target_yaw, turn_speed * delta)

	# 5) Move the character
	move_and_slide()

	# 6) Teleport cooldown timer
	if not _can_teleport:
		_teleport_timer -= delta
		if _teleport_timer <= 0.0:
			_can_teleport = true


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("teleport"):
		_attempt_teleport()


func _attempt_teleport() -> void:
	if not _can_teleport:
		return

	# No movement input? don’t teleport.
	if _last_move_dir.length_squared() == 0.0:
		return

	var from: Vector3 = global_transform.origin
	var to: Vector3 = from + _last_move_dir * teleport_distance

	# SIMPLE VERSION: just snap to "to"
	# Later we’ll raycast to avoid going through walls.
	global_transform.origin = to

	_can_teleport = false
	_teleport_timer = teleport_cooldown


func _get_input_axis() -> Vector2:
	var x: float = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var y: float = Input.get_action_strength("move_forward") - Input.get_action_strength("move_back")
	var axis := Vector2(x, y)
	if axis.length() > 1.0:
		axis = axis.normalized()
	return axis
