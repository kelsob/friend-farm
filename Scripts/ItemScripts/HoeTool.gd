extends ToolItem
class_name HoeTool

const dust_effect_scene = preload("res://Scenes/Effects/LandingDustEffect.tscn")
const TILLED_EARTH_TILE_INDEX = 10

export (String) var player_use_animation = "Chop"
export (String) var player_use_animation_miss = "Chop"

func used(player, current_scene):
	var player_colliding = player.get_all_colliders(true)
	if player_colliding.size() != 0:
		return false
	
	var till_position = get_tile_position(player)
	print(till_position)
	
	if current_scene.tilled_earth_tilemap.get_cellv(till_position / 16) == TILLED_EARTH_TILE_INDEX:
		current_scene.tilled_earth_tilemap.set_cellv(till_position / 16, -1, false, false)
		current_scene.tilled_earth_tilemap.update_dirty_quadrants()
		current_scene.tilled_earth_tilemap.update_bitmask_area(till_position / 16)
	
	else:
		current_scene.tilled_earth_tilemap.set_cellv(till_position / 16, TILLED_EARTH_TILE_INDEX, false, false)
		current_scene.tilled_earth_tilemap.update_dirty_quadrants()
		current_scene.tilled_earth_tilemap.update_bitmask_area(till_position / 16)
	
	var dust_effect = dust_effect_scene.instance()
	dust_effect.position = till_position + Vector2(0, -6)
	current_scene.add_child(dust_effect)
	
	return true


func get_use_animations():
	player_use_animations = [player_use_animation, player_use_animation_miss]
	return player_use_animations
