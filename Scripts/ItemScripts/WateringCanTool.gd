extends ToolItem
class_name WateringCanTool

export (float) var capacity = 100
var stored_quantity = 100
export (float) var use_rate = 5
export (float) var fill_rate = 20

var minigame_scene = load("res://Scenes/UI/WateringMinigame.tscn")
var colliding_plant
var player

signal stored_quantity_changed(current_capacity)
signal capacity_changed(max_capacity)
signal stored_quantity_expended(quantity)

export (String) var player_use_animation = "KneelStay"
export (String) var player_use_animation_miss = "Kneel"

func used(player_init, current_scene):

	player = player_init
	player.move_colliders(player.facing_vector)
	var water_position = get_tile_position(player)
	
	var colliding_water = player.water_collider.get_overlapping_bodies()
	if colliding_water.size() != 0:
		water_refilled()
		return false
	
	if stored_quantity <= 0:
		return false
	
	var colliding_objects = player.interactable_collider.get_overlapping_areas()
	var colliding_object
	if colliding_objects.size() != 0:
		colliding_object = colliding_objects[0]
	
	if colliding_object!= null:
		if colliding_object.get_parent().has_method('picked_up'):
			return false
	
	var colliding_plant_array = player.plant_collider.get_overlapping_areas()
	if colliding_plant_array.size() != 0:
		colliding_plant = colliding_plant_array[0]
	else:
		colliding_plant = null
	
	# Implement Watering Minigame
	var minigame_target = null
	var initial_water_level = 0
	if colliding_plant != null:
		if colliding_plant.species.harvestable:
			return false
		
		print(colliding_plant.species.growth_stage - 1)
		minigame_target = colliding_plant.species.optimal_watering_curve[colliding_plant.species.growth_stage - 1]
		initial_water_level = colliding_plant.species.current_water_level

	var minigame = minigame_scene.instance()
	current_scene.ysort.add_child(minigame)
	minigame.initialize(minigame_target, initial_water_level, stored_quantity, water_position, use_rate)
	
	minigame.connect('minigame_completed', self, '_on_minigame_completed')
	
	#Disable Player Input

	
	minigame.start_minigame()
	player.spawn_watering_can_effect()
	return true

func water_refilled():
	stored_quantity = capacity
	emit_signal('stored_quantity_changed', stored_quantity)
	

func _on_minigame_completed(watering_value, change):
	stored_quantity -= change
	stored_quantity = clamp(stored_quantity, 0, capacity)
	
	if colliding_plant != null:
		colliding_plant.watered(watering_value)
	
	emit_signal('stored_quantity_changed', stored_quantity)
	player._on_action_complete()
	player.clear_watering_can_effect()


func get_use_animations():
	player_use_animations = [player_use_animation, player_use_animation_miss]
	return player_use_animations
