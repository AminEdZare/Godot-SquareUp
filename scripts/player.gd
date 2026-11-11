class_name Player
extends CharacterBody2D
## The player square. Combines three Unity scripts:
## PlayerController.cs (movement), Boundaries.cs (stay on screen) and
## Health.cs (hearts, damage, regen, death).

signal health_changed(health: int, max_health: int)
signal died

@export_group("Movement")
## Unity: PlayerController.speed = 5.5 units/s.
@export var speed: float = 550.0

@export_group("Health")
## Unity: Health.health.
@export var health: int = 5
## Unity: Health.numOfHearts.
@export var max_health: int = 5

@export_group("Objects")
## Unity: Health.playerDeathEffect.
@export var death_effect: PackedScene

@onready var _sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	health = mini(health, max_health)
	health_changed.emit(health, max_health)


func _process(delta: float) -> void:
	# GetAxisRaw + normalized: always full speed, including on diagonals.
	var input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input != Vector2.ZERO:
		position += input.normalized() * speed * delta
	_clamp_to_screen()


## Keeps the whole sprite inside the visible part of the world (Boundaries.cs).
## Reads the camera view every frame, so it follows window resizes.
func _clamp_to_screen() -> void:
	var view := get_canvas_transform().affine_inverse() * get_viewport_rect()
	var half := _sprite.texture.get_size() * _sprite.global_scale * 0.5
	global_position = global_position.clamp(view.position + half, view.end - half)


func take_damage(amount: int) -> void:
	if health <= 0:
		return
	health -= amount
	health_changed.emit(maxi(health, 0), max_health)
	if health <= 0:
		_die()


## Called by enemies when they die (Health.PlayerRegen).
func heal(amount: int) -> void:
	if health <= 0:
		return
	health = mini(health + amount, max_health)
	health_changed.emit(health, max_health)


func _die() -> void:
	Game.spawn(death_effect, global_position)
	died.emit()
	queue_free()
