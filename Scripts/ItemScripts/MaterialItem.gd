extends Item
class_name MaterialItem

export (String) var player_use_animation = "Eat"
export (String) var player_use_animation_miss = "Eat"


func get_use_animations():
	player_use_animations = [player_use_animation, player_use_animation_miss]
	return player_use_animations
