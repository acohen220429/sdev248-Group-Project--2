extends CharacterBody2D


const SPEED := 300.0
const JUMP_VELOCITY := -400.0

var facing_direction := 1.0
var nearby_box: Node2D = null
var held_box: Node2D = null


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
		facing_direction = sign(direction)
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


func get_facing_direction() -> float:
	return facing_direction


func _on_pickup_zone_body_entered(body: Node2D) -> void:
	if body.is_in_group("pickable_box"):
		nearby_box = body


func _on_pickup_zone_body_exited(body: Node2D) -> void:
	if body == nearby_box:
		nearby_box = null
