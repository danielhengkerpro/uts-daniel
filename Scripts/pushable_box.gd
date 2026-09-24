extends CharacterBody2D
class_name PushableBox

@export var push_speed: float = 80.0

var push_direction: float = 0.0
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	# Terapkan gravitasi jika kotak di udara
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Pergerakan dorong horizontal
	if push_direction != 0.0:
		velocity.x = push_direction * push_speed
		if animated_sprite and animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation("hit"):
			animated_sprite.play("hit")
		push_direction = 0.0
	else:
		velocity.x = move_toward(velocity.x, 0.0, push_speed * 10.0 * delta)
		if animated_sprite and animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation("idle"):
			if not animated_sprite.is_playing() or animated_sprite.animation == "hit":
				animated_sprite.play("idle")

	move_and_slide()

func push(direction: float) -> void:
	push_direction = direction
