extends Node2D
class_name Level

@export var player: Player

func _ready() -> void:
	player.get_node("Texture").game_over.connect(on_game_over)
	
func on_game_over() -> void:
	get_tree().reload_current_scene()
