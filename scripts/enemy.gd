class_name Enemy
extends CharacterBody2D
## Enemy brain (EnemyIQ.cs). Walks toward the player until it is within
## `chase_range`, backs off if the player gets inside `retreat_range`, and
## fires a homing projectile on a fixed timer.

@export_group("Stats")
@export var health: int = 10
## Hearts given back to the player when this enemy dies.
@export var regen: int = 1
## Score awarded on death.
@export var xp: int = 50
@export var speed: float = 400.0
## Unity: shotFrequency (seconds between shots).
@export var shot_cooldown: float = 0.75

@export_group("Distances")
## Unity: distanceRange. Farther than this: approach.
@export var chase_range: float = 100.0
## Unity: retreatRange. Closer than this: back away.
@export var retreat_range: float = 50.0

@export_group("Objects")
@export var projectile_scene: PackedScene
@export var death_effect: PackedScene

var _target: Node2D
var _time_until_next_shot: float = 0.0
var _dead: bool = false


func _ready() -> void:
	_target = get_tree().get_first_node_in_group("player") as Node2D
	_time_until_next_shot = shot_cooldown


func _process(delta: float) -> void:
	# No player (it died): stand still and hold fire.
	if _dead or not is_instance_valid(_target):
		return

	var target_position := _target.global_position
	var distance := global_position.distance_to(target_position)
	if distance > chase_range:
		global_position = global_position.move_toward(target_position, speed * delta)
	elif distance < retreat_range and distance > 0.0:
		global_position += (global_position - target_position) / distance * speed * delta

	if _time_until_next_shot <= 0.0:
		Game.spawn(projectile_scene, global_position)
		_time_until_next_shot = shot_cooldown
	else:
		_time_until_next_shot -= delta


func take_damage(amount: int) -> void:
	if _dead:
		return
	health -= amount
	if health <= 0:
		_die()


func _die() -> void:
	_dead = true
	Game.add_score(xp)
	Game.spawn(death_effect, global_position)
	var player := get_tree().get_first_node_in_group("player")
	if player != null:
		player.heal(regen)
	queue_free()
