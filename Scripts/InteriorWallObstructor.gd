extends Node2D

var obstacle_array = []

func _ready():
	obstacle_array = []
	
	for dx in range(scale.x):
		for dy in range(scale.y):
			var index = Vector2(get_global_position().x/16 + dx, get_global_position().y/16 + dy)
			
			if !obstacle_array.has(index):
				obstacle_array.append(index)
