extends InteractableObject

tool

var species : Resource
export var species_override : Resource = null
export (int) var growth_stage_override = 1
# Stage override ranges: beans/tomatoes 1-7 frames, berry bushes 6 frames, all else 5 frames.

var light_level : float = 1.0
var weather_shade_level : float = 1.0
var rng = RandomNumberGenerator.new()

onready var spread_raycast = $RayCast2DSpread
onready var breed_raycast = $RayCast2DBreed
onready var interactable_collision_shape = $Area2DInteractable/CollisionShape2D
onready var plant_collision_area = $Area2DPlant
onready var watered_effect_particles = $WateredEffect

const grass_step_effect_scene = preload("res://Scenes/Effects/GrassStepEffect.tscn")

func _ready():
	rng.randomize()
	sprite.material = sprite.material.duplicate()
	if species_override != null:
		initialize_override(species_override)

func player_interacted(player):
	
	if species.harvestable:
		harvested(0.0)

func initialize(crop_species : FlowerSpecies):
	species = crop_species.duplicate()
	sprite.texture = species.spritesheet
	sprite.offset = species.sprite_offset
	sprite.hframes = crop_species.growth_stages
	watered_effect_particles.process_material = load(species.watered_particle_effect_curve[species.growth_stage - 1][0]).duplicate()
	watered_effect_particles.position = species.watered_particle_effect_curve[species.growth_stage - 1][1]

func initialize_override(flower_species : FlowerSpecies):
	species = flower_species.duplicate()
	species.growth_stage = growth_stage_override
	
	sprite.hframes = species.growth_stages
	sprite.texture = species.spritesheet
	sprite.offset = species.sprite_offset
	sprite.frame = species.growth_stage - 1

	watered_effect_particles.process_material = load(species.watered_particle_effect_curve[species.growth_stage - 1][0]).duplicate()
	watered_effect_particles.position = species.watered_particle_effect_curve[species.growth_stage - 1][1]
	
	if species.growth_stage >= species.mature_stage:
		maturity_reached()
	
	if species.growth_stage == species.growth_stages:
		flower_matured()

func advance_day():
	advance_watering()
	if species.mature:
		if species.flowering && !species.harvestable:
			flower_grow()
		else:
			spread_check()
	else:
		grow()

func grow():
	var watered_percent_buff = 1 / (100 - abs(species.current_water_level - species.optimal_watering_curve[species.growth_stage - 1]))

	var light_growth_buff = 0.0
	if species.sun_shade == species.SunShade.SUN:
		light_growth_buff = 0.8 - 0.15 * (species.shade_tier + weather_shade_level)
	elif species.sun_shade == species.SunShade.SHADE:
		light_growth_buff = 0.5 + 0.2 * (species.shade_tier  + weather_shade_level)
	
	species.growth_progress_to_next_stage += species.base_growth_rate + light_growth_buff + watered_percent_buff * (species.watered_growth_acceleration_curve[species.growth_stage - 1])
	if species.growth_progress_to_next_stage >= species.growth_curve[species.growth_stage - 1]:
		grow_to_next_stage()

func flower_grow():
	species.growth_progress_to_next_stage += species.flower_growth_rate + int(species.watered) * (species.watered_growth_acceleration_curve[species.growth_stage - 1])
	if species.growth_progress_to_next_stage >= species.growth_curve[species.growth_stage - 1]:
		grow_flower_to_next_stage()

func advance_watering():
	var water_target_percent = clamp(1.0 - (abs(species.current_water_level - species.optimal_watering_curve[species.growth_stage - 1]) / species.optimal_watering_curve[species.growth_stage - 1]), 0.0, 1.0)
	var watered_quality_improvement = water_target_percent * species.watered_quality_improvement
	if watered_quality_improvement != 0:
		improve_quality(watered_quality_improvement)
	
	species.current_water_level *= species.daily_water_retention
	if species.current_water_level <= 5.0:
		species.current_water_level = 0
		species.watered = false
		watered_effect_particles.emitting = false
		watered_effect_particles.visible = false

func grow_to_next_stage():
	species.growth_stage += 1
	sprite.frame = species.growth_stage - 1
	species.growth_progress_to_next_stage = 0.0
	
	species.pruned = false
	
	if species.growth_stage == species.mature_stage:
		maturity_reached()

func grow_flower_to_next_stage():
	species.growth_stage += 1
	sprite.frame += 1
	species.growth_progress_to_next_stage = 0.0
	
	species.pruned = false

	watered_effect_particles.process_material = load(species.watered_particle_effect_curve[species.growth_stage - 1][0]).duplicate()
	
	if species.growth_stage == species.growth_stages:
		flower_matured()

func flower_matured():
	species.harvestable = true
	interactable_collision_shape.disabled = false

func harvested(harvest_mod):
	improve_quality(harvest_mod)
	
	generate_flower()
	flower_harvest()
	
	spawn_grass_effect()


func spread_check():
	var spread = rng.randf_range(0.0,1.0)
	if spread <= species.random_spread_chance_current:
		spread()
		species.random_spread_chance_current = species.random_spread_chance_base
	else: species.random_spread_chance_current *= 2.0

func spread():
	var plant_location
	var cast_direction = rng.randi_range(0,7)
	spread_raycast.cast_to = species.spread_locations[cast_direction]
	spread_raycast.force_raycast_update()
	cast_direction = species.spread_locations[cast_direction]
	
	if spread_raycast.get_collider() == null:
		
		var bred_flower = breed_check()
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		plant_location = get_global_position() + cast_direction * 2
		var new_flower_scene = load(species.flower_object_path)
		var new_flower = new_flower_scene.instance()
		get_tree().current_scene.current_scene.ysort.flowers.add_child(new_flower)
		new_flower.set_global_position(plant_location)
		
		if bred_flower != null:
			new_flower.flower_bred(bred_flower, self)


func breed_check():
	rng.randomize()
	
	var breeding_flowers = []
	
	for breeding_location in species.breed_locations:
		breed_raycast.cast_to = breeding_location
		breed_raycast.force_raycast_update()
	
		var bred_flower = breed_raycast.get_collider()
	
		if bred_flower != null:
			
			if bred_flower.has_method("flower_bred"):
				if bred_flower.species.name == species.name:
					breeding_flowers.append(breed_raycast.get_collider())
	
	var bred_flower = null
	
	if breeding_flowers.size() != 0:
		bred_flower = breeding_flowers[rng.randi_range(0, breeding_flowers.size() - 1)]
	
	return bred_flower

func flower_bred(bred_parent_dad, bred_parent_mom):
	z_index = 5
	
	for i in range(5):
		var color_dad = bred_parent_dad.sprite.material.get_shader_param("replace_" + String(i + 1))
		var color_mom = bred_parent_mom.sprite.material.get_shader_param("replace_" + String(i + 1))
		
		if color_dad.is_equal_approx(color_mom):
			break
		
		var new_color = color_dad
		new_color.s = (color_dad.s + color_mom.s) / 2
		new_color.v = (color_dad.v + color_mom.v) / 2
		
		var h_diff = abs(color_dad.h - color_mom.h)
		if h_diff > 0.5:
			h_diff = 1.0 - h_diff
			h_diff = h_diff/2
			h_diff = h_diff * (i * 0.15) + 0.05
			if new_color.h > color_mom.h:
				new_color.h += h_diff
				if new_color.h > 1.0:
					new_color.h -= 1.0
			else:
				new_color.h -= h_diff
				if new_color.h < 0.0:
					new_color.h += 1.0
		else:
			h_diff = h_diff/2
			h_diff = h_diff * (i * 0.15) + 0.05
			if new_color.h > color_mom.h:
				new_color.h -= h_diff
			else:
				new_color.h += h_diff

		sprite.material.set_shader_param("replace_" + String(i + 1), new_color)

func improve_quality(quality_improvement):
	species.quality += quality_improvement
	print("crop_quality improved to:", + species.quality)

func pruned(growth_extension, quality_improvement):

	if species.pruned or species.growth_stage == 0:
		return

	species.pruned = true
	species.prune_count += 1
	spawn_grass_effect()
	species.growth_progress_to_next_stage -= growth_extension
	improve_quality(quality_improvement)


func flower_harvest():
	species.growth_stage = species.mature_stage
	sprite.frame = species.growth_stage - 1
	species.harvestable = false
	species.harvest_count += 1
	interactable_collision_shape.disabled = true

func generate_flower():
	var flower_item = load(species.flower_item_path).duplicate()
	flower_item.improve_quality(species.quality)
	print ("flower quality:", + flower_item.quality)
	species.quality = 0.0
	
	get_tree().current_scene.add_item(flower_item, get_global_position() + Vector2(8,8))
	

func maturity_reached():
	species.mature = true
	species.flowering = true

func watered(watering_value):
	watered_effect_particles.amount = watering_value
	species.current_water_level = watering_value
	species.watered = true	
	watered_effect_particles.visible = true

	rng.randomize()
	yield(get_tree().create_timer(rng.randf_range(0,1.5)), 'timeout')
	watered_effect_particles.emitting = true

func spawn_grass_effect():
	var grass_step_effect = grass_step_effect_scene.instance()
	grass_step_effect.position = position
	get_tree().current_scene.add_child(grass_step_effect)

func chopped(cut_tier):
	yield(get_tree().create_timer(0.3), "timeout")
	if species.harvestable:
		harvested(-10.0)
	spawn_grass_effect()
	self_remove()

func shade_entered(shade_mod):
	species.shade_tier = clamp(species.shade_tier + 1, 0, 10)
	light_level = clamp(light_level - shade_mod, 0, 1)
	sprite.modulate = Color(light_level, light_level, light_level)

func shade_exited(shade_mod):
	species.shade_tier = clamp(species.shade_tier - 1, 0, 10)
	light_level = clamp(light_level + shade_mod, 0, 1)
	sprite.modulate = Color(light_level, light_level, light_level)

func fertilized():
	pass

func RGBRotate(color, degrees):
	var matrix = [[1,0,0],[0,1,0],[0,0,1]]
	var cosA = cos(deg2rad(degrees))
	var sinA = sin(deg2rad(degrees))
	
	matrix[0][0] = cosA + (1.0 - cosA) / 3.0
	matrix[0][1] = 1.0/3.0 * (1.0 - cosA) - sqrt(1.0/3.0) * sinA
	matrix[0][2] = 1.0/3.0 * (1.0 - cosA) + sqrt(1.0/3.0) * sinA
	matrix[1][0] = 1.0/3.0 * (1.0 - cosA) + sqrt(1.0/3.0) * sinA
	matrix[1][1] = cosA + 1.0/3.0 * (1.0 - cosA)
	matrix[1][2] = 1.0/3.0 * (1.0 - cosA) - sqrt(1.0/3.0) * sinA
	matrix[2][0] = 1.0/3.0 * (1.0 - cosA) - sqrt(1.0/3.0) * sinA
	matrix[2][1] = 1.0/3.0 * (1.0 - cosA) + sqrt(1.0/3.0) * sinA
	matrix[2][2] = cosA + 1.0/3.0 * (1.0 - cosA)
	
	var r = color.r8
	var g = color.g8
	var b = color.b8
	
	var rx = r * matrix[0][0] + g * matrix[0][1] + b * matrix[0][2]
	var gx = r * matrix[1][0] + g * matrix[1][1] + b * matrix[1][2]
	var bx = r * matrix[2][0] + g * matrix[2][1] + b * matrix[2][2]

	return Color8(color_clamp(rx), color_clamp(gx), color_clamp(bx), 255)

func color_clamp(v):
	if v < 0:
		return 0
	if v > 255:
		return 255
	return int(v + 0.5)

func _on_Button_pressed():
	var color_1 = sprite.material.get_shader_param("replace_1")
	var color_2 = sprite.material.get_shader_param("replace_2")
	var color_3 = sprite.material.get_shader_param("replace_3")
	var color_4 = sprite.material.get_shader_param("replace_4")
	var color_5 = sprite.material.get_shader_param("replace_5")
	
	sprite.material.set_shader_param("replace_1", RGBRotate(color_1, 10))
	sprite.material.set_shader_param("replace_2", RGBRotate(color_2, 10))
	sprite.material.set_shader_param("replace_3", RGBRotate(color_3, 10))
	sprite.material.set_shader_param("replace_4", RGBRotate(color_4, 10))
	sprite.material.set_shader_param("replace_5", RGBRotate(color_5, 10))


func _on_Area2DPlayer_body_entered(body):

	if species.growth_stage <= 2:
		return
	
	yield(get_tree().create_timer(0.1), "timeout")
	var grass_step_effect = grass_step_effect_scene.instance()
	grass_step_effect.position = position
	get_tree().current_scene.add_child(grass_step_effect)


func _on_Area2DPlayer_body_exited(body):
	pass

func weather_changed(weather_precipitation, weather_light):
	if weather_precipitation != 0:
		var new_watered_level = clamp(species.current_water_level + weather_precipitation,0.0,100)
		watered(new_watered_level)
	weather_shade_level = (1.0 - weather_light)/0.1
