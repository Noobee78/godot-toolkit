extends Area2D


var max_speed := 1200.0
var velocity := Vector2.ZERO
var steering_factor := 3.0
var max_health := 100
var health := 100
var gem_count := 0

func _physics_process(delta: float) -> void:
	var objects_in_range = get_overlapping_bodies()
	if objects_in_range.size() > 0:
		var target_object = objects_in_range.front()
		look_at(target_object.global_position)

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	# This call updates the health bar to math the health variable when the
	# game starts
	$HealthDecayTimer.timeout.connect(_on_health_decay_timer_timeout)
	set_health(health)

func _process(delta: float) -> void:
	var direction := Vector2.ZERO
	direction.x = Input.get_axis("move_left", "move_right")
	direction.y = Input.get_axis("move_up", "move_down")

	if direction.length() > 1.0:
		direction = direction.normalized()

	var desired_velocity := max_speed * direction
	var steering := desired_velocity - velocity
	velocity += steering * steering_factor * delta
	position += velocity * delta

	if velocity.length() > 0.0:
		#rotation = velocity.angle()
		get_node("Sprite2D").rotation = velocity.angle()
		
	var viewport_size := get_viewport_rect().size
	position.x = wrapf(position.x, 0, viewport_size.x)
	position.y = wrapf(position.y, 0, viewport_size.y)
			
func _on_health_decay_timer_timeout() -> void:
	set_health(health - 1) # lose 1 health  per second

func set_health(new_health: int) -> void:
	health = clamp(new_health, 0, max_health)
	get_node("UI/HealthBar").value = health
	
	if health <= 0:
		get_tree().reload_current_scene()
	
func set_gem_count(new_gem_count: int) -> void:
	gem_count = new_gem_count
	get_node("UI/GemCount").text = "x" + str(gem_count)

func _on_area_entered(area_that_entered: Area2D) -> void:
	if area_that_entered.is_in_group("gem"):
		set_gem_count(gem_count + 1)
		area_that_entered.queue_free()
	elif area_that_entered.is_in_group("healing_item"):
		set_health(health + 25)
		area_that_entered.queue_free()
		
func shoot() -> void:
	const BULLET = preload("res://lessons/Scenes/bullet.tscn")
	var new_bullet = BULLET.instantiate()
	new_bullet.gloabl_position = $ShootingPoint.global_position
