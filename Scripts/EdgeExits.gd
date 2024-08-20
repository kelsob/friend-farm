extends Area2D
tool

onready var edge_left = $EdgeExitLeft
onready var edge_right = $EdgeExitRight
onready var edge_up = $EdgeExitUp
onready var edge_down = $EdgeExitDown

func initialize_scale(map_dimensions):
	
	var horizontal_midposition = (map_dimensions.x/2 + 0.5) * 16
	var vertical_midposition = (map_dimensions.y/2 + 0.5) * 16
	var horizontal_endposition = (map_dimensions.x + 0.5) * 16
	var vertical_endposition = (map_dimensions.y + 0.5) * 16
	
	edge_left.position = Vector2(8, vertical_midposition)
	edge_up.position = Vector2(horizontal_midposition, -8)
	edge_right.position = Vector2(horizontal_endposition, vertical_midposition)
	edge_down.position = Vector2(horizontal_midposition, vertical_endposition)
	
	edge_up.scale = Vector2(map_dimensions.x + 1.5, 1)
	edge_down.scale = Vector2(map_dimensions.x + 1.5, 1)
	edge_left.scale = Vector2(map_dimensions.x + 1.5, 1)
	edge_right.scale = Vector2(map_dimensions.x + 1.5, 1)

