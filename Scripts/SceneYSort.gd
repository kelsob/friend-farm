extends YSort
tool


onready var trees = $TreesYSort
onready var plants = $PlantsYSort
onready var grasses = $GrassesYSort
onready var flowers = $FlowersYSort
onready var stones = $StonesYSort
onready var items = $ItemsYSort
onready var buildings = $BuildingsYSort
onready var rooftops = $RooftopsYSort
onready var wall_obstructors = $WallObstructorYSort
onready var objects = $ObjectsYSort

onready var characters = $CharactersYSort
onready var tilemaps = $TileMapYSort

onready var ysort_array = [trees, plants, grasses, flowers, stones, items, buildings, characters, wall_obstructors, objects]

func _ready():
	for building in buildings.get_children():
		if building.has_method("create_rooftops"):
			building.create_rooftops()

func advance_day():
	for tree in trees.get_children():
		tree.advance_day()
	for plant in plants.get_children():
		plant.advance_day()
	for flower in flowers.get_children():
		flower.advance_day()
	for grass in grasses.get_children():
		grass.advance_day()

func collect_obstacles():
	var obstacle_array = []
	
	for ysort in ysort_array:
		for potential_collider in ysort.get_children():
			if potential_collider.obstructing:
				for index in potential_collider.return_colliding_indices():
					obstacle_array.append(index)
	
	for tilemap in tilemaps.get_children():
		obstacle_array += tilemap.get_child(0).get_used_cells()
	
	return obstacle_array

func collect_pathable_areas():
	var pathable_areas = []
	for building in buildings.get_children():
		if building.has_method("return_porch_cells"):
			pathable_areas.append(building.return_porch_cells())
	return pathable_areas
	

func activate():
	for character in characters.get_children():
		character.scene_activate()

func weather_changed(weather_precipitation, weather_light):
	for tree in trees.get_children():
		tree.weather_changed(weather_precipitation, weather_light)
	for plant in plants.get_children():
		plant.weather_changed(weather_precipitation, weather_light)
	for grass in grasses.get_children():
		grass.weather_changed(weather_precipitation, weather_light)
	for flower in flowers.get_children():
		flower.weather_changed(weather_precipitation, weather_light)

	for building in buildings.get_children():
		building.weather_changed(weather_precipitation, weather_light)
