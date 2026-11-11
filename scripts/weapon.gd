extends Sprite2D
## The player's gun (Weapon.cs). Points at the mouse and fires one projectile
## per click, with a minimum delay between shots.

## Unity: Weapon.shotFrequency (seconds between shots).
@export var shot_cooldown: float = 0.25
## Unity: Weapon.projectile.
@export var projectile_scene: PackedScene

var _time_until_next_shot: float = 0.0

@onready var _shot_point: Marker2D = $ShotPoint


func _process(delta: float) -> void:
	look_at(get_global_mouse_position())

	if _time_until_next_shot <= 0.0:
		# Semi-automatic like the original: one shot per press, and presses made
		# during the cooldown are not buffered.
		if Input.is_action_just_pressed("shoot"):
			Game.spawn(projectile_scene, _shot_point.global_position, global_rotation)
			_time_until_next_shot = shot_cooldown
	else:
		_time_until_next_shot -= delta
