extends CharacterBody2D

const THROW_SPEED := 500.0
const THROW_UPWARD_SPEED := -100.0
const GRAVITY := 1200.0

var carried := false
var flying := false
var holder: Node2D = null


func _physics_process(delta: float) -> void:
	if carried:
		return

	if flying:
		velocity.y += GRAVITY * delta

		var collision := move_and_collide(velocity * delta)

		if collision:
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

	reparent(level, true)

	carried = false
	flying = true

	collision_layer = 1
	collision_mask = 1

	var direction := 1.0

	if old_holder.has_method("get_facing_direction"):
		direction = old_holder.get_facing_direction()

	velocity = Vector2(
		direction * THROW_SPEED,
		THROW_UPWARD_SPEED
	)

	holder = null
