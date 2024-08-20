extends "res://Scripts/InteractableObject.gd"
tool

export var growth_stage = 1
export var max_growth = 3
export var growth_curve = [4,3,2]
export var growth_clock = 0 
export var internal_clock = 0
var fully_grown : bool = false
var watered : bool = false
export (float) var current_water_level = 0.0
export (float) var water_retention_level = 0.25
export (float) var spread_chance = 0.1
var spread_locations = [Vector2(-8,-8),
	Vector2(0,-8),
	Vector2(8,-8),
	Vector2(8,0),
	Vector2(8,8),
	Vector2(0,8),
	Vector2(-8,8),
	Vector2(-8,0)
]

export (String) var spread_object_path = "res://Scenes/Objects/Plants/Grass.tscn"
export (String) var grass_overlay_scene = "res://Scenes/Objects/Plants/GrassOverlaySprite.tscn"
const grass_step_effect_scene = preload("res://Scenes/Effects/GrassStepEffect.tscn")

export (bool) var randomize_flip_h = true
var grass_overlay

var player_inside = false
var rng = RandomNumberGenerator.new()

onready var spread_raycast : RayCast2D = $RayCast2DSpread

func player_interacted(player):
	pass

func _ready():
	update_sprite()

	rng.randomize()
	if randomize_flip_h:
		sprite.flip_h = bool(rng.randi_range(0,1))
	if growth_stage == max_growth:
		fully_grown = true
	
#	var player = find_parent("SceneHolder").get_children().front().find_node("Player")
#	if player != null:
#		player.connect("player_moving_signal", self, "player_exiting_grass")



func grow():
	
	if fully_grown:
		return
	else:
		sprite.frame += 1
		growth_stage += 1
		if growth_stage == max_growth:
			fully_grown = true
		update_sprite()

func player_exiting_grass():
	player_inside = false
	update_sprite()
	if is_instance_valid(grass_overlay):
		grass_overlay.queue_free()

func update_sprite():
	sprite.frame_coords = Vector2(growth_stage - 1, 0)

func advance_day():
	advance_watering()
	internal_clock += 1
	growth_clock += 1 + current_water_level
	
	if fully_grown:
		spread_check()
		return
	
	if growth_clock >= growth_curve[growth_stage]:
		grow()
		growth_clock = 0

func advance_watering():
	current_water_level *= water_retention_level
	if current_water_level <= 0.08:
		current_water_level = 0.0
		watered = false

func spread_check():
	var spread = rng.randf_range(0.0,1.0)
	if spread <= spread_chance:
		spread()

func spread():
	var plant_location
	var cast_direction = rng.randi_range(0,7)
	spread_raycast.cast_to = spread_locations[cast_direction]
	spread_raycast.force_raycast_update()
	cast_direction = spread_locations[cast_direction]
	
	if spread_raycast.get_collider() == null:
		plant_location = get_global_position() + cast_direction * 2
		var new_grass_scene = load(spread_object_path)
		var new_grass = new_grass_scene.instance()
		get_tree().current_scene.current_scene.ysort.grasses.add_child(new_grass)
		new_grass.set_global_position(plant_location)

func _on_Area2D_body_entered(body):
	player_inside = true
	
	sprite.frame_coords = Vector2(growth_stage - 1, sprite.vframes - 1)
	
	grass_overlay = load(grass_overlay_scene).instance()
	grass_overlay.frame = growth_stage - 1
	grass_overlay.position = position
	get_node("../..").add_child(grass_overlay)

	if growth_stage == 0:
		return
	
	yield(get_tree().create_timer(0.1), "timeout")
	var grass_step_effect = grass_step_effect_scene.instance()
	grass_step_effect.position = position
	get_tree().current_scene.add_child(grass_step_effect)

func watered(watering_value):
#	watered_effect_particles.amount = watering_value
#	watered_effect_particles.emitting = true
#	watered_effect_particles.visible = true
	current_water_level = watering_value
	watered = true


func _on_Area2D_body_exited(body):
	player_exiting_grass()

func weather_changed(weather_precipitation, weather_light):
	if weather_precipitation != 0:
		var new_watered_level = clamp(current_water_level + weather_precipitation,0.0,100)
		watered(new_watered_level)

