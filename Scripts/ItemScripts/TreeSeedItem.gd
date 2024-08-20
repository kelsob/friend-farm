extends Item
class_name TreeSeedItem

var plant_direction = Vector2(0,0)

const dust_effect_scene = preload("res://Scenes/Effects/LandingDustEffect.tscn")

export (bool) var tilled_earth_required = false
export (Resource) var tree_species
var tree_object = load('res://Scenes/Environment/Trees/TreeObject.tscn')

export (String) var player_use_animation = "Kneel"
export (String) var player_use_animation_miss = "Kneel"

func used(player, current_scene):
	var plantable = check_plantability(player)
	print(plantable)

	if !plantable:
		print(player_use_animation_miss)
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
		print (player.tilled_earth_collider.get_overlapping_bodies())
		if player.tilled_earth_collider.get_overlapping_bodies().size() == 0:
			plantable = false
	return plantable

func plant_seed(player, current_scene):
	var plant_location = player.get_global_position() + plant_direction - player.grid_offset
	var tree = tree_object.instance()
	current_scene.ysort.trees.add_child(tree)
	tree.initialize(tree_species)
	tree.set_global_position(plant_location)

	var dust_effect = dust_effect_scene.instance()
	dust_effect.position = plant_location + Vector2(0, -4)
	current_scene.add_child(dust_effect)

	reduce_quantity()

func reduce_quantity():
	if single_use:
		current_stack_size -= 1
		emit_signal("quantity_changed", self, current_stack_size)
		if current_stack_size == 0:
			emit_signal("quantity_depleted", self)


func get_use_animations():
	player_use_animations = [player_use_animation, player_use_animation_miss]
	return player_use_animations
