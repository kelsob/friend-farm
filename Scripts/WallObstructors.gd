extends StaticBody2D

export (bool) var debug = false

func collect_obstructing_cells():
	var obstructing_cells = []
	for obstructor in get_children():
		for obstructing_cell in obstructor.obstacle_array:
			obstructing_cells.append(obstructing_cell)
			if debug:
				print("obstructing cell:", obstructing_cell)
	return obstructing_cells
