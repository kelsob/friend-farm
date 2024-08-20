extends Node2D

var obstructing = true

export (Vector2) var tile_dimensions = Vector2(1, 1)


func return_colliding_indices():
	var obstacle_array = []

	for dx in range(tile_dimensions.x):
		for dy in range(tile_dimensions.y):
			var index = Vector2(get_global_position().x/16 + dx, get_global_position().y/16 + dy)
			obstacle_array.append(index)
	
	return obstacle_array
