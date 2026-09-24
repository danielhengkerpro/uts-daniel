extends CharacterBody2D

signal score_changed(new_score: int)

const SPEED = 250.0
const JUMP_VELOCITY = -420.0

var score: int = 0
var spawn_position: Vector2 = Vector2(80, 410)

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var score_label: Label = $HUD/ScorePanel/ScoreLabel
@onready var win_panel: Control = $HUD/WinPanel
@onready var win_label: Label = $HUD/WinPanel/WinLabel


func _ready() -> void:
	spawn_position = global_position
	update_score_ui()
	if win_panel:
		win_panel.visible = false


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump (hanya ketika sedang berpijak di tanah)
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("move_left", "move_right")
	if direction != 0.0:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0.0, SPEED)

	move_and_slide()

	# Panggil fungsi untuk ganti animasi & arah sprite
	update_animation(direction)


func update_animation(direction: float) -> void:
	# Balik sprite (flip_h) sesuai arah gerak
	if direction > 0.0:
		animated_sprite.flip_h = false
	elif direction < 0.0:
		animated_sprite.flip_h = true

	# Mainkan animasi run/jump/idle sesuai kondisi is_on_floor() dan direction
	if not is_on_floor():
		animated_sprite.play("jump")
	elif direction != 0.0:
		animated_sprite.play("run")
	else:
		animated_sprite.play("idle")


func add_score(amount: int) -> void:
	score += amount
	update_score_ui()
	score_changed.emit(score)


func update_score_ui() -> void:
	if score_label:
		score_label.text = "SCORE: %d" % score


func die_and_respawn() -> void:
	velocity = Vector2.ZERO
	global_position = spawn_position


func show_win_ui() -> void:
	if win_panel and win_label:
		win_label.text = "LEVEL COMPLETE!\nFINAL SCORE: %d" % score
		win_panel.visible = true
