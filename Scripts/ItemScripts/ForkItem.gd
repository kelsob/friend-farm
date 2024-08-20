extends ToolItem
class_name ForkItem

export (String) var player_use_animation = "Swing"
export (String) var player_use_animation_miss = "Swing"


func get_use_animations():
	player_use_animations = [player_use_animation, player_use_animation_miss]
	return player_use_animations
