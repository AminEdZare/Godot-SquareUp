extends Node
## Endless enemy spawner (EnemySpawner.cs).
##
## Loop: pick a point on a circle around the player, play the warning effect
## there, wait `warning_time`, drop a random enemy on that point, wait
## `spawn_interval`, repeat. Stops for good once the player is dead.

@export_group("Spawn Stats")
## Unity: spawnRadius = 4 units.
@export var spawn_radius: float = 400.0
## Unity: `time`, the pause after an enemy appears.
@export var spawn_interval: float = 1.0
## Unity: timeBtwEffAndSpawn, how long the warning plays first.
@export var warning_time: float = 2.0

@export_group("Spawn Objects")
@export var spawn_effect: PackedScene
@export var enemies: Array[PackedScene] = []

enum _State { WARNING, COOLDOWN, STOPPED }

var _state: _State = _State.STOPPED
var _time_left: float = 0.0
var _spawn_position: Vector2


func _ready() -> void:
	# Deferred: the level is still being assembled while _ready runs, so nothing
	# can be added to it yet.
	_begin_warning.call_deferred()


func _process(delta: float) -> void:
	if _state == _State.STOPPED:
		return
	_time_left -= delta
	if _time_left > 0.0:
		return

	if _state == _State.WARNING:
		if not enemies.is_empty():
			Game.spawn(enemies.pick_random(), _spawn_position)
		_state = _State.COOLDOWN
		_time_left += spawn_interval
	else:
		_begin_warning()


func _begin_warning() -> void:
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		_state = _State.STOPPED
		return
	_spawn_position = player.global_position + Vector2.from_angle(randf() * TAU) * spawn_radius
	Game.spawn(spawn_effect, _spawn_position)
	_state = _State.WARNING
	_time_left += warning_time
