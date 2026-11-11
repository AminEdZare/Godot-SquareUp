extends Area2D
## A homing enemy shot (Enemy01Proj.cs). Used by the red bolt, the fireball
## and the melon slice; they differ only in their exported values.

@export_group("Projectile Stats")
@export var speed: float = 500.0
## Unity: `offset`, in degrees. Added to the "away from the player" angle, so
## 180 makes the sprite's right-hand side face the player.
@export var rotation_offset_degrees: float = 0.0
## Seconds before the shot gives up and pops.
@export var lifetime: float = 4.0
@export var damage: int = 1

@export_group("Objects")
## Unity: damageEffect (shown on hit and on timeout).
@export var hit_effect: PackedScene

var _age: float = 0.0
var _done: bool = false
var _player: Node2D


func _ready() -> void:
	_player = get_tree().get_first_node_in_group("player") as Node2D
	body_entered.connect(_on_body_entered)
	# Face the right way on the very first drawn frame.
	if is_instance_valid(_player):
		rotation = (global_position - _player.global_position).angle() \
				- deg_to_rad(rotation_offset_degrees)


func _process(delta: float) -> void:
	if _done:
		return
	_age += delta
	if _age >= lifetime:
		_finish()
		return
	# Once the player is gone the shot just hangs in the air until it times
	# out, exactly like the original.
	if not is_instance_valid(_player):
		return

	var target := _player.global_position
	var away := global_position - target
	global_position = global_position.move_toward(target, speed * delta)
	rotation = away.angle() - deg_to_rad(rotation_offset_degrees)


func _on_body_entered(body: Node2D) -> void:
	if _done or not body.is_in_group("player"):
		return
	body.take_damage(damage)
	_finish()


func _finish() -> void:
	_done = true
	Game.spawn(hit_effect, global_position)
	queue_free()
