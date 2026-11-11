extends Node2D
## Root of the level (SampleScene in Unity). Wires the player to the HUD and
## shows the game-over screen, which is what GameController.cs did.

@onready var _player: Player = $Player
@onready var _hud: HUD = $HUD


func _ready() -> void:
	_player.health_changed.connect(_hud.set_health)
	_player.died.connect(_hud.show_game_over)
	_hud.set_health(_player.health, _player.max_health)
