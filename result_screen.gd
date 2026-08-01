extends Control

@onready var replay_button: Button = $CenterContainer/VBoxContainer/ReplayButton


func _ready() -> void:
	replay_button.pressed.connect(_on_replay_pressed)


func _on_replay_pressed() -> void:
	get_tree().change_scene_to_file("res://level.tscn")
