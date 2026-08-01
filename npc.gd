extends Node2D

@onready var interact_area: Area2D = $InteractArea

var intro_lines: Array[String] = [
	"Hey kid! I heard you got some kind of lawsuits goin' on.",
	"I'll be your lawyer but you gotta get me that chedda' if you expect me to work for you.",
	"Let's say you get me 17 coins? That oughta be enough.",
	"Don't try and swindle me either, the Judge will know..."
]
var repeat_line := "Go make that money kid!"

var current := 0
var active := false
var has_talked := false
var player_in_range := false
var player: Node = null

var box: Panel
var label: Label

func _ready() -> void:
	_build_box()
	player = get_node("../Player")
	interact_area.body_entered.connect(_on_body_entered)
	interact_area.body_exited.connect(_on_body_exited)
	_start_intro()

func _build_box() -> void:
	# CanvasLayer so it always draws on top, in screen space
	var layer := CanvasLayer.new()
	layer.layer = 100
	add_child(layer)

	box = Panel.new()
	box.position = Vector2(300, 120)      # screen position; tweak later
	box.size = Vector2(560, 90)
	layer.add_child(box)

	label = Label.new()
	label.position = Vector2(16, 12)
	label.size = Vector2(528, 66)
	label.add_theme_font_size_override("font_size", 22)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(label)

func _on_body_entered(body: Node2D) -> void:
	if body == player:
		player_in_range = true

func _on_body_exited(body: Node2D) -> void:
	if body == player:
		player_in_range = false

func _start_intro() -> void:
	active = true
	current = 0
	has_talked = true
	box.visible = true
	label.text = intro_lines[current]
	_set_player_locked(true)

func _input(event: InputEvent) -> void:
	if active:
		if event.is_action_pressed("jump") or event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
			current += 1
			if current >= intro_lines.size():
				active = false
				box.visible = false
				_set_player_locked(false)
			else:
				label.text = intro_lines[current]
			get_viewport().set_input_as_handled()
		return

	if has_talked and player_in_range and event.is_action_pressed("interact"):
		if box.visible:
			box.visible = false
		else:
			label.text = repeat_line
			box.visible = true
		get_viewport().set_input_as_handled()

func _set_player_locked(locked: bool) -> void:
	if player != null:
		player.set_physics_process(not locked)
