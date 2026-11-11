extends Area2D
## The player's shot (PlayerProjectile.cs).
##
## Unity ran a zero-length raycast from the projectile's centre every frame,
## which is a point test against the enemy layer. Here a tiny collision shape
## on this Area2D does the same job through `body_entered`.

@export_group("Projectile Stats")
## Unity: 5 units/s.
@export var speed: float = 500.0
## Seconds before the shot fizzles out. With the speed above that is a range
## of 250 px (2.5 Unity units).
@export var lifetime: float = 0.5
@export var damage: int = 5

@export_group("Objects")
## Unity: destroyEffect (shown when the shot hits something).
@export var hit_effect: PackedScene
## Unity: dissappearEffect (shown when the shot runs out of lifetime).
@export var expire_effect: PackedScene

var _age: float = 0.0
var _done: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	if _done:
		return
	position += transform.x * speed * delta
	_age += delta
	if _age >= lifetime:
		_finish(expire_effect)


func _on_body_entered(body: Node2D) -> void:
	if _done:
		return
	if body.is_in_group("enemy"):
		body.take_damage(damage)
	_finish(hit_effect)


func _finish(effect: PackedScene) -> void:
	_done = true
	Game.spawn(effect, global_position)
	queue_free()
