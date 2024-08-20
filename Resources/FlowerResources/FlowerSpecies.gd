extends Resource
class_name FlowerSpecies

# General Properties
export (String) var name

# Plant Properties
export (Texture) var spritesheet
export (Vector2) var sprite_offset

enum SunShade {SUN, SHADE}
export (SunShade) var sun_shade = SunShade.SUN
export (int) var shade_tier = 0

export (int) var growth_stage = 1
export (int) var growth_stages = 6
export (float) var base_growth_rate = 1.0
export (Array, float) var growth_curve = [5.0,5.0,5.0,5.0,5.0,5.0,5.0]
export (int) var mature_stage = 4

export (bool) var mature = false
export (bool) var flowering = false
export (float) var flower_growth_rate = 1.0

export (float) var growth_progress_to_next_stage = 0.0

# Breeding / Spreading / General Replication Variables
export (bool) var spreading = false
export (float) var random_spread_chance_base = 0.01
export (float) var random_spread_chance_current = 0.01

var spread_locations = [Vector2(-8,-8),
	Vector2(0,-8),
	Vector2(8,-8),
	Vector2(8,0),
	Vector2(8,8),
	Vector2(0,8),
	Vector2(-8,8),
	Vector2(-8,0)
]

var breed_locations = [Vector2(-16,-16),
	Vector2(16,-16),
	Vector2(16,16),
	Vector2(-16,16)
]

# Collision/Z-index properties

# Plant Watering Variables
export (bool) var watered = false
export (Array, float) var optimal_watering_curve = [6,7,8,9,10,11]
export (Array, float) var watered_growth_acceleration_curve = [1.0,1.0,1.0,1.0,1.0,1.0]

export (float) var watered_quality_improvement = 0.05
export (float) var current_water_level = 0.0
export (float) var daily_water_retention = 0.25

export (Array, Array) var watered_particle_effect_curve = [["res://Scenes/Particles/WateredParticleSphere3.tres", Vector2(8, 6)],
	["res://Scenes/Particles/WateredParticleSphere3.tres", Vector2(8, 6)],
	["res://Scenes/Particles/WateredParticleSphere4.tres", Vector2(8, 6)],
	["res://Scenes/Particles/WateredParticleSphere6.tres", Vector2(8, 6)],
	["res://Scenes/Particles/WateredParticleSphere8.tres", Vector2(8, 6)],
	["res://Scenes/Particles/WateredParticleSphere8.tres", Vector2(8, 6)]]

# Crop + Harvesting Variables
export (int) var flower_quantity = 0
export (float) var quality = 0.0

# Pruning Variables.
export (bool) var pruned = false
export (int) var prune_count = 0

export (bool) var harvestable = false
export (bool) var multiharvestable = false
export (int) var harvest_count = 0
export (String) var flower_item_path
export (String) var flower_object_path

# Cutting Variables
export (int) var cut_tier = 0

var rng = RandomNumberGenerator.new()
