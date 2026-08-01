extends CharacterBody2D

const JUMP_VELOCITY := -350.0
const THROW_COOLDOWN := 1.5

var throw_timer := THROW_COOLDOWN
var jump_timer := 1.0
var target: Node2D = null

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var projectile_scene: PackedScene 

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if target != null:
		# horizontal distance to the player
		var distance_x := target.global_position.x - global_position.x
		var direction_to_target := signf(distance_x)
		
		# Face the player
		if direction_to_target != 0:
			animated_sprite.flip_h = direction_to_target > 0
			
		# Play the Attack animation when the player is near
		if animated_sprite.animation != "nintendoN_Attack":
			animated_sprite.play("nintendoN_Attack")
		
		# Jumping Logic
		jump_timer -= delta
		if is_on_floor() and jump_timer <= 0.0:
			velocity.y = JUMP_VELOCITY
			jump_timer = randf_range(1.2, 2.8)
			
		# Throwing Logic
		throw_timer -= delta
		if throw_timer <= 0.0:
			_throw_projectile(distance_x) # Pass the exact distance to the throw function
			throw_timer = THROW_COOLDOWN
	else:
		velocity.x = 0
		# Return to Idle when the player leaves the zone
		if animated_sprite.animation != "nintendoN_Idle":
			animated_sprite.play("nintendoN_Idle")

	move_and_slide()

func _throw_projectile(distance_x: float) -> void:
	if projectile_scene != null:
		var proj = projectile_scene.instantiate()
		get_parent().add_child(proj) 
		proj.global_position = global_position
		
		if proj.get("velocity") != null:
			# the time the projectile spends in the air
			var throw_speed_x = clamp(absf(distance_x) * 0.9, 50.0, 450.0)
			
			var dir = signf(distance_x)
			if dir == 0: 
				dir = -1.0
				
			proj.velocity = Vector2(dir * throw_speed_x, -350.0)

func _on_detection_zone_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") or body.has_method("die"):
		target = body

func _on_detection_zone_body_exited(body: Node2D) -> void:
	if body == target:
		target = null

func die() -> void:
	set_physics_process(false)
	
	# Turn off the main collision so it doesn't block the player
	collision_layer = 0
	collision_mask = 0
	
	# Turn off the attack hitbox so it can't kill the player during the death animation
	if has_node("Hitbox"):
		$Hitbox.set_deferred("monitoring", false)
		
	animated_sprite.play("nintendoN_Death")
	await animated_sprite.animation_finished
	queue_free()
