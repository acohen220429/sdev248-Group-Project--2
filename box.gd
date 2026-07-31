extends CharacterBody2D

const THROW_SPEED := 500.0

var carried := false
var flying := false
var holder: Node2D = null


func _physics_process(_delta: float) -> void:
	if carried:
		return

	if flying:
		var collision := move_and_collide(velocity * _delta)

		if collision:
			flying = false
			velocity = Vector2.ZERO
			queue_free()
	else:
		velocity = Vector2.ZERO


func toggle_carry(player: Node2D) -> void:
	if carried:
		throw_box()
	elif not flying:
		pick_up(player)


func pick_up(player: Node2D) -> void:
	carried = true
	flying = false
	holder = player
	velocity = Vector2.ZERO

	reparent(player, true)

	position = Vector2(0, -60)

	collision_layer = 0
	collision_mask = 0


func throw_box() -> void:
	if holder == null:
		return

	var old_holder := holder
	var level := old_holder.get_parent()
	var release_y := old_holder.global_position.y

	var direction := 1.0

	if old_holder.has_method("get_facing_direction"):
		direction = old_holder.get_facing_direction()

	reparent(level, true)

	global_position.y = release_y

	var old_holder_body := old_holder as CharacterBody2D

	if old_holder_body != null:
		add_collision_exception_with(old_holder_body)

	carried = false
	flying = true

	collision_layer = 1
	collision_mask = 1

	velocity = Vector2(
		direction * THROW_SPEED,
		0.0
	)

	holder = null
