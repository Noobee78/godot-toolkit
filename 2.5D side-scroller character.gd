extends CharacterBody3D

@export var speed = 4.0

@onready var animated_player: AnimatedPlayer = $AnimatedPlayer

func _ready() -> void:
	look_toward_direction(Vector3.BACK)
	
func _physics_process(delta: float) -> void:
	var direction := get_movement_direction()
	core_movement(direction, delta)
	look_toward_direction(direction)
	move_and_slide()
	
func get_movement_direction() -> Vector3:
	var input := Vector3.ZERO
	var input_dir := Input.get_axis("move_left", "move_right")
	input = Vector3(input_dir, 0, 0.0)
	return input.normalized()

func look_toward_direction(direction: Vector3) -> void:
	if direction.is_zero_approx(): return
	animated_player.look_at(global_position + direction, Vector3.UP, true)
	
func core_movement(direction: Vector3, delta: float) -> void:
	if direction:
		velocity.x = direction.x * speed
		animated_player.set_run_blend(1.0)
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		animated_player.set_run_blend(-1.0)
	if not is_on_floor():
		velocity += get_gravity() * delta

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.double_click:
			global_position += Vector3.UP * 6.0
