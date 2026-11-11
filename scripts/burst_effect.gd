class_name BurstEffect
extends Node2D
## One-shot burst of coloured squares, then the node frees itself.
##
## Replaces the nine Unity ParticleSystem prefabs in Prefabs/Effects. They all
## fired 30 square particles in a single burst and differed only in colour,
## size and emitter shape, so one small script reproduces them exactly:
##
## - CONE: Unity's cone emitter pointed into the screen (1 degree, speed 100).
##   Seen through the 2D camera that is a disc of squares spreading outward,
##   the fastest ones at 100 * sin(1 deg) = 1.745 units/s.
## - BOX: squares appear at random spots inside a box and stay put (the enemy
##   spawn warning).
##
## Every setting is exported, so effects can be tuned in the Inspector.

enum Shape { CONE, BOX }

@export var shape: Shape = Shape.CONE
## Number of squares. Unity: burst count, capped by Max Particles.
@export_range(1, 200) var amount: int = 30
## Seconds each square lives. Unity: Start Lifetime.
@export var lifetime: float = 1.0
## Side of a square in pixels at full size. Unity: Start Size x 100.
@export var particle_size: float = 30.0
## CONE only: outward speed of the fastest squares, in px/s.
@export var max_speed: float = 174.5
## BOX only: area the squares are scattered over, in px.
@export var box_size: Vector2 = Vector2(80, 80)
## Unity: Start Color.
@export var start_color: Color = Color.WHITE
## Unity: Color over Lifetime. Multiplied with the start colour. Optional.
@export var color_over_lifetime: Gradient
## Unity: Size over Lifetime. Multiplied with the particle size. Optional;
## without it the size stays constant.
@export var size_over_lifetime: Curve

var _age: float = 0.0
var _origins: PackedVector2Array = []
var _velocities: PackedVector2Array = []


func _ready() -> void:
	_origins.resize(amount)
	_velocities.resize(amount)
	for i in amount:
		if shape == Shape.CONE:
			# Uniform point in the unit disc: the direction is uniform and the
			# speed scales with the distance from the centre.
			var direction := Vector2.from_angle(randf() * TAU)
			_origins[i] = Vector2.ZERO
			_velocities[i] = direction * sqrt(randf()) * max_speed
		else:
			_origins[i] = Vector2(randf() - 0.5, randf() - 0.5) * box_size
			_velocities[i] = Vector2.ZERO


func _process(delta: float) -> void:
	_age += delta
	if _age >= lifetime:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var t := clampf(_age / lifetime, 0.0, 1.0)

	var color := start_color
	if color_over_lifetime != null:
		color *= color_over_lifetime.sample(t)

	var side := particle_size
	if size_over_lifetime != null:
		# Unity draws a negative size mirrored rather than hiding it.
		side *= absf(size_over_lifetime.sample(t))
	if side <= 0.0 or color.a <= 0.0:
		return

	var size := Vector2(side, side)
	for i in amount:
		var center := _origins[i] + _velocities[i] * _age
		draw_rect(Rect2(center - size * 0.5, size), color)
