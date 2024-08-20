extends InteractableObject
class_name Gate


enum ORIENTATION {HORIZONTAL, VERTICAL}
export (ORIENTATION) var gate_orientation = ORIENTATION.HORIZONTAL
enum STATE {OPEN, CLOSED, OPENING, CLOSING}
export (STATE) var gate_state = STATE.CLOSED

export (Texture) var horizontal_texture
export (Texture) var vertical_texture

var interacted_direction : String
var open_direction : String
var fence_id = 0

var fences_found = [false, false, false, false]
onready var fence_collision_areas = [$Area2DLeft, $Area2DRight, $Area2DUp, $Area2DDown]
var detecting_areas = true

func initialize(fence_id_init):
	fence_id = fence_id_init

func player_interacted(player):
	
	if gate_state == STATE.CLOSED:
		
		var difference_vector = (get_global_position() - player.get_global_position() - player.grid_offset)/16
		
		if difference_vector.x < 0:
			open_direction = "left"
		elif difference_vector.x > 0:
			open_direction = "right"
		elif difference_vector.y < 0:
			open_direction = "up"
		elif difference_vector.y > 0:
			open_direction = "down"
		
		gate_state = STATE.OPENING
		open(open_direction)
		
	elif gate_state == STATE.OPEN:
		
		gate_state = STATE.CLOSING
		close(open_direction)
	
	interacted_direction = open_direction

func npc_opened(npc_facing_vector):
	var difference_vector = npc_facing_vector.normalized()
	
	if difference_vector.x < 0:
		open_direction = "left"
	elif difference_vector.x > 0:
		open_direction = "right"
	elif difference_vector.y < 0:
		open_direction = "up"
	elif difference_vector.y > 0:
		open_direction = "down"
	
	
	interacted_direction = open_direction
	open(open_direction)

func npc_closed():
	if gate_state == STATE.OPEN:
		close(open_direction)
		

func open(open_direction):
	anim.play("open_gate_" + open_direction)
	remove_astar_obstacles()
#	collision_shape_obstruction.disabled = true

func close(close_direction):
	anim.play("close_gate_" + close_direction)
	add_astar_obstacles()
#	collision_shape_obstruction.disabled = false

func opened():
	gate_state = STATE.OPEN

func closed():
	gate_state = STATE.CLOSED

func set_vertical():
	gate_orientation = ORIENTATION.VERTICAL
	sprite.texture = vertical_texture

func set_horizontal():
	gate_orientation = ORIENTATION.HORIZONTAL
	sprite.texture = horizontal_texture

func _on_Area2DLeft_entered(area):
	if !detecting_areas:
		return
	if area.name.begins_with("Fence"):
		fences_found[0] = true
	update_orientation()

func _on_Area2DRight_entered(area):
	if !detecting_areas:
		return
	if area.name.begins_with("Fence"):
		fences_found[1] = true
	update_orientation()

func _on_Area2DUp_entered(area):
	if !detecting_areas:
		return
	if area.name.begins_with("Fence"):
		fences_found[2] = true
	update_orientation()

func _on_Area2DDown_entered(area):
	if !detecting_areas:
		return
	if area.name.begins_with("Fence"):
		fences_found[3] = true
	update_orientation()


func _on_Area2DLeft_exited(area):
	if !detecting_areas:
		return
	if area.name.begins_with("Fence"):
		fences_found[0] = false
	update_orientation()

func _on_Area2DRight_exited(area):
	if !detecting_areas:
		return
	if area.name.begins_with("Fence"):
		fences_found[1] = false
	update_orientation()

func _on_Area2DUp_exited(area):
	if !detecting_areas:
		return
	if area.name.begins_with("Fence"):
		fences_found[2] = false
	update_orientation()

func _on_Area2DDown_exited(area):
	if !detecting_areas:
		return
	if area.name.begins_with("Fence"):
		fences_found[3] = false
	update_orientation()


func update_orientation():
	if fences_found[0] and fences_found[1]:
		set_horizontal()
	elif fences_found[2] and fences_found[3]:
		set_vertical()
	elif !fences_found[0] and !fences_found[1] and (fences_found[2] or fences_found[3]):
		set_vertical()
	else:
		set_horizontal()

func update_fences():
	var collision_objects = []
	print(fence_collision_areas)
	for collision_area in fence_collision_areas:
		collision_objects += collision_area.get_overlapping_bodies()
	for collision_object in collision_objects:
		if collision_object.name.begins_with("Fence"):
			collision_object.gate_built(get_global_position())
	yield(get_tree(), "idle_frame")

	detecting_areas = true

func built():
	add_astar_obstacles()
	dismantlable = true
	movable = true
	collision_build_indicator.visible = false
	collision_shape_obstruction.scale = Vector2(1,1)
	z_index = 5

	detecting_areas = false
	update_fences()
