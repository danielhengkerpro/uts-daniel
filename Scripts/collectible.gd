extends Area2D

signal collected(points: int)

@export var fruit_name: String = "Fruit"
@export var points: int = 1

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var is_collected: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	if animated_sprite:
		animated_sprite.animation_finished.connect(_on_animation_finished)
		animated_sprite.play("default")


func _on_body_entered(body: Node2D) -> void:
	if is_collected:
		return

	if body.name == "Player" or body.has_method("add_score"):
		is_collected = true
		if body.has_method("add_score"):
			body.add_score(points)
		collected.emit(points)

		if collision_shape:
			collision_shape.set_deferred("disabled", true)

		if animated_sprite and animated_sprite.sprite_frames.has_animation("collected"):
			animated_sprite.play("collected")
		else:
			queue_free()


func _on_animation_finished() -> void:
	if animated_sprite and animated_sprite.animation == "collected":
		queue_free()
