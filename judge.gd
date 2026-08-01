extends Node2D

@onready var interact_area: Area2D = $InteractArea

const REQUIRED_COINS := 14

var intro_lines: Array[String] = []
var repeat_line := ""

var current := 0
var active := false
var has_talked := false
var player_in_range := false
var player: Node = null

var box: Panel
var label: Label

var player_won := false

func _ready() -> void:
	_build_box()
	player = get_node("../Player")

	interact_area.body_entered.connect(_on_body_entered)
	interact_area.body_exited.connect(_on_body_exited)


func _build_box() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 100
	add_child(layer)

	box = Panel.new()
	box.position = Vector2(300, 120)
	box.size = Vector2(560, 120)
	box.visible = false
	layer.add_child(box)

	label = Label.new()
	label.position = Vector2(16, 12)
	label.size = Vector2(528, 96)
	label.add_theme_font_size_override("font_size", 22)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(label)


func _on_body_entered(body: Node2D) -> void:
	if body == player:
		player_in_range = true

		if not has_talked:
			_start_verdict()


func _on_body_exited(body: Node2D) -> void:
	if body == player:
		player_in_range = false


func _get_coin_count() -> int:
	if player == null:
		return 0

	var value = player.get("coin_count")
	return int(value) if value != null else 0


func _start_verdict() -> void:
	var coins := _get_coin_count()
	player_won = coins >= REQUIRED_COINS

	if player_won:
		intro_lines = [
			"All rise. The court is now in session.",
			"You have collected %d coins. The required amount is 14." % coins,
			"Verdict: NOT GUILTY!",
			"You have enough money to pay your legal fees."
		]
		repeat_line = "Verdict: NOT GUILTY. You met the 14-coin requirement."
	else:
		intro_lines = [
			"All rise. The court is now in session.",
			"You have collected %d coins, but you need at least 14." % coins,
			"Verdict: GUILTY!",
			"You did not collect enough money to pay your legal fees."
		]
		repeat_line = "Verdict: GUILTY. You still need 14 coins."

	active = true
	current = 0
	has_talked = true
	box.visible = true
	label.text = intro_lines[current]
	_set_player_locked(true)


func _input(event: InputEvent) -> void:
	if active:
		if event.is_action_pressed("jump") \
		or event.is_action_pressed("interact") \
		or event.is_action_pressed("ui_accept"):
			current += 1

			if current >= intro_lines.size():
				active = false
				box.visible = false
				_set_player_locked(false)

				var result_scene := "res://win_screen.tscn" if player_won else "res://lose_screen.tscn"
				get_tree().call_deferred("change_scene_to_file", result_scene)
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
