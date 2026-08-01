extends CharacterBody2D

const SPEED := 100.0
var direction := -1.0 
var is_attacking := false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var edge_detector: RayCast2D = $EdgeDetector

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Check edges and walls to turn around
	if is_on_wall() or (is_on_floor() and not edge_detector.is_colliding()):
		direction *= -1.0
		edge_detector.position.x = direction * absf(edge_detector.position.x)
		
	animated_sprite.flip_h = direction > 0
	velocity.x = direction * SPEED

	# Handle animation states based on proximity
	if is_attacking:
		if animated_sprite.animation != "nintendoS_Attack":
			animated_sprite.play("nintendoS_Attack")
	else:
		if animated_sprite.animation != "nintendoS_Idle" and not animated_sprite.is_playing():
			animated_sprite.play("nintendoS_Idle")

	move_and_slide()

func _on_detection_zone_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") or body.has_method("die"):
		is_attacking = true

func _on_detection_zone_body_exited(body: Node2D) -> void:
	if body == target_check(body):
		is_attacking = false

func target_check(body: Node2D) -> Node2D:
	return body

func die() -> void:
	set_physics_process(false)
	
	collision_layer = 0
	collision_mask = 0
	
	if has_node("Hitbox"):
		$Hitbox.set_deferred("monitoring", false)
		
	animated_sprite.play("nintendoS_Death")
	await animated_sprite.animation_finished
	queue_free()
