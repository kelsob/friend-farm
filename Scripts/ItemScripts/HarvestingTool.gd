extends ToolItem
class_name HarvestingTool

export (float) var harvest_quality_mod = 0.25

export (String) var player_use_animation = "Kneel"
export (String) var player_use_animation_miss = "Kneel"

func used(player, current_scene):
	
	var colliding_plant = get_harvestable_plant(player)

	if colliding_plant != null:
		if colliding_plant.species.harvestable:
			colliding_plant.harvested(harvest_quality_mod)
			return true

	return false

func get_harvestable_plant(player):
	var colliding_plant = null
	var colliding_plant_array = player.plant_collider.get_overlapping_areas()
	if colliding_plant_array.size() != 0:
		for plant in colliding_plant_array:
			if plant.has_method("harvested"):
				colliding_plant = plant
	
	return colliding_plant


func get_use_animations():
	player_use_animations = [player_use_animation, player_use_animation_miss]
	return player_use_animations
