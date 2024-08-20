extends Resource
class_name TreeSpecies

# General Properties
export (String) var name

# Plant Properties
export (Texture) var spritesheet
export (Texture) var shadow_spritesheet
export (Vector2) var sprite_offset

export (int) var growth_stage = 1
export (int) var growth_stages = 5
export (float) var base_growth_rate = 1.0
export (Array, float) var growth_curve = [5.0,5.0,5.0,5.0]
export (int) var mature_stage = 3

export (bool) var mature = false
export (bool) var fruiting = false
export (float) var fruit_growth_rate = 1.0

export (float) var growth_progress_to_next_stage = 0.0

# Plant Watering Variables
export (bool) var watered = false
export (Array, float) var optimal_watering_curve = [15,20,30,45,45]
export (Array, float) var watered_growth_acceleration_curve = [1.0,1.0,1.0,1.0,1.0]

export (float) var current_water_level = 0.0
export (float) var daily_water_retention = 0.5

export (Array, Array) var watered_particle_effect_curve = [["res://Scenes/Particles/WateredParticleSphere3.tres", Vector2(8, 6)],
	["res://Scenes/Particles/WateredParticleSphere3.tres", Vector2(8, 6)],
	["res://Scenes/Particles/WateredParticleSphere4.tres", Vector2(8, 6)],
	["res://Scenes/Particles/WateredParticleSphere6.tres", Vector2(8, 6)],
	["res://Scenes/Particles/WateredParticleSphere8.tres", Vector2(8, 6)]]

# Crop + Harvesting Variables
export (int) var crop_quantity = 0
export (float) var quality = 0.0

export (bool) var harvestable = false
export (bool) var multiharvestable = false
export (int) var harvest_count = 0
export (String) var crop_item_path

# Cutting Variables
export (int) var cut_tier = 1
export (Array, float) var cut_resistance_curve = [1.0,2.0,3.0,3.0,3.0]
export (float) var cut_progress = 0.0

export (Resource) var wood_type_stored
export (Array, float) var wood_quantity_stored_curve = [2.0, 4.0, 6.0, 6.0, 6.0]
export (int) var current_wood_stored = 1
export (float) var wood_regeneration_rate = 1.0
export (float) var current_wood_regeneration = 0.0

export (Array, int) var stump_wood_stored_curve = [1.0,2.0,3.0,3.0,3.0]
export (Array, float) var stump_cut_resistance = [0.0,2.0,4.0,4.0,4.0]

export (Array, Vector2) var tree_collision_curve = [Vector2(2,1), Vector2(2,1), Vector2(2,1)]
export (Array, Array, Vector2) var growth_ray_cast_to_curve = [[Vector2(-16, 0), Vector2(16, 0), Vector2(0, -16), Vector2(0, 16)], [Vector2(-16, 0), Vector2(16, 0), Vector2(0, -16), Vector2(0, 16)]]

# Shade Properties
export (Array, bool) var shade_buff_provided = [0.0, 0.5, 1.0, 1.0, 1.0]
export (bool) var providing_shade = false
export (float) var shade_mod = 0.2

var rng = RandomNumberGenerator.new()
