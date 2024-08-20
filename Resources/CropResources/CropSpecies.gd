extends Resource
class_name CropSpecies

# General Properties
export (String) var name

# Plant Properties
export (Texture) var plant_spritesheet
export (Vector2) var sprite_offset

enum SunShade {SUN, SHADE}
export (SunShade) var sun_shade = SunShade.SUN
export (int) var shade_tier = 0

export (int) var growth_stage = 1
export (int) var growth_stages = 5
export (float) var base_growth_rate = 1.0
export (Array, float) var growth_curve = [5.0,5.0,5.0,5.0,5.0,5.0,5.0]
export (int) var mature_stage = 5

export (bool) var mature = false
export (bool) var fruiting = false
export (float) var fruit_growth_rate = 1.0

export (float) var growth_progress_to_next_stage = 0.0

# Plant Watering Variables
export (bool) var watered = false
export (Array, float) var optimal_watering_curve = [2,4,6,8,10,15,20,20]
export (Array, float) var watered_growth_acceleration_curve = [4.0,3.0,2.0,1.0,1.0,1.0,1.0,1.0]

export (float) var watered_quality_improvement = 0.05
export (float) var current_water_level = 0.0
export (float) var daily_water_retention = 0.5

export (Array, Array) var watered_particle_effect_curve = [["res://Scenes/Particles/WateredParticleSphere3.tres", Vector2(8, 6)],
	["res://Scenes/Particles/WateredParticleSphere3.tres", Vector2(8, 6)],
	["res://Scenes/Particles/WateredParticleSphere4.tres", Vector2(8, 6)],
	["res://Scenes/Particles/WateredParticleSphere6.tres", Vector2(8, 6)],
	["res://Scenes/Particles/WateredParticleSphere8.tres", Vector2(8, 6)],
	["res://Scenes/Particles/WateredParticleSphere8.tres", Vector2(8, 6)],
	["res://Scenes/Particles/WateredParticleSphere8.tres", Vector2(8, 6)],
	["res://Scenes/Particles/WateredParticleSphere8.tres", Vector2(8, 6)],
]

# Quality Variables
export (float) var quality = 0.0

# Pruning Variables.
export (bool) var pruned = false
export (int) var prune_count = 0

# Crop + Harvesting Variables
export (int) var crop_quantity = 0
export (float) var crop_quality = 0.0

export (bool) var harvestable = false
export (bool) var multiharvestable = false
export (int) var harvest_count = 0
export (String) var crop_item_path

# Seed Variables
export (String) var seed_item_path = ""
export (Array, float) var extra_seed_generation_chances = [0.5, 0.3, 0.2, 0.1, 0.05, 0.01, 0.001]
export (bool) var seed_harvestable = false
export (int) var seed_growth_days = 7
export (int) var seed_growth_progression = 0

# Fertilization Variables
var fertilizer_item = null
var fertilized : bool = false

# Cutting Variables
export (int) var cut_tier = 0

export (Array, float) var cut_resistance_curve = [1.0,2.0,3.0]
export (float) var cut_progress = 0.0
export (Resource) var wood_type_stored
export (Array, float) var wood_stored_curve = [1.0, 3.0, 6.0]
export (int) var current_wood_stored = 1.0
export (float) var wood_regeneration_rate = 0.25
export (float) var current_wood_regeneration = 0.0
