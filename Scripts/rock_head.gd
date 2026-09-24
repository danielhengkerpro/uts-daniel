extends Node2D
class_name RockHead

@export var fall_distance: float = 128.0
@export var wait_top_time: float = 1.6
@export var fall_speed: float = 380.0
@export var wait_bottom_time: float = 0.8
@export var rise_speed: float = 65.0
@export var initial_delay: float = 0.0

@onready var animated_sprite: AnimatedSprite2D = $Body/AnimatedSprite2D
@onready var body: AnimatableBody2D = $Body
@onready var hazard_area: Area2D = $Body/HazardArea

var start_y: float = 0.0


func _ready() -> void:
	start_y = body.position.y
	if hazard_area:
		hazard_area.body_entered.connect(_on_hazard_entered)
	_run_slam_cycle()


func _on_hazard_entered(other_body: Node2D) -> void:
	if other_body is CharacterBody2D and other_body.has_method("die_and_respawn"):
		other_body.die_and_respawn()


func _run_slam_cycle() -> void:
	if initial_delay > 0.0:
		await get_tree().create_timer(initial_delay).timeout
	
	while is_inside_tree():
		# 1. Wait at ceiling with blinking
		if animated_sprite:
			animated_sprite.play("blink")
		await get_tree().create_timer(wait_top_time).timeout
		if not is_inside_tree():
			return
		
		# 2. Fast slam downwards
		if animated_sprite:
			animated_sprite.play("idle")
		var target_y = start_y + fall_distance
		var fall_duration = fall_distance / fall_speed
		var tween_slam = create_tween()
		tween_slam.tween_property(body, "position:y", target_y, fall_duration).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
		await tween_slam.finished
		if not is_inside_tree():
			return
		
		# 3. Bottom impact
		if animated_sprite:
			animated_sprite.play("bottom_hit")
		await get_tree().create_timer(wait_bottom_time).timeout
		if not is_inside_tree():
			return
		
		# 4. Slowly rise back up
		if animated_sprite:
			animated_sprite.play("idle")
		var rise_duration = fall_distance / rise_speed
		var tween_rise = create_tween()
		tween_rise.tween_property(body, "position:y", start_y, rise_duration).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR)
		await tween_rise.finished
