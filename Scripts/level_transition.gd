extends Area2D

@export_file("*.tscn") var target_scene_path: String = ""
@export var prompt_text: String = "NEXT WORLD"

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var label: Label = $Label
var triggered: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	if label:
		label.text = prompt_text


func _on_body_entered(body: Node2D) -> void:
	if triggered or target_scene_path == "":
		return
	if body is CharacterBody2D:
		triggered = true
		if animated_sprite and animated_sprite.sprite_frames.has_animation("flag_out"):
			animated_sprite.play("flag_out")
		await get_tree().create_timer(0.4).timeout
		if get_node_or_null("/root/GameManager"):
			get_node("/root/GameManager").change_to_world(target_scene_path)
		else:
			get_tree().change_scene_to_file(target_scene_path)
