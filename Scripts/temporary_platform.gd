extends AnimatableBody2D
class_name TemporaryPlatform

@export var stand_time: float = 0.55
@export var reset_time: float = 2.0
@export var tilt_angle: float = 90.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var step_detector: Area2D = $StepDetector

var is_triggered: bool = false
var is_open: bool = false
var original_rotation: float = 0.0


func _ready() -> void:
	original_rotation = rotation_degrees
	if step_detector:
		step_detector.body_entered.connect(_on_step_entered)


func _on_step_entered(body: Node2D) -> void:
	if is_triggered or is_open:
		return
	if body is CharacterBody2D:
		_start_collapse_sequence()


func _start_collapse_sequence() -> void:
	is_triggered = true
	var shake_tween = create_tween()
	shake_tween.tween_property(animated_sprite, "position:y", 1.0, stand_time * 0.5)
	shake_tween.tween_property(animated_sprite, "position:y", 0.0, stand_time * 0.5)
	
	await get_tree().create_timer(stand_time).timeout
	if not is_inside_tree():
		return
	
	is_open = true
	if animated_sprite:
		animated_sprite.play("off")
	
	var open_tween = create_tween()
	open_tween.tween_property(self, "rotation_degrees", original_rotation + tilt_angle, 0.15).set_ease(Tween.EASE_IN)
	await open_tween.finished
	if not is_inside_tree():
		return
	
	if collision_shape:
		collision_shape.set_deferred("disabled", true)
	
	await get_tree().create_timer(reset_time).timeout
	if not is_inside_tree():
		return
	
	var restore_tween = create_tween()
	restore_tween.tween_property(self, "rotation_degrees", original_rotation, 0.25).set_ease(Tween.EASE_OUT)
	await restore_tween.finished
	if not is_inside_tree():
		return
	
	if collision_shape:
		collision_shape.set_deferred("disabled", false)
	if animated_sprite:
		animated_sprite.play("on")
	
	is_open = false
	is_triggered = false
