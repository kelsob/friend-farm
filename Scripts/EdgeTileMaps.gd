extends Node2D
tool

onready var edge_left = $EdgeTileMapLeft
onready var edge_right = $EdgeTileMapRight
onready var edge_up = $EdgeTileMapUp
onready var edge_down = $EdgeTileMapDown

func initialize_positions(map_dimensions):
	
	var horizontal_midposition = (map_dimensions.x/2) * 16
	var vertical_midposition = (map_dimensions.y/2) * 16
	var horizontal_endposition = (map_dimensions.x + 1.5) * 16
	var vertical_endposition = (map_dimensions.y + 1.5) * 16
	
	edge_left.position = Vector2(8, vertical_midposition)
	edge_up.position = Vector2(horizontal_midposition, -8)
	edge_right.position = Vector2(horizontal_endposition, vertical_midposition)
	edge_down.position = Vector2(horizontal_midposition, vertical_endposition)

