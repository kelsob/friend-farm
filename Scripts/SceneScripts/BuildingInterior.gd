extends Node2D
class_name BuildingInterior

export (bool) var debug_mode

var indoors = true
var active = false
var player

export (Vector2) var scene_tile_dimensions = Vector2(64,64)
export (Array, int) var camera_limits = [-400, 400, -400, 400]
export (Array, String) var connected_scenes = []

var wall_cells : Array = []

onready var ysort = $YSort

onready var A_star = $Astar
onready var entrance_positions = $EntrancePositions
onready var background_black = $ColorRect

onready var wall_obstructors = $WallObstructors
onready var colliding_tilemaps : Array = [
]

func _ready():
	background_black.show()

func initialize():
	initialize_a_star()

func activate():
	player.camera_activate()
	yield(get_tree().create_timer(1.0), "timeout")
	player.activate()
	active = true

	ysort.activate()

func deactivate():
	active = false

func remove_player():
	ysort.characters.remove_child(player)

func add_player(player_init):
	player = player_init
	ysort.characters.add_child(player)

func advance_day():
	pass

func _on_weather_changed(weather_precipitation, weather_light):
	pass

func initialize_a_star():
	A_star.initialize()
	var obstacles_array = collect_obstacles()
	A_star.disable_obstructing_cells(obstacles_array, true)
	establish_pathable_areas()

func establish_pathable_areas():
	var pathable_areas = ysort.collect_pathable_areas()
	for pathable_area in pathable_areas:
		A_star.disconnect_rect_pathability(pathable_area)

func collect_obstacles():
	var obstacle_array : Array = []
	
	for tilemap in colliding_tilemaps:
		obstacle_array += tilemap.get_used_cells()

	obstacle_array += ysort.collect_obstacles()
	obstacle_array += wall_obstructors.collect_obstructing_cells()
	return obstacle_array


func get_exits(target_scene_id):
	var target_scene_name = get_parent().get_child(target_scene_id).name
	var potential_entrances = []
	
	for entrance in entrance_positions.get_children():
		if entrance.connected_scene == target_scene_name:
			potential_entrances.append(entrance)
	
	return potential_entrances
