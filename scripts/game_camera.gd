extends Camera2D
## Keeps a fixed slice of the world on screen, whatever the window shape.
##
## Unity's camera was orthographic with size 5: always 10 units tall, wider or
## narrower depending on the aspect ratio. This does the same by adjusting the
## zoom whenever the window is resized.

## World height that fills the screen, in pixels (10 Unity units).
@export var visible_height: float = 1000.0


func _ready() -> void:
	get_viewport().size_changed.connect(_update_zoom)
	_update_zoom()


func _update_zoom() -> void:
	var viewport_height := get_viewport_rect().size.y
	if viewport_height > 0.0:
		zoom = Vector2.ONE * (viewport_height / visible_height)
