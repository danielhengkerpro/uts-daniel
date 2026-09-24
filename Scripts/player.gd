extends CharacterBody2D

signal score_changed(new_score: int)

const SPEED = 250.0
const JUMP_VELOCITY = -420.0

var score: int = 0
var spawn_position: Vector2 = Vector2.ZERO

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var score_label: Label = $HUD/ScorePanel/ScoreLabel
@onready var win_panel: Control = $HUD/WinPanel
@onready var win_label: Label = $HUD/WinPanel/WinLabel


func _ready() -> void:
	spawn_position = global_position
	# Ambil skor persisten dari GameManager jika ada
	if Engine.has_singleton("GameManager") or get_node_or_null("/root/GameManager"):
		var gm = get_node("/root/GameManager")
		score = gm.total_score
	update_score_ui()
	if win_panel:
		win_panel.visible = false


func _physics_process(delta: float) -> void:
	# Gravitasi
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Lompat hanya saat berpijak di tanah
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Horizontal movement
	var direction := Input.get_axis("move_left", "move_right")
	if direction != 0.0:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0.0, SPEED)

	move_and_slide()

	# Animasi & arah hadap
	update_animation(direction)


func update_animation(direction: float) -> void:
	if direction > 0.0:
		animated_sprite.flip_h = false
	elif direction < 0.0:
		animated_sprite.flip_h = true

	if not is_on_floor():
		animated_sprite.play("jump")
	elif direction != 0.0:
		animated_sprite.play("run")
	else:
		animated_sprite.play("idle")


func add_score(amount: int) -> void:
	score += amount
	if get_node_or_null("/root/GameManager"):
		get_node("/root/GameManager").add_score(amount)
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
		win_label.text = "CONGRATULATIONS!\nALL WORLDS CLEARED!\nFINAL SCORE: %d" % score
		win_panel.visible = true


func notify_checkpoint() -> void:
	if score_label:
		var orig = score_label.text
		score_label.text = "CHECKPOINT REACHED!"
		await get_tree().create_timer(1.2).timeout
		update_score_ui()
