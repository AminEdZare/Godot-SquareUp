class_name HUD
extends CanvasLayer
## Heads-up display: hearts, score and the game-over screen.
## Covers the UI half of Health.cs plus Score.cs and GameOverScreen.cs.

@export var full_heart: Texture2D
@export var empty_heart: Texture2D

@onready var _hearts: Array[Node] = $Root/Hearts.get_children()
@onready var _score_label: Label = $Root/ScoreText
@onready var _game_over: Control = $Root/GameOver
@onready var _points_label: Label = $Root/GameOver/PointsText
@onready var _retry_button: Button = $Root/GameOver/RetryButton
@onready var _quit_button: Button = $Root/GameOver/QuitButton

var _pulse: Tween


func _ready() -> void:
	_game_over.hide()
	_score_label.text = str(Game.score)
	_score_label.pivot_offset = _score_label.size * 0.5
	Game.score_changed.connect(_on_score_changed)
	_retry_button.pressed.connect(_on_retry_pressed)
	_quit_button.pressed.connect(_on_quit_pressed)
	# Phones and tablets have no use for a Quit button.
	if OS.has_feature("mobile") or OS.has_feature("web"):
		_quit_button.hide()
		# Retry is anchored to the screen centre, so centring its offsets is enough.
		var half_width := (_retry_button.offset_right - _retry_button.offset_left) * 0.5
		_retry_button.offset_left = -half_width
		_retry_button.offset_right = half_width


## Health.cs Update(): hearts below `health` are full, the rest empty, and
## hearts beyond `max_health` are hidden.
func set_health(health: int, max_health: int) -> void:
	for i in _hearts.size():
		var heart := _hearts[i] as TextureRect
		heart.texture = full_heart if i < health else empty_heart
		heart.visible = i < max_health


## GameOverScreen.SetUp().
func show_game_over() -> void:
	_points_label.text = "%d POINTS" % Game.score
	_game_over.show()


func _on_score_changed(score: int) -> void:
	_score_label.text = str(score)
	if score > 0:
		_pulse_score()


## Score.Pulse(): the score pops to 120% and back. The original stepped the
## scale by 0.05 per frame, which is about 1/15 s each way at 60 fps.
func _pulse_score() -> void:
	if _pulse != null:
		_pulse.kill()
	_score_label.scale = Vector2.ONE
	_pulse = create_tween()
	_pulse.tween_property(_score_label, "scale", Vector2(1.2, 1.2), 4.0 / 60.0)
	_pulse.tween_property(_score_label, "scale", Vector2.ONE, 4.0 / 60.0)


func _on_retry_pressed() -> void:
	Game.reset_score()
	get_tree().reload_current_scene()


func _on_quit_pressed() -> void:
	get_tree().quit()
