extends Area2D

@export var move_distance: float = 64.0
@export var speed: float = 60.0

var start_x: float = 0.0
var direction: float = 1.0


func _ready() -> void:
	start_x = position.x
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	if move_distance > 0.0:
		position.x += direction * speed * delta
		if position.x > start_x + move_distance:
			direction = -1.0
		elif position.x < start_x:
			direction = 1.0


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and body.has_method("die_and_respawn"):
		body.die_and_respawn()
