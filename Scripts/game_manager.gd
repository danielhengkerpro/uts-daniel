extends Node

signal score_updated(new_score: int)

var total_score: int = 0
var current_world: int = 1


func add_score(amount: int) -> void:
	total_score += amount
	score_updated.emit(total_score)


func reset_game() -> void:
	total_score = 0
	current_world = 1
	score_updated.emit(total_score)


func change_to_world(scene_path: String) -> void:
	get_tree().change_scene_to_file(scene_path)
