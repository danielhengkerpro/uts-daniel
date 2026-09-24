extends Area2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
var is_triggered: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if is_triggered:
		return
	if body is CharacterBody2D:
		is_triggered = true
		animated_sprite.play("pressed")
		if body.has_method("show_win_ui"):
			body.show_win_ui()
