extends ToolItem
class_name PickTool

export (int) var pick_tier = 0
const dust_effect_scene = preload("res://Scenes/Effects/LandingDustEffect.tscn")

export (String) var player_use_animation = "Chop"
export (String) var player_use_animation_miss = "Chop"


func used(player, current_scene):
	
	var colliding_object = get_pickable_object(player)
	print(player.get_global_position())
	print(player.get_position())

	if colliding_object != null:
		colliding_object.picked(pick_tier)
		return true

	return false

func get_pickable_object(player):
	var colliding_object = null
	var colliding_array = player.get_all_colliders(true)
	
	if colliding_array.size() != 0:
		for object in colliding_array:
			print(object)
			if object.has_method("picked"):
				colliding_object = object
	
	return colliding_object

func get_use_animations():
	player_use_animations = [player_use_animation, player_use_animation_miss]
	return player_use_animations
