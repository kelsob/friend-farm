extends ToolItem
class_name CuttingTool

export (int) var cut_tier = 0

export (String) var player_use_animation = "Chop"
export (String) var player_use_animation_miss = "Chop"

func used(player, current_scene):
	
	var colliding_plant = get_choppable_plant(player)

	if colliding_plant != null:
		colliding_plant.chopped(cut_tier)
		return true

	return false

func get_choppable_plant(player):
	var colliding_plant = null
	var colliding_plant_array = player.interactable_collider.get_overlapping_areas()
	if colliding_plant_array.size() != 0:
		for plant in colliding_plant_array:
			if plant.has_method("chopped"):
				colliding_plant = plant
	
	return colliding_plant

func get_use_animations():
	player_use_animations = [player_use_animation, player_use_animation_miss]
	return player_use_animations
