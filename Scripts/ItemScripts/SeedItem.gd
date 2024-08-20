extends Item
class_name SeedItem

var plant_direction = Vector2(0,0)

const dust_effect_scene = preload("res://Scenes/Effects/LandingDustEffect.tscn")

export (bool) var tilled_earth_required = false
export (Resource) var crop_species

export (String) var crop_object_path = 'res://Scenes/Objects/Plants/CropObject.tscn'

export (String) var player_use_animation = "Kneel"
export (String) var player_use_animation_miss = "Kneel"

func used(player, current_scene):
	var plantable = check_plantability(player)

	if !plantable:
		player.act(player_use_animation_miss)
		return false
	
	plant_seed(player, current_scene)
	return true

func check_plantability(player):
	var plantable = true
	
	plant_direction = Vector2(0,0)
	if player.facing_direction == player.FacingDirection.LEFT:
		plant_direction = Vector2(-16,0)
	elif player.facing_direction == player.FacingDirection.RIGHT:
		plant_direction = Vector2(16,0)
	elif player.facing_direction == player.FacingDirection.UP:
		plant_direction = Vector2(0,-16)
	elif player.facing_direction == player.FacingDirection.DOWN:
		plant_direction = Vector2(0,16)
	
	player.move_colliders(plant_direction)
	
	var player_colliding = player.get_all_colliders(true)
	if player_colliding.size() != 0:
		return false
	
	if tilled_earth_required:
		if player.tilled_earth_collider.get_overlapping_bodies().size() == 0:
			plantable = false
			print('no tilled earth')
	return plantable

func plant_seed(player, current_scene):
	
	var plant_location = player.get_global_position() + plant_direction - player.grid_offset
	var crop_object = load(crop_object_path)
	var crop = crop_object.instance()
	current_scene.ysort.plants.add_child(crop)
	crop.set_global_position(plant_location)
	crop.initialize(crop_species)

	var dust_effect = dust_effect_scene.instance()
	dust_effect.position = plant_location + Vector2(0, -4)
	current_scene.add_child(dust_effect)

	reduce_quantity()

func get_use_animations():
	player_use_animations = [player_use_animation, player_use_animation_miss]
	return player_use_animations
