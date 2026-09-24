extends Area2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
var activated: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if activated:
		return
	if body is CharacterBody2D:
		activated = true
		body.spawn_position = global_position + Vector2(0, 8)
		if body.has_method("notify_checkpoint"):
			body.notify_checkpoint()
		animated_sprite.play("flag_out")
		await animated_sprite.animation_finished
		animated_sprite.play("flag_idle")
