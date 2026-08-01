extends CharacterBody2D


var player_money: int = 15
var safe_limit: int = 17

func _ready() -> void:
	check_guilt(player_money)

func check_guilt(amount: int) -> void:
	if amount >= safe_limit:
		print("You have ", amount, " money. You are NOT guilty!")
	else:
		print("You have ", amount, " money. You are guilty.")
