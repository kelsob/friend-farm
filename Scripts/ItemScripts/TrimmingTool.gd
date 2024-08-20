extends ToolItem
class_name TrimmingTool

export (float) var growth_extension = 1.0
export (float) var quality_improvement = 0.1

export (String) var player_use_animation = "Kneel"
export (String) var player_use_animation_miss = "Kneel"

func used(player, current_scene):
	var trim_position = get_tile_position(player)
	
	player.move_colliders(player.facing_vector)
	
	var plant_colliders = player.plant_collider.get_overlapping_areas()
	var plant_collider = null    
	
	if plant_colliders.size() != 0:
		plant_collider = plant_colliders[0]
		if plant_collider.has_method("pruned"):
			print (plant_collider.species.pruned)
			if !plant_collider.species.pruned and !plant_collider.species.harvestable and plant_collider.species.growth_stage != 0:
				plant_collider.pruned(growth_extension, quality_improvement)
				player.act(player_use_animation)
				print('plant pruned')
				return true
			else:
				player.act(player_use_animation_miss)
				return false
		else:
			player.act(player_use_animation_miss)
			return false
	else:
		player.act(player_use_animation_miss)
		print('plant not found')
		return false


func get_use_animations():
	player_use_animations = [player_use_animation, player_use_animation_miss]
	return player_use_animations

