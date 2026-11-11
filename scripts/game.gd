extends Node
## Global game state (autoload singleton, registered as `Game`).
##
## Unity kept the score in a static field (`Score.scoreValue`) and found other
## objects by tag. Here the score lives in this autoload and everything else
## talks through signals and node groups.
##
## Units: the Unity project used 100 pixels per unit. Every distance and speed
## in this port is the Unity inspector value multiplied by 100, so a Unity
## speed of 5.5 is 550 here.

signal score_changed(score: int)

## World pixels per Unity unit. Handy when copying numbers from the old project.
const PIXELS_PER_UNIT := 100.0

var score: int = 0


func _ready() -> void:
	# Keep handling the fullscreen shortcut even if the tree is ever paused.
	process_mode = Node.PROCESS_MODE_ALWAYS


func add_score(points: int) -> void:
	score += points
	score_changed.emit(score)


func reset_score() -> void:
	score = 0
	score_changed.emit(score)


## Adds `node` to the running level at `at`. The Godot counterpart of
## `Instantiate(prefab, position, Quaternion.identity)`.
func spawn(scene: PackedScene, at: Vector2, angle: float = 0.0) -> Node2D:
	if scene == null:
		return null
	var node := scene.instantiate() as Node2D
	node.position = at
	node.rotation = angle
	get_tree().current_scene.add_child(node)
	return node


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_fullscreen"):
		var window := get_window()
		if window.mode == Window.MODE_FULLSCREEN:
			window.mode = Window.MODE_WINDOWED
		else:
			window.mode = Window.MODE_FULLSCREEN
