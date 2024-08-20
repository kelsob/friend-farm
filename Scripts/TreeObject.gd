extends InteractableObject
tool
var species : Resource
export var species_override : Resource = null
export (int) var growth_stage_override = 1
export (bool) var stump_override = false
# Stage override ranges: beans/tomatoes 1-7 frames, berry bushes 6 frames, all else 5 frames.

onready var watered_effect_particles = $WateredEffect
onready var sprite_shadow = $SpriteShadow
onready var ray_cast_growth = $RayCast2DGrowth
onready var interactable_collision_shape = $Area2DInteractable/CollisionShape2D
onready var shade_collision_area = $Area2DShade

export var stump : bool = false

enum State {IDLE, SHAKING}
var state = State.IDLE

export var shake_amplitude_initial : float = 1.0
export var shake_amplitude : float = 1.0
var shake_duration : float = 0.0
var shake_speed : float = 36.0

const grass_step_effect_scene = preload("res://Scenes/Effects/GrassStepEffect.tscn")

func _ready():
	
	if species_override != null:
		initialize_override(species_override)

func advance_day():
	if stump:
		return
	replenish_wood()
	if species.mature:
		if species.fruiting && !species.harvestable:
			fruit_grow()
	else:
		grow()
		advance_watering()

func grow():
	var watered_percent_buff = 1 / (100 - abs(species.current_water_level - species.optimal_watering_curve[species.growth_stage - 1]))
	species.growth_progress_to_next_stage += species.base_growth_rate + watered_percent_buff * (species.watered_growth_acceleration_curve[species.growth_stage - 1])
	if species.growth_progress_to_next_stage >= species.growth_curve[species.growth_stage - 1]:
		if check_growth_area():
			grow_to_next_stage()

func replenish_wood():
	if species.current_wood_stored == species.wood_quantity_stored_curve[species.growth_stage - 1]:
		return
	species.current_wood_regeneration += species.wood_regeneration_rate + int(species.watered) * species.watered_growth_acceleration_curve[species.growth_stage - 1]
	if species.current_wood_regeneration >= 1.0:
		species.current_wood_stored += int(round(species.current_wood_regeneration))
	species.current_wood_regeneration = 0.0

func advance_watering():
	species.current_water_level *= species.daily_water_retention
	if species.current_water_level <= 5.0:
		species.current_water_level = 0
		species.watered = false
		watered_effect_particles.emitting = false
		watered_effect_particles.visible = false

func grow_to_next_stage():
	update_shade_levels()
	update_collision_shapes()
	
	species.growth_stage += 1
	species.current_wood_stored = species.wood_quantity_stored_curve[species.growth_stage - 1]
	
	if species.shade_buff_provided[species.growth_stage - 1] != 0:
		species.providing_shade = true
	sprite.frame_coords.x= species.growth_stage - 1
	sprite_shadow.frame_coords.x= species.growth_stage - 1

	watered_effect_particles.process_material = load(species.watered_particle_effect_curve[species.growth_stage - 1][0])
	species.growth_progress_to_next_stage = 0.0
	
	if species.growth_stage == species.growth_stages:
		maturity_reached()

func update_shade_levels():
	var shade_change = species.shade_mod * abs(species.shade_buff_provided[species.growth_stage] - species.shade_buff_provided[species.growth_stage - 1])
	for area in shade_collision_area.get_overlapping_areas():
		if area.get_parent().has_method("shade_entered"):
			area.get_parent().shade_entered(shade_change)

func remove_shaded_levels():
	var shade_change = species.shade_mod * species.shade_buff_provided[species.growth_stage - 1]
	for area in shade_collision_area.get_overlapping_areas():
		if area.get_parent().has_method("shade_exited"):
			area.get_parent().shade_exited(shade_change)

func update_collision_shapes():
	collision_shape_obstruction.scale = species.tree_collision_curve[species.growth_stage - 1]
	interactable_collision_shape.scale = species.tree_collision_curve[species.growth_stage - 1]
	
	var collision_position = Vector2(8,8)
	collision_position.x = collision_shape_obstruction.scale.x * 8
	collision_position.y = - 8 * collision_shape_obstruction.scale.y + 16
	collision_shape_obstruction.position = collision_position
	interactable_collision_shape.position = collision_position

func check_growth_area():
	var colliding = false
	for i in range(species.growth_ray_cast_to_curve[species.growth_stage - 1].size()):
		if ray_cast_growth.is_colliding():
			colliding = true
		ray_cast_growth.cast_to = species.growth_ray_cast_to_curve[species.growth_stage - 1][i]
		ray_cast_growth.force_raycast_update()
		if ray_cast_growth.is_colliding():
			colliding = true
	
	return !colliding

func chopped(cut_tier):
	
	var cutting_mod = 0.0
	
	if cut_tier < species.cut_tier:
		# Can place future bark generation in here if so desired.
		shake(1.0)
		return
	elif cut_tier == species.cut_tier:
		cutting_mod = 1.0
	elif cut_tier > species.cut_tier:
		# Theoretical room for advanced over-leveled cutting.
		cutting_mod = 2.0
	
	if species.current_wood_stored > 0:
		chop_wood(cutting_mod)
	else:
		chop_stump(cutting_mod)

func chop_wood(cutting_mod):
	yield(get_tree().create_timer(0.3), 'timeout')
	shake(1.0)
	species.cut_progress += 1.0 * cutting_mod
	if species.cut_progress >= species.cut_resistance_curve[species.growth_stage - 1]:
		generate_wood()
		species.cut_progress = 0
		if species.current_wood_stored == 0:
			chopped_down()

func generate_wood():
	get_tree().current_scene.add_item(species.wood_type_stored.duplicate())
	species.current_wood_stored -= 1

func chop_stump(cutting_mod):
	shake(1.0)
	yield(get_tree().create_timer(0.3), 'timeout')
	var grass_step_effect = grass_step_effect_scene.instance()
	grass_step_effect.position = position
	
	species.cut_progress += 1.0 * cutting_mod
	if species.cut_progress >= species.stump_cut_resistance[species.growth_stage - 1]:
		for i in range(species.stump_wood_stored_curve[species.growth_stage - 1]):
			generate_wood()
	
		get_tree().current_scene.add_child(grass_step_effect)
		self_remove()

func chopped_down():
	remove_shaded_levels()
	if species.growth_stage == 1:
		self_remove()
	stump = true
	shake(2.0)
	var grass_step_effect = grass_step_effect_scene.instance()
	grass_step_effect.position = position
	get_tree().current_scene.add_child(grass_step_effect)
	sprite.frame_coords.y = 1
	sprite_shadow.frame_coords.y = 1

func player_interacted(player):
	if species.harvestable:
		harvested()

func initialize_override(tree_species : TreeSpecies):
	species = tree_species.duplicate()
	species.growth_stage = growth_stage_override
	
	sprite.hframes = species.growth_stages
	sprite.texture = species.spritesheet
	sprite.offset = species.sprite_offset

	sprite_shadow.texture = species.shadow_spritesheet
	sprite_shadow.hframes = species.growth_stages
	sprite_shadow.offset = species.sprite_offset
	
	sprite.frame_coords = Vector2(species.growth_stage - 1, int(stump_override))
	sprite_shadow.frame_coords = Vector2(species.growth_stage - 1, int(stump_override))

	watered_effect_particles.process_material = load(species.watered_particle_effect_curve[species.growth_stage - 1][0])
	watered_effect_particles.position = species.watered_particle_effect_curve[species.growth_stage - 1][1]
	
	if species.growth_stage >= species.mature_stage:
		maturity_reached()
	
	if species.growth_stage == species.growth_stages:
		fruit_matured()

func initialize(tree_species : TreeSpecies):
	species = tree_species.duplicate()
	sprite.texture = species.spritesheet
	sprite_shadow.texture = species.shadow_spritesheet
	sprite.offset = species.sprite_offset
	sprite_shadow.offset = species.sprite_offset
	sprite.hframes = species.growth_stages
	sprite_shadow.hframes = species.growth_stages
	watered_effect_particles.process_material = load(species.watered_particle_effect_curve[species.growth_stage - 1][0])
	watered_effect_particles.position = species.watered_particle_effect_curve[species.growth_stage - 1][1]
	update_collision_shapes()

func fruit_grow():
	species.growth_progress_to_next_stage += species.fruit_growth_rate + int(species.watered) * (species.watered_growth_acceleration_curve[species.growth_stage - 1])
	if species.growth_progress_to_next_stage >= species.growth_curve[species.growth_stage - 1]:
		grow_fruit_to_next_stage()

func grow_fruit_to_next_stage():
	
	species.growth_stage += 1
	sprite.frame += 1
	species.growth_progress_to_next_stage = 0.0
	
	if species.growth_stage == species.growth_stages:
		fruit_matured()

func fruit_matured():
	species.harvestable = true
	interactable_collision_shape.disabled = false

func harvested():
	generate_fruit()
	if species.multiharvestable:
		fruit_harvest()
	else:
		plant_harvest()
	
	var grass_step_effect = grass_step_effect_scene.instance()
	grass_step_effect.position = position
	get_tree().current_scene.add_child(grass_step_effect)

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
	crop_item.quality = clamp(species.quality, 0.0, 1.0)
	print ("crop quality:", + crop_item.quality)
	species.quality = 0.0
	
	get_tree().current_scene.add_item(crop_item)


func maturity_reached():
	species.mature = true
	if species.multiharvestable:
		species.fruiting = true
	elif !species.multiharvestable:
		species.fruiting = false

func watered(watering_value):
	watered_effect_particles.amount = watering_value
	watered_effect_particles.emitting = true
	watered_effect_particles.visible = true
	species.current_water_level = watering_value
	species.watered = true


func shake(shake_amplitude_mod):
	set_process(true)
	state = State.SHAKING
	tween.interpolate_property(self, "shake_amplitude",
	shake_amplitude_initial * shake_amplitude_mod, 0.0, 0.25,
	Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()

func _process(delta):
	if state == State.SHAKING:
		
		shake_duration += delta * shake_speed
		sprite.offset = species.sprite_offset + Vector2(shake_amplitude * cos(shake_duration), 0)

func _on_tween_completed(object, key):
	shake_amplitude = shake_amplitude_initial
	state = State.IDLE
	set_process(false)
	sprite.offset = species.sprite_offset

func _on_Area2DShade_entered(area):
	if area.get_parent().has_method('shade_entered'):
		area.get_parent().shade_entered(species.shade_mod * species.shade_buff_provided[species.growth_stage - 1])

func _on_Area2DShade_exited(area):
	if area.get_parent().has_method('shade_exited'):
		area.get_parent().shade_exited(species.shade_mod * species.shade_buff_provided[species.growth_stage - 1])

func weather_changed(weather_precipitation, weather_light):
	if weather_precipitation != 0:
		var new_watered_level = clamp(species.current_water_level + weather_precipitation,0.0,100)
		watered(new_watered_level)
