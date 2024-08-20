extends Node2D
tool

onready var entrance_left = get_node("0EntranceLeft")
onready var entrance_right = get_node("1EntranceRight")
onready var entrance_up = get_node("2EntranceUp")
onready var entrance_down = get_node("3EntranceDown")

func initialize_positions(map_dimensions):
	
	var horizontal_midposition = (map_dimensions.x/2) * 16
	var vertical_midposition = (map_dimensions.y/2) * 16
	var horizontal_endposition = (map_dimensions.x - 1) * 16
	var vertical_endposition = (map_dimensions.y - 1) * 16
	
	
	entrance_left.position = Vector2(16, vertical_midposition)
	entrance_right.position = Vector2(horizontal_endposition, vertical_midposition)
	entrance_up.position = Vector2(horizontal_midposition, 0)
	entrance_down.position = Vector2(horizontal_midposition, vertical_endposition)
