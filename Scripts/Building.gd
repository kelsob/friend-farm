extends Node2D
class_name Building

export (bool) var obstructing = true
export (Vector2) var tile_dimensions = Vector2(1,1)

export (String) var interior_scene_path = ""

export (Array, Vector2) var structure_cells = []
export (Array, Vector2) var porch_cells = []
export (Array, Array) var porch_connectors = []

onready var sprite = $Sprite
onready var weathered_effects = $WeatheredEffects
onready var rooftop_sprites = $RooftopSprites
onready var doors = $Doors
onready var anim = $AnimationPlayer

var rng = RandomNumberGenerator.new()

func _ready():
	for door in doors.get_children():
		door.next_scene_path = interior_scene_path
	rng.randomize()

func weather_changed(weather_precipitation, weather_light):
	get_node('WeatheredEffects')
	weathered_effects.weather_changed(weather_precipitation, weather_light)

func create_rooftops():
	for rooftop_sprite_init in rooftop_sprites.get_children():
		var rooftop_sprite = Sprite.new()
		get_node('../../RooftopsYSort').add_child(rooftop_sprite)
		rooftop_sprite.centered = false
		rooftop_sprite.position = position + rooftop_sprite_init.position
		rooftop_sprite.offset = rooftop_sprite_init.offset
		rooftop_sprite.z_index = 5
		rooftop_sprite.texture = rooftop_sprite_init.texture
		
		rooftop_sprite_init.visible = false

func return_porch_cells():
	return [get_global_position()/16, porch_cells, porch_connectors]

func return_colliding_indices():
	var obstacle_array = []
	
	for obstructing_cell in structure_cells:
		obstacle_array.append(obstructing_cell + get_global_position()/16)

#	for dx in range(tile_dimensions.x):
#		for dy in range(tile_dimensions.y):
#			var index = Vector2(get_global_position().x/16 + dx, get_global_position().y/16 + dy)
#			obstacle_array.append(index)
	
	return obstacle_array
