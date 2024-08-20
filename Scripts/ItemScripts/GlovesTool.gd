extends ToolItem
class_name GlovesTool

export (String) var player_use_animation = "Kneel"
export (String) var player_use_animation_miss = "Kneel"


func get_use_animations():
	player_use_animations = [player_use_animation, player_use_animation_miss]
	return player_use_animations
