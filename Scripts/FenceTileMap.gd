extends TileMap

export (Array, Resource) var fence_buildable_items = [load("res://Resources/ItemResources/BuildableItems/BuildableFenceItems/PicketFence.tres"),
	load("res://Resources/ItemResources/BuildableItems/BuildableFenceItems/WoodFence.tres")] 
export (Array, Vector2) var gate_positions = []


func dismantle_cell(fence_location, fence_id):
	set_cellv(fence_location/16, -1, false, false)
	update_dirty_quadrants()
	update_bitmask_area(fence_location/16)
	
	get_tree().current_scene.add_item(fence_buildable_items[fence_id].duplicate(), fence_location + Vector2(8,8))
	
	clear_gates()


func dismantle_held_cell(fence_location, fence_id):
	get_tree().current_scene.add_item(fence_buildable_items[fence_id].duplicate(), fence_location + Vector2(8,8))

func gate_built(gate_location):
	gate_positions.append(gate_location/16)
	gate_location = gate_location/16
	set_cell(gate_location.x, gate_location.y, 1, false, false, false, Vector2(4,3))
	update_dirty_quadrants()
	update_bitmask_area(gate_location)
	
	clear_gates()

func clear_gates():
	
	for gate_position in gate_positions:
		set_cell(gate_position.x, gate_position.y, 1, false, false, false, Vector2(4,3))
