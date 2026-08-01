extends Area2D

const GRAVITY := 600.0
var velocity := Vector2.ZERO

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	
	# Create a timer that automatically deletes the projectile after 3 seconds
	var lifespan_timer := get_tree().create_timer(3.0)
	lifespan_timer.timeout.connect(queue_free)

func _process(delta: float) -> void:
	velocity.y += GRAVITY * delta
	position += velocity * delta

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("die"):
		body.die()
		queue_free()
