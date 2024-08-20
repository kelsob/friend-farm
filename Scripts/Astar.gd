extends TileMap

export (bool) var debug = false

tool
onready var astar_node = AStar2D.new()
onready var map_size : Vector2

# The path start and end variables use setter methods
# You can find them at the bottom of the script

var path_start_position = Vector2() setget _set_path_start_position
var path_end_position = Vector2() setget _set_path_end_position

var _point_path = []

var character_locations : Array = []
var player_location 

const BASE_LINE_WIDTH = 3.0
const DRAW_COLOR = Color('#fff')

# get_used_cells_by_id is a method from the TileMap node
# here the id 0 corresponds to the grey tile, the obstacles
onready var obstacles : Array
onready var _half_cell_size = Vector2(8,8)

func initialize():
	map_size = get_parent().scene_tile_dimensions
	var base_cells_list = astar_add_base_cells()
	astar_connect_base_cells(base_cells_list)

func astar_add_base_cells():
	var points_array = []
	for y in range(map_size.y):
		for x in range(map_size.x):
			var point = Vector2(x, y)
			points_array.append(point)
			# The AStar class references points with indices
			# Using a function to calculate the index from a point's coordinates
			# ensures we always get the same index with the same input point
			var point_index = calculate_point_index(point)
			# AStar works for both 2d and 3d, so we have to convert the point
			# coordinates from and to Vector3s
			astar_node.add_point(point_index, Vector2(point.x, point.y))
	return points_array

func astar_connect_base_cells(points_array):
	for point in points_array:
		var point_index = calculate_point_index(point)
		# For every cell in the map, we check the one to the top, right.
		# left and bottom of it. If it's in the map and not an obstalce,
		# We connect the current point with it
		var points_relative = PoolVector2Array([
			Vector2(point.x + 1, point.y),
			Vector2(point.x - 1, point.y),
			Vector2(point.x, point.y + 1),
			Vector2(point.x, point.y - 1)])
		for point_relative in points_relative:
			var point_relative_index = calculate_point_index(point_relative)

			if is_outside_map_bounds(point_relative):
				continue
			if not astar_node.has_point(point_relative_index):
				continue
			# Note the 3rd argument. It tells the astar_node that we want the
			# connection to be bilateral: from point A to B and B to A
			# If you set this value to false, it becomes a one-way path
			# As we loop through all points we can set it to false
			astar_node.connect_points(point_index, point_relative_index, false)

func disable_obstructing_cells(obstacles, disabled):


	for obstacle_point in obstacles:
		if astar_node.has_point(calculate_point_index(obstacle_point)):
			if debug: print(obstacle_point)
			astar_node.set_point_disabled(calculate_point_index(obstacle_point), disabled)


# Click and Shift force the start and end position of the path to update
# and the node to redraw everything
func _input(event):
	if event.is_action_pressed('left_click') and Input.is_key_pressed(KEY_SHIFT):
		# To call the setter method from this script we have to use the explicit self.
		self.path_start_position = world_to_map(get_global_mouse_position())
	elif event.is_action_pressed('left_click'):
		self.path_end_position = world_to_map(get_global_mouse_position())


# This is a variation of the method above
# It connects cells horizontally, vertically AND diagonally
func astar_connect_walkable_cells_diagonal(points_array):
	for point in points_array:
		var point_index = calculate_point_index(point)
		for local_y in range(3):
			for local_x in range(3):
				var point_relative = Vector2(point.x + local_x - 1, point.y + local_y - 1)
				var point_relative_index = calculate_point_index(point_relative)

				if point_relative == point or is_outside_map_bounds(point_relative):
					continue
				if not astar_node.has_point(point_relative_index):
					continue
				astar_node.connect_points(point_index, point_relative_index, true)


func is_outside_map_bounds(point):
	return point.x < 0 or point.y < 0 or point.x >= map_size.x or point.y >= map_size.y


func calculate_point_index(point):
	return point.x + map_size.x * point.y


func find_path(world_start, world_end):
	self.path_start_position = world_to_map(world_start)
	self.path_end_position = world_to_map(world_end)
	_recalculate_path()
	var path_world = []
	for point in _point_path:
		var point_world = map_to_world(Vector2(point.x, point.y)) + _half_cell_size
		path_world.append(point_world)
	return path_world

func _recalculate_path():
	clear_previous_path_drawing()
	var start_point_index = calculate_point_index(path_start_position)
	var end_point_index = calculate_point_index(path_end_position)
	# This method gives us an array of points. Note you need the start and end
	# points' indices as input
	_point_path = astar_node.get_point_path(start_point_index, end_point_index)
	# Redraw the lines and circles from the start to the end point
	update()

func clear_previous_path_drawing():
	if not _point_path:
		return
	var point_start = _point_path[0]
	var point_end = _point_path[len(_point_path) - 1]
	set_cell(point_start.x, point_start.y, -1)
	set_cell(point_end.x, point_end.y, -1)

func _draw():

	if not _point_path:
		return
	var point_start = _point_path[0]
	var point_end = _point_path[len(_point_path) - 1]

	set_cell(point_start.x, point_start.y, 1)
	set_cell(point_end.x, point_end.y, 2)

	var last_point = map_to_world(Vector2(point_start.x, point_start.y)) + _half_cell_size
	for index in range(1, len(_point_path)):
		var current_point = map_to_world(Vector2(_point_path[index].x, _point_path[index].y)) + _half_cell_size
		draw_line(last_point, current_point, DRAW_COLOR, BASE_LINE_WIDTH, true)
		draw_circle(current_point, BASE_LINE_WIDTH * 2.0, DRAW_COLOR)
		last_point = current_point

func disconnect_rect_pathability(rect_region):
	var base_position = rect_region[0]
	var cell_ids = []
	
	for cell in rect_region[1]:
		cell_ids.append(calculate_point_index(base_position + cell))
	
	for cell_id in cell_ids:

		var connected_cells = astar_node.get_point_connections(cell_id)
		for connected_cell in connected_cells:
			if !has_cell(cell_ids, connected_cell):
				
				astar_node.disconnect_points(cell_id, connected_cell)

	var connector_ids = []
	for connector in rect_region[2]:
		var connector_cell = base_position + connector[0]
		var reconnected_cell = base_position + connector[0] + connector[1]
		astar_node.connect_points(calculate_point_index(connector_cell), calculate_point_index(reconnected_cell), true)


func has_cell(cell_ids, connected_cell):
	var cell_found = false
	
	for cell in cell_ids:
		if cell == connected_cell:
			cell_found = true
			break
	
	return cell_found

# Setters for the start and end path values.
func _set_path_start_position(value):
	if value in obstacles:
		return
	if is_outside_map_bounds(value):
		return

	set_cell(path_start_position.x, path_start_position.y, -1)
	set_cell(value.x, value.y, 1)
	path_start_position = value
	if path_end_position and path_end_position != path_start_position:
		_recalculate_path()


func _set_path_end_position(value):
	if value in obstacles:
		return
	if is_outside_map_bounds(value):
		return

	set_cell(path_start_position.x, path_start_position.y, -1)
	set_cell(value.x, value.y, 2)
	path_end_position = value
	if path_start_position != value:
		_recalculate_path()

func are_points_connected(tile_location_current, tile_location_target):
	return astar_node.are_points_connected(calculate_point_index(tile_location_current/16), calculate_point_index(tile_location_target/16))

func get_point_path(point_1, point_2):
	point_1 -= get_global_position()/16
	point_2 -= get_global_position()/16
	
	point_1 = calculate_point_index(point_1)
	point_2 = calculate_point_index(point_2)
	
#	print('point1:, ', point_1, ', point2:, ', point_2)

	var point_path = []

	if astar_node.has_point(point_1) and astar_node.has_point(point_2):
		point_path = astar_node.get_point_path(point_1, point_2)

#	print(point_path)
	
	return point_path

func is_point_disabled(point):
	var point_index = calculate_point_index(point)/16
#	print("checking if : ", point_index, " is disabled.")
	if astar_node.has_point(point_index):
		return astar_node.is_point_disabled(point_index)
	else:
		return false

func get_closest_point(point, include_disabled):
	return astar_node.get_point_position(astar_node.get_closest_point(point/16, include_disabled))

func npc_departed_tile(tile_location):
	character_locations.erase(tile_location)
	disable_obstructing_cells([tile_location], false)

func npc_arrived_tile(tile_location):
	character_locations.append(tile_location)
	disable_obstructing_cells([tile_location], true)

func player_arrived_tile(tile_location):
	player_location = tile_location
	disable_obstructing_cells([tile_location], true)

func player_departed_tile(tile_location):
	disable_obstructing_cells([tile_location], false)

func get_npcless_path(point_1, point_2):
	disable_obstructing_cells(character_locations, false)
	if player_location != null:
		disable_obstructing_cells([player_location], false)
	
	var point_path = get_point_path(point_1, point_2)
	
	disable_obstructing_cells(character_locations, true)
	if player_location != null:
		disable_obstructing_cells([player_location], true)

	return point_path
