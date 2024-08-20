extends InteractableObject
tool

var species : Resource
export var species_override : Resource = null
export (int) var growth_stage_override = 1
# Stage override ranges: beans/tomatoes 1-7 frames, berry bushes 6 frames, all else 5 frames.

var light_level : float = 1.0
var weather_shade_level : float = 1.0
var fertilizer_object = null

onready var interactable_collision_shape = $Area2DInteractable/CollisionShape2D
onready var watered_effect_particles = $WateredEffect

export (float) var fertilizer_growth_buff = 0.0
export (float) var fertilizer_quality_buff = 0.0
export (float) var fertilizer_water_retention_buff = 0.0
export (float) var fertilizer_quantity_buff = 0.0
export (float) var fertilizer_seed_quality_buff = 0.0

const grass_step_effect_scene = preload("res://Scenes/Effects/GrassStepEffect.tscn")
const sprite_pickup_scene = preload("res://Scenes/UI/ItemPickupSprite.tscn")

var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	if species_override != null:
		initialize_override(species_override)

func player_interacted(player_init):
	player = player_init
	
	if species.seed_harvestable:
		seed_harvested(0.0)
	
	elif species.harvestable:
		harvested(0.0)

func initialize(crop_species : CropSpecies):
	species = crop_species.duplicate()
	sprite.texture = species.plant_spritesheet
	sprite.offset = species.sprite_offset
	sprite.hframes = crop_species.growth_stages
	sprite.frame = crop_species.growth_stage - 1
	watered_effect_particles.process_material = load(species.watered_particle_effect_curve[species.growth_stage - 1][0]).duplicate()
	watered_effect_particles.position = species.watered_particle_effect_curve[species.growth_stage - 1][1]
	create_pathfindinding_obstacle()

func initialize_override(crop_species : CropSpecies):
	species = crop_species.duplicate()
	species.growth_stage = growth_stage_override
	
	sprite.hframes = species.growth_stages
	sprite.texture = species.plant_spritesheet
	sprite.offset = species.sprite_offset
	sprite.frame = species.growth_stage - 1

	watered_effect_particles.process_material = load(species.watered_particle_effect_curve[species.growth_stage - 1][0]).duplicate()
	watered_effect_particles.position = species.watered_particle_effect_curve[species.growth_stage - 1][1]
	
	if species.growth_stage >= species.mature_stage:
		maturity_reached()
	
	if species.growth_stage == species.growth_stages:
		fruit_matured()

func advance_day():
	advance_watering()
	if species.mature:
		if species.fruiting && !species.harvestable:
			fruit_grow()
		elif species.harvestable:
			seed_grow()
	else:
		grow()

func grow():
	var watered_percent_buff = 1 / (100 - abs(species.current_water_level - species.optimal_watering_curve[species.growth_stage - 1]))
	
	var light_growth_buff = 0.0
	if species.sun_shade == species.SunShade.SUN:
		light_growth_buff = 0.8 - 0.15 * (species.shade_tier + weather_shade_level)
	elif species.sun_shade == species.SunShade.SHADE:
		light_growth_buff = 0.5 + 0.2 * (species.shade_tier  + weather_shade_level)
	
	species.growth_progress_to_next_stage += light_growth_buff * (species.base_growth_rate + fertilizer_growth_buff +  watered_percent_buff * (species.watered_growth_acceleration_curve[species.growth_stage - 1]))
	if species.growth_progress_to_next_stage >= species.growth_curve[species.growth_stage - 1]:
		grow_to_next_stage()

func fruit_grow():
	species.growth_progress_to_next_stage += species.fruit_growth_rate + int(species.watered) * (species.watered_growth_acceleration_curve[species.growth_stage - 1])
	if species.growth_progress_to_next_stage >= species.growth_curve[species.growth_stage - 1]:
		grow_fruit_to_next_stage()

func seed_grow():
	species.seed_growth_progression += 1
	if species.seed_growth_progression >= species.seed_growth_days:
		species.seed_harvestable = true

func advance_watering():
	
	var water_target_percent = clamp(1.0 - (abs(species.current_water_level - species.optimal_watering_curve[species.growth_stage - 1]) / species.optimal_watering_curve[species.growth_stage - 1]), 0.0, 1.0)
	var watered_quality_improvement = water_target_percent * species.watered_quality_improvement
	if watered_quality_improvement != 0:
		improve_quality(watered_quality_improvement)
	
	species.current_water_level = clamp(species.current_water_level * (species.daily_water_retention + fertilizer_water_retention_buff), 0, 100)
	if species.current_water_level <= 5.0:
		species.current_water_level = 0
		species.watered = false
		watered_effect_particles.emitting = false
		watered_effect_particles.visible = false

func grow_to_next_stage():

	species.pruned = false
	
	species.growth_stage += 1
	sprite.frame = species.growth_stage - 1
	species.growth_progress_to_next_stage = 0.0
	
	watered_effect_particles.process_material = load(species.watered_particle_effect_curve[species.growth_stage - 1][0]).duplicate()
	
	if species.growth_stage == species.mature_stage:
		maturity_reached()

func grow_fruit_to_next_stage():
	species.pruned = false
	
	species.growth_stage += 1
	sprite.frame += 1
	species.growth_progress_to_next_stage = 0.0
	
	if species.growth_stage == species.growth_stages:
		fruit_matured()

func fruit_matured():
	species.harvestable = true
	interactable_collision_shape.disabled = false

func seed_harvested(harvest_mod):
	improve_quality(harvest_mod)
	generate_seed()
	species.seed_harvestable = false
	species.harvestable = false
	species.seed_growth_progression = 0
	species.growth_stage = species.mature_stage
	sprite.frame = species.growth_stage - 1
	interactable_collision_shape.disabled = false
	if !species.multiharvestable:
		self_remove()

func generate_seed():
	var seed_item = load(species.seed_item_path).duplicate()
	seed_item.improve_quality(species.quality * (0.5 + fertilizer_seed_quality_buff))
	print ("seed quality:", + seed_item.quality)
	species.quality = 0
	var seed_generation_count = 1
	for seed_generation_chance in species.extra_seed_generation_chances:
		if rng.randf_range(0.0, 1.0) <= seed_generation_chance:
			seed_generation_count += 1
	
	seed_item.current_stack_size = seed_generation_count
	
	check_fertilizer()
	
	get_tree().current_scene.add_item(seed_item, get_global_position() + Vector2(8,8))

func harvested(harvest_mod):
	improve_quality(harvest_mod)
	generate_fruit()
	
	if species.multiharvestable:
		fruit_harvest()
	else:
		plant_harvest()
	
	spawn_grass_effect()

func fruit_harvest():
	species.harvestable = false
	species.growth_stage = species.mature_stage
	sprite.frame = species.growth_stage - 1
	species.harvest_count += 1
	interactable_collision_shape.disabled = true

func plant_harvest():
	self_remove()

func generate_fruit():
	
	var crop_item = load(species.crop_item_path).duplicate()
	crop_item.improve_quality(species.quality + fertilizer_quality_buff)
	species.quality = 0.0
	
	check_fertilizer()
	
	get_tree().current_scene.add_item(crop_item, get_global_position() + Vector2(8,8))


func maturity_reached():
	species.mature = true
	if species.multiharvestable:
		species.fruiting = true
	elif !species.multiharvestable:
		species.fruiting = false
		species.harvestable = true
		interactable_collision_shape.disabled = false

func watered(watering_value):
	watered_effect_particles.amount = watering_value
	species.current_water_level = watering_value
	species.watered = true	
	watered_effect_particles.visible = true	

	rng.randomize()
	yield(get_tree().create_timer(rng.randf_range(0,1.5)), 'timeout')
	if is_instance_valid(self):
		watered_effect_particles.emitting = true




func chopped(cut_tier):
	if species.harvestable:
		harvested(-10.0)
	else:
		spawn_grass_effect()
		self_remove()

func pruned(growth_extension, quality_improvement):

	if species.pruned or species.growth_stage == 0:
		return

	species.pruned = true
	species.prune_count += 1
	spawn_grass_effect()
	species.growth_progress_to_next_stage -= growth_extension
	improve_quality(quality_improvement)

func spawn_grass_effect():
	var grass_step_effect = grass_step_effect_scene.instance()
	grass_step_effect.position = position
	get_tree().current_scene.add_child(grass_step_effect)

func improve_quality(quality_improvement):
	species.quality += quality_improvement
	print("crop_quality improved to:", + species.quality)

func shade_entered(shade_mod):
	shade_mod *= 0.5
	species.shade_tier = clamp(species.shade_tier + 1, 0, 10)
	light_level = clamp(light_level - shade_mod, 0, 1)
	sprite.modulate = Color(light_level, light_level, light_level)

func shade_exited(shade_mod):
	shade_mod*= 0.5
	species.shade_tier = clamp(species.shade_tier - 1, 0, 10)
	light_level = clamp(light_level + shade_mod, 0, 1)
	sprite.modulate = Color(light_level, light_level, light_level)

func check_fertilizer():
	if fertilizer_object != null:
		fertilizer_object.fertilizer_used()
		if fertilizer_object.fertilizer_item.uses == 0:
			unfertilized()

func fertilized(fertilizer):
	species.fertilized = true
	fertilizer_object = fertilizer
	match fertilizer_object.fertilizer_item.affected_stat:
		0:
			fertilizer_quality_buff = fertilizer_object.fertilizer_item.stat_change
		1:
			fertilizer_growth_buff = fertilizer_object.fertilizer_item.stat_change
		2:
			fertilizer_water_retention_buff = fertilizer_object.fertilizer_item.stat_change
		3:
			fertilizer_quantity_buff = fertilizer_object.fertilizer_item.stat_change
		4:
			fertilizer_seed_quality_buff = fertilizer_object.fertilizer_item.stat_change

func unfertilized():
	species.fertilized = false
	fertilizer_object.exhausted()
	fertilizer_object == null
	
	fertilizer_quality_buff = 0.0
	fertilizer_growth_buff = 0.0
	fertilizer_water_retention_buff = 0.0
	fertilizer_quantity_buff = 0.0
	fertilizer_seed_quality_buff = 0.0

func weather_changed(weather_precipitation, weather_light):
	if weather_precipitation != 0:
		var new_watered_level = clamp(species.current_water_level + weather_precipitation,0.0,100)
		watered(new_watered_level)
	weather_shade_level = (1.0 - weather_light)/0.1
