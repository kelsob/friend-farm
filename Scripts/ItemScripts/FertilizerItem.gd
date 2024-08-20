extends Item
class_name FertilizerItem

enum AffectedStat {CROP_QUALITY, GROWTH_RATE, WATER_RETENTION, CROP_QUANTITY, SEED_QUALITY}
export (AffectedStat) var affected_stat = AffectedStat.CROP_QUALITY

export (Color) var color_modulate = Color(1,1,1)
export (float) var stat_change = 0.25
export (int) var uses = 3.0
export (String) var object_path = "res://Scenes/Environment/Miscellaneous/FertilizerObject.tscn"

const dust_effect_scene = preload("res://Scenes/Effects/LandingDustEffect.tscn")

export (String) var player_use_animation = "Kneel"
export (String) var player_use_animation_miss = "Kneel"

func used(player, current_scene):
	var usable = check_item_usability(player)

	if !usable:
		player.act(player_use_animation_miss)
		return false
	
	use_item(player, current_scene)
	return true


func check_item_usability(player):
	player.move_colliders(player.facing_vector)
	var plant_collider = player.plant_collider.get_overlapping_areas()
	
	if plant_collider.size() != 0:
		if plant_collider[0].has_method("fertilized"):
			if !plant_collider[0].species.fertilized:
				return true
			else:
				return false
		else:
			return false
	else:
		return false

func use_item(player, current_scene):
	var use_location = player.get_global_position() + player.facing_vector - player.grid_offset
	var fert_object = load(object_path)
	var fert = fert_object.instance()
	current_scene.background_objects.add_child(fert)
	fert.initialize(self)
	fert.set_global_position(use_location)

	var dust_effect = dust_effect_scene.instance()
	dust_effect.position = use_location + Vector2(0, -4)
	current_scene.add_child(dust_effect)

	reduce_quantity()


func get_use_animations():
	player_use_animations = [player_use_animation, player_use_animation_miss]
	return player_use_animations
