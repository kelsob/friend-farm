extends Node2D
class_name WorldScene
tool

var active = false
var player

var indoors = false

export (Vector2) var scene_tile_dimensions = Vector2(64,64)
export (Array, int) var camera_limits = [16, 1024, 0, 1024]
export (Array, String) var connected_scenes = []

onready var entrance_positions = $EntrancePositions

onready var ysort = $YSort
onready var background_objects = $BackgroundObjects

onready var tilled_earth_tilemap : TileMap = $TilledEarthTileMap
onready var water_tilemap : TileMap = $WaterTileMap
onready var ledge_tilemap_l : TileMap = $LedgeTileMapLeft
onready var ledge_tilemap_r : TileMap = $LedgeTileMapRight
onready var ledge_tilemap_u : TileMap = $LedgeTileMapUp
onready var ledge_tilemap_d : TileMap = $LedgeTileMapDown
onready var fence_tilemap : TileMap = $FenceTileMap
onready var structural_tilemap : TileMap = $StructuralTileMap

onready var edge_tilemaps = $EdgeTileMaps
onready var edge_exits = $EdgeExits

onready var colliding_tilemaps : Array = [water_tilemap,
	fence_tilemap,
	ledge_tilemap_l,
	ledge_tilemap_r,
	ledge_tilemap_u,
	ledge_tilemap_d,
	structural_tilemap
]

onready var A_star = $Astar

func _ready():
	initialize_edges()

func initialize():
	initialize_a_star()

func activate():
	player = get_node("YSort/CharactersYSort/Player")
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
	ysort.advance_day()

func initialize_a_star():
	A_star.initialize()
	var obstacles_array = collect_obstacles()
	A_star.disable_obstructing_cells(obstacles_array, true)
	establish_pathable_areas()

func initialize_edges():
	edge_exits.initialize_scale(scene_tile_dimensions)
#	entrance_positions.initialize_positions(scene_tile_dimensions)
	edge_tilemaps.initialize_positions(scene_tile_dimensions)

func establish_pathable_areas():
	var pathable_areas = ysort.collect_pathable_areas()
	for pathable_area in pathable_areas:
		A_star.disconnect_rect_pathability(pathable_area)

func collect_obstacles():
	var obstacle_array : Array = []
	
	for tilemap in colliding_tilemaps:
		obstacle_array += tilemap.get_used_cells()

	obstacle_array += ysort.collect_obstacles()
	return obstacle_array

func create_obstacle(obstacle_points):
	A_star.disable_obstructing_cells(obstacle_points, true)

func remove_obstacle(obstacle_points):
	A_star.disable_obstructing_cells(obstacle_points, false)

func _on_weather_changed(weather_precipitation, weather_light):
	if indoors:
		return
	
	ysort.weather_changed(weather_precipitation, weather_light)

func get_exits(target_scene_id):
	var target_scene_name = get_parent().get_child(target_scene_id).name
	var potential_entrances = []
	
	for entrance in entrance_positions.get_children():
		if entrance.connected_scene == target_scene_name:
			potential_entrances.append(entrance)
	
	return potential_entrances

