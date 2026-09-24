extends Area2D

@export var bounce_force: float = -650.0
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var can_bounce: bool = true


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if not can_bounce:
		return
	if body is CharacterBody2D:
		# Bounce character upwards
		body.velocity.y = bounce_force
		animated_sprite.play("jump")
		can_bounce = false
		await animated_sprite.animation_finished
		animated_sprite.play("idle")
		can_bounce = true
