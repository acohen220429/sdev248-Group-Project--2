extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var foreground_tile_map: TileMapLayer = $"../ForegroundTileMap"
@onready var coin_label: Label = $"../HUD/CoinLabel"

const SPEED := 300.0
const JUMP_VELOCITY := -400.0

var facing_direction := 1.0
var nearby_box: Node2D = null
var held_box: Node2D = null
var coin_count := 0
var is_dead := false

func _ready() -> void:
	$PickupZone.body_entered.connect(_on_pickup_zone_body_entered)
	$PickupZone.body_exited.connect(_on_pickup_zone_body_exited)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction := Input.get_axis("move_left", "move_right")

	if direction:
		velocity.x = direction * SPEED
		facing_direction = signf(direction)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	if Input.is_action_just_pressed("interact"):
		if held_box != null:
			held_box.toggle_carry(self)
			held_box = null
		elif nearby_box != null:
			nearby_box.toggle_carry(self)
			held_box = nearby_box
			nearby_box = null

	move_and_slide()
	_collect_coins()
	_update_animation()

func _update_animation() -> void:
	animated_sprite.flip_h = facing_direction < 0

	var next_animation := "idle"

	if not is_on_floor():
		if velocity.y < 0:
			next_animation = "jump"
		else:
			next_animation = "fall"
	elif absf(velocity.x) > 0.1:
		next_animation = "walk"

	if animated_sprite.animation != next_animation or not animated_sprite.is_playing():
		animated_sprite.play(next_animation)


func get_facing_direction() -> float:
	return facing_direction


func _on_pickup_zone_body_entered(body: Node2D) -> void:
	if body.is_in_group("pickable_box"):
		nearby_box = body


func _on_pickup_zone_body_exited(body: Node2D) -> void:
	if body == nearby_box:
		nearby_box = null

func die() -> void:
	if is_dead:
		return

	is_dead = true
	set_physics_process(false)
	get_tree().call_deferred("reload_current_scene")

func _collect_coins() -> void:
	var collision_shape := $CollisionShape2D.shape as RectangleShape2D

	if collision_shape == null:
		return

	var player_scale := Vector2(
		absf(global_scale.x),
		absf(global_scale.y)
	)

	var world_size := collision_shape.size * player_scale
	var half_size := world_size * 0.5

	var map_center := foreground_tile_map.to_local(
		$CollisionShape2D.global_position
	)

	var player_rect := Rect2(
		map_center - half_size,
		world_size
	)

	var first_cell := foreground_tile_map.local_to_map(player_rect.position)
	var last_cell := foreground_tile_map.local_to_map(
		player_rect.position + player_rect.size - Vector2.ONE * 0.001
	)

	for y in range(first_cell.y, last_cell.y + 1):
		for x in range(first_cell.x, last_cell.x + 1):
			var cell := Vector2i(x, y)
			var tile_data := foreground_tile_map.get_cell_tile_data(cell)

			if tile_data == null:
				continue

			var power_up_type := int(
				tile_data.get_custom_data("PowerUpType")
			)

			if power_up_type != 1:
				continue

			foreground_tile_map.erase_cell(cell)

			coin_count += 1
			coin_label.text = "Coins: %d" % coin_count
