extends Node2D

const TILE_SIZE = 16
const SlotClass = preload("res://Scripts/HotbarSlot.gd")
const SlotObject = preload("res://Scenes/UI/HotbarSlot.tscn")
const dust_effect_scene = preload("res://Scenes/Effects/LandingDustEffect.tscn")
const build_select_indicator_scene = preload("res://Scenes/UI/BuildSelectIndicator.tscn")

var build_select_indicator

enum HotbarOrientation {HORIZONTAL, VERTICAL}
var orientation = HotbarOrientation.HORIZONTAL

enum BuildState {SELECTING_ITEM, BUILDING, BUILDING_FENCE, DISMANTLING, DISMANTLE_SELECT, MOVING_OBJECT, MOVING_FENCE}
var build_state = BuildState.SELECTING_ITEM

var positions_array = [Vector2(160, 148), Vector2(12, 80)]

var build_color_clear = Color(0,1,0,1)
var build_color_blocked = Color(1,0,0,1)
var collision_indicator : ColorRect

var active = false
var moved = false

var active_item_slot_index : int = -1
var active_item
var held_item_object : Node = null
var active_build_object
var object_placeable : bool = false
var dismantle_object_hovered = null

var cursor_location : Vector2 = Vector2(0,0)

var fence_tilemap
var fence_initial_position
var fence_held = false
var fence_id = -1
var fence_hovered = false
var fence_temp_drawn = false
var astar

var object_shaking : bool = false
export var shake_amplitude_initial : float = 2.0
export var shake_amplitude : float = 2.0
var shake_duration : float = 0.0
var shake_speed : float = 48.0
var shake_object_offset_base : Vector2

var held_item_slot : SlotClass = null
var mouse_hovered_slot : SlotClass = null

var PlayerInventory
var player

onready var tween = $Tween
onready var anim = $AnimationPlayer
onready var hotbar_slots = $HotbarSlots
onready var active_item_label = $ActiveItemLabel
onready var slots = hotbar_slots.get_children()
onready var dismantle_button = $DismantleButton

func _process(delta):
	if build_state == BuildState.SELECTING_ITEM:
		process_player_input_selecting(delta)
	
	elif build_state == BuildState.BUILDING:
		process_player_input_building(delta)

	elif build_state == BuildState.BUILDING_FENCE:
		process_player_input_building_fence(delta)
	
	elif build_state == BuildState.DISMANTLING:
		process_player_input_dismantling(delta)
	
	elif build_state == BuildState.DISMANTLE_SELECT:
		process_player_input_dismantle_select(delta)
	
	elif build_state == BuildState.MOVING_FENCE:
		process_player_input_moving_fence(delta)
	
	if object_shaking:
		shake_duration += delta * shake_speed
		active_build_object.sprite.offset = shake_object_offset_base + Vector2(shake_amplitude * cos(shake_duration), 0)

func process_player_input_selecting(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		disappear()
	
	if Input.is_action_just_pressed("ui_left"):
		if active_item_slot_index <= 0:
			if slots.size() != 0:
				slots[active_item_slot_index].deselected()
			active_item_slot_index = -1
			build_state = BuildState.DISMANTLE_SELECT
			dismantle_button.material = load("res://Shaders/OutlineShaderRG.tres")
		else:
			_slot_selected(slots[active_item_slot_index - 1])
	elif Input.is_action_just_pressed("ui_right"):
		if active_item_slot_index == slots.size() - 1:
			return
		else:
			_slot_selected(slots[active_item_slot_index + 1])
	elif Input.is_action_just_pressed("ui_accept"):
		if active_item != null:
			if active_item is BuildableFenceItem:
				enter_building_fence_state()
			else:
				enter_building_state()
	
	if held_item_object != null && Input.is_action_just_released("left_click"):
		_held_item_released()
	elif held_item_object:
		held_item_object.global_position = get_global_mouse_position()
	
	if Input.is_action_just_released("Hotbar1"):
		if slots.size() < 1:
			return
		assign_active_item(0)
	elif Input.is_action_just_released("Hotbar2"):
		if slots.size() < 2:
			return
		assign_active_item(1)
	elif Input.is_action_just_released("Hotbar3"):
		if slots.size() < 3:
			return
		assign_active_item(2)
	elif Input.is_action_just_released("Hotbar4"):
		if slots.size() < 4:
			return
		assign_active_item(3)
	elif Input.is_action_just_released("Hotbar5"):
		if slots.size() < 5:
			return
		assign_active_item(4)
	elif Input.is_action_just_released("Hotbar6"):
		if slots.size() < 6:
			return
		assign_active_item(5)
	elif Input.is_action_just_released("Hotbar7"):
		if slots.size() < 7:
			return
		assign_active_item(6)
	elif Input.is_action_just_released("Hotbar8"):
		if slots.size() < 8:
			return
		assign_active_item(7)

func process_player_input_building(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		object_shaking = false
		enter_selecting_state()
		return
	
	if Input.is_action_just_pressed("ui_accept") and object_placeable:
		yield(get_tree(), 'idle_frame')
		if (active_build_object.get_overlapping_areas().size() + active_build_object.get_overlapping_bodies().size()) == 0:
			build_object()
			return
	
	elif Input.is_action_just_pressed("ui_accept") and !object_placeable and !object_shaking:
		shake_object_offset_base = active_build_object.sprite.offset
		object_shaking = true
		tween.interpolate_property(self, "shake_amplitude",
		shake_amplitude_initial, 0.0, 0.25,
		Tween.TRANS_LINEAR, Tween.EASE_OUT)
		tween.start()
		return
	
	var move_vector = Vector2(0,0)
	if Input.is_action_just_pressed('ui_left'):
		move_vector = Vector2(-TILE_SIZE,0)
	if Input.is_action_just_pressed('ui_right'):
		move_vector = Vector2(TILE_SIZE,0)
	if Input.is_action_just_pressed('ui_down'):
		move_vector = Vector2(0,TILE_SIZE)
	if Input.is_action_just_pressed('ui_up'):
		move_vector = Vector2(0,-TILE_SIZE)

	active_build_object.position += move_vector
	cursor_location = active_build_object.position
	update_player_facing()

	if (active_build_object.get_overlapping_areas().size() + active_build_object.get_overlapping_bodies().size()) != 0 or !active_build_object.visibility_notifier.is_on_screen():
		active_build_object.collision_build_indicator.modulate = build_color_blocked
		object_placeable = false
	else:
		active_build_object.collision_build_indicator.modulate = build_color_clear
		object_placeable = true

func process_player_input_building_fence(delta):
	
	if Input.is_action_just_pressed("ui_cancel"):
		object_shaking = false
		active_build_object = null
		enter_selecting_state()
		build_select_indicator.queue_free()
		
		if !astar.is_point_disabled(cursor_location):
			fence_tilemap.set_cellv(cursor_location/16, -1, false, false)
			fence_tilemap.update_dirty_quadrants()
			fence_tilemap.update_bitmask_area(cursor_location/16)
			fence_tilemap.clear_gates()
		return
		
	if Input.is_action_just_pressed("ui_accept"):
		yield(get_tree(), 'idle_frame')
		if !astar.is_point_disabled(cursor_location):
			build_fence()
		return
	
	var move_vector = Vector2(0,0)
	if Input.is_action_just_pressed('ui_left'):
		move_vector = Vector2(-TILE_SIZE,0)
	elif Input.is_action_just_pressed('ui_right'):
		move_vector = Vector2(TILE_SIZE,0)
	elif Input.is_action_just_pressed('ui_down'):
		move_vector = Vector2(0,TILE_SIZE)
	elif Input.is_action_just_pressed('ui_up'):
		move_vector = Vector2(0,-TILE_SIZE)
	else:
		return
	
	if fence_temp_drawn == true:
		fence_temp_drawn = false
		fence_tilemap.set_cellv(cursor_location/16, -1, false, false)
		fence_tilemap.update_dirty_quadrants()
		fence_tilemap.update_bitmask_area(cursor_location/16)
		fence_tilemap.clear_gates()

	build_select_indicator.moved_visible(move_vector)
	cursor_location += move_vector

	if !astar.is_point_disabled(cursor_location):
		fence_temp_drawn = true
		fence_tilemap.set_cellv(cursor_location/16, fence_id, false, false)
		fence_tilemap.update_dirty_quadrants()
		fence_tilemap.update_bitmask_area(cursor_location/16)
		fence_tilemap.clear_gates()

func process_player_input_dismantle_select(delta):
	if Input.is_action_just_pressed("ui_accept"):
		enter_dismantling_state()
	elif Input.is_action_just_pressed("ui_right") and slots.size() != 0:
		dismantle_button.material = null
		enter_selecting_state()
	elif Input.is_action_just_pressed("ui_cancel"):
		dismantle_button.material = null
		disappear()

func process_player_input_dismantling(delta):


	if Input.is_action_just_pressed("ui_accept"):
		if active_build_object != null:
			release_selected_object()
		elif dismantle_object_hovered != null:
			grab_object()
		return
	
	if Input.is_action_just_pressed("ui_cancel"):
		if active_build_object != null:
			release_selected_object()
			return
		   
		object_shaking = false
		if dismantle_object_hovered != null:
			if dismantle_object_hovered.name.begins_with("Fence"):
				pass
			else:
				dismantle_object_hovered.collision_build_indicator.visible = false
		build_select_indicator.queue_free()
		enter_selecting_state()
		if slots.size() != 0:
			dismantle_button.material = null
		return
	
	if Input.is_action_just_pressed("ui_triangle"):
		dismantle_object()
	
	var move_vector = Vector2(0,0)
	if Input.is_action_just_pressed('ui_left'):
		move_vector = Vector2(-TILE_SIZE,0)
	elif Input.is_action_just_pressed('ui_right'):
		move_vector = Vector2(TILE_SIZE,0)
	elif Input.is_action_just_pressed('ui_down'):
		move_vector = Vector2(0,TILE_SIZE)
	elif Input.is_action_just_pressed('ui_up'):
		move_vector = Vector2(0,-TILE_SIZE)
	else:
		return

	
	if active_build_object != null:
		build_select_indicator.moved_visible(move_vector)
		process_object_selected_move(move_vector)
	else:
		build_select_indicator.moved(move_vector)
		process_selection_indicator_move()

	cursor_location = build_select_indicator.get_global_position()

	update_player_facing()

func process_player_input_moving_fence(delta):

	if !fence_held or fence_id == -1:
		build_state = BuildState.DISMANTLING
	
	if Input.is_action_just_pressed("ui_cancel"):
		object_shaking = false
		enter_selecting_state()
		build_select_indicator.queue_free()
		
		if !astar.is_point_disabled(cursor_location):
			fence_tilemap.set_cellv(cursor_location/16, -1, false, false)
			fence_tilemap.update_dirty_quadrants()
			fence_tilemap.update_bitmask_area(cursor_location/16)
			fence_tilemap.clear_gates()
		return
	
	if Input.is_action_just_pressed("ui_accept"):
		if !astar.is_point_disabled(cursor_location):
			release_fence()
		return
	
	if Input.is_action_just_pressed("ui_triangle"):
		dismantle_fence()
		return
	
	var move_vector = Vector2(0,0)
	if Input.is_action_just_pressed('ui_left'):
		move_vector = Vector2(-TILE_SIZE,0)
	elif Input.is_action_just_pressed('ui_right'):
		move_vector = Vector2(TILE_SIZE,0)
	elif Input.is_action_just_pressed('ui_down'):
		move_vector = Vector2(0,TILE_SIZE)
	elif Input.is_action_just_pressed('ui_up'):
		move_vector = Vector2(0,-TILE_SIZE)
	else:
		return
	
	if fence_temp_drawn:
		fence_temp_drawn = false
		fence_tilemap.set_cellv(cursor_location/16, -1, false, false)
		fence_tilemap.update_dirty_quadrants()
		fence_tilemap.update_bitmask_area(cursor_location/16)
		fence_tilemap.clear_gates()

	build_select_indicator.moved_visible(move_vector)
	cursor_location += move_vector
	if !astar.is_point_disabled(cursor_location):
		fence_temp_drawn = true
		fence_tilemap.set_cellv(cursor_location/16, fence_id, false, false)
		fence_tilemap.update_dirty_quadrants()
		fence_tilemap.update_bitmask_area(cursor_location/16)
		fence_tilemap.clear_gates()


func release_selected_object():
	yield(get_tree(), 'idle_frame')
	
	if object_shaking:
		return
	
	if active_build_object.get_overlapping_areas().size() + active_build_object.get_overlapping_bodies().size() <= 1:
		active_build_object.object_released()
		active_build_object.collision_build_indicator.modulate = Color(1,1,1)
		active_build_object = null
		build_select_indicator.object_grabbed(false)
		player.build_object()

	else:
		shake_object_offset_base = active_build_object.sprite.offset
		object_shaking = true
		tween.interpolate_property(self, "shake_amplitude",
		shake_amplitude_initial, 0.0, 0.25,
		Tween.TRANS_LINEAR, Tween.EASE_OUT)
		tween.start()
		return


func grab_object():
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")

	if dismantle_object_hovered == null:
		return

	if dismantle_object_hovered.name.begins_with("Fence"):
		grab_fence()
	
	elif dismantle_object_hovered.movable:
		build_select_indicator.object_grabbed(true)
		active_build_object = dismantle_object_hovered
		active_build_object.object_grabbed()
		active_build_object.collision_build_indicator.modulate = build_color_clear

func grab_fence():
	fence_temp_drawn = true
	fence_initial_position = cursor_location
	astar.disable_obstructing_cells([cursor_location/16], false)
	fence_id = dismantle_object_hovered.get_cellv(cursor_location/16)
	build_select_indicator.object_grabbed(true)
	fence_held = true
	build_state = BuildState.MOVING_FENCE

func release_fence():
	
	player.build_object()
	astar.disable_obstructing_cells([cursor_location/16], true)
	
	var dust_effect = dust_effect_scene.instance()
	dust_effect.position = cursor_location
	get_tree().current_scene.add_child(dust_effect)

	build_select_indicator.object_grabbed(false)
	build_select_indicator.corners_show()

	build_state = BuildState.DISMANTLING
	fence_held = false

func dismantle_fence():
	# Here we need to remove the obstacle from the fence's initial position. If the current cursor location is not equal to the initial position
	if fence_held:
		astar.disable_obstructing_cells([fence_initial_position/16], false)
		
		if cursor_location == fence_initial_position:
			fence_tilemap.dismantle_cell(cursor_location, fence_id)
		
		else:
			if astar.is_point_disabled(cursor_location):
				fence_tilemap.dismantle_held_cell(cursor_location, fence_id)
			else:
				fence_tilemap.dismantle_cell(cursor_location, fence_id)

	else:
		astar.disable_obstructing_cells([cursor_location/16], false)
		fence_tilemap.dismantle_cell(cursor_location, fence_id)

	dismantle_object_hovered = null

	fence_held = false
	build_select_indicator.hide_hand()
	build_select_indicator.hand_sprite.frame = 1
	build_select_indicator.corners_show()

	process_selection_indicator_move()

func dismantle_object():
	var dismantle_object
	if dismantle_object_hovered != null:
		dismantle_object = dismantle_object_hovered
		if dismantle_object.name.begins_with("Fence"):
			dismantle_fence()
			return
	
		if !dismantle_object.dismantlable:
			return
		else:
			var dust_effect = dust_effect_scene.instance()
			dust_effect.position = dismantle_object.get_global_position() +  Vector2((dismantle_object.tile_dimensions.x - 1) * 8, (dismantle_object.tile_dimensions.y - 1) * 16)
			get_tree().current_scene.add_child(dust_effect)
			
			dismantle_object.dismantled()
			dismantle_object_hovered = null
			build_select_indicator.hide_hand()
			build_select_indicator.corners_show()
			build_select_indicator.object_grabbed(false)
			active_build_object = null
	
	elif active_build_object != null:
		dismantle_object = active_build_object
		
		if !dismantle_object.dismantlable:
			shake_object_offset_base = dismantle_object.sprite.offset
			object_shaking = true
			tween.interpolate_property(self, "shake_amplitude",
			shake_amplitude_initial, 0.0, 0.25,
			Tween.TRANS_LINEAR, Tween.EASE_OUT)
			tween.start()
		else:
			var dust_effect = dust_effect_scene.instance()
			dust_effect.position = dismantle_object.get_global_position() +  Vector2((dismantle_object.tile_dimensions.x - 1) * 8, (dismantle_object.tile_dimensions.y - 1) * 16)
			get_tree().current_scene.add_child(dust_effect)
			
			dismantle_object.dismantled()
			active_build_object = null
			build_select_indicator.hide_hand()
			build_select_indicator.corners_show()
			build_select_indicator.object_grabbed(false)

func process_object_selected_move(move_vector):
	active_build_object.position += move_vector
	build_select_indicator.show_hand()
	build_select_indicator.corners_hide()

	yield(get_tree(),"idle_frame")
	yield(get_tree(),"idle_frame")
	build_select_indicator.show_hand()

	if (active_build_object.get_overlapping_areas().size() + active_build_object.get_overlapping_bodies().size()) > 1:
		active_build_object.collision_build_indicator.modulate = build_color_blocked
		object_placeable = false
	
	else:
		active_build_object.collision_build_indicator.modulate = build_color_clear
		object_placeable = true

func process_selection_indicator_move():
	yield(get_tree(),"idle_frame")
	yield(get_tree(),"idle_frame")
	
	var colliding_objects = build_select_indicator.collision_area.get_overlapping_areas() + build_select_indicator.collision_area.get_overlapping_bodies()
	
	if colliding_objects.size() == 0:
		fence_hovered = false
		
		if dismantle_object_hovered != null:
			if dismantle_object_hovered.name.begins_with("Fence"):
				build_select_indicator.corners_show()
				dismantle_object_hovered = null
			else:
				dismantle_object_hovered.collision_build_indicator.visible = false
				dismantle_object_hovered = null
				build_select_indicator.corners_show()

		else:
			build_select_indicator.corners_show()
		
		
	# There is a hovered object.
	elif colliding_objects.size() != 0:
		# The hovered object is different than the currently hovered object.
		if dismantle_object_hovered != colliding_objects[0]:
			# Just hovered over an object, but there was not one before. 
			if dismantle_object_hovered == null:
				dismantle_object_hovered = colliding_objects[0]
				
				if dismantle_object_hovered.name.begins_with("Fence"):
					fence_tile_map_hovered()
				else:
					fence_hovered = false
					new_object_hovered()

			# Just hovered over a new object, different from the previous object.
			else:
				if !dismantle_object_hovered.name.begins_with("Fence"):
					dismantle_object_hovered.collision_build_indicator.visible = false
				
				if colliding_objects[0].name.begins_with("Fence"):
					dismantle_object_hovered = colliding_objects[0]
					fence_tile_map_hovered()
				else:
					fence_hovered = false
					dismantle_object_hovered = colliding_objects[0]

					new_object_hovered()

		
		# The hovered object is the same as the currently hovered object.
		else:
			if dismantle_object_hovered.name.begins_with("Fence"):
				fence_tile_map_hovered()
			
			elif dismantle_object_hovered.movable:
				build_select_indicator.show_hand()

func fence_tile_map_hovered():
	build_select_indicator.show_hand()
	build_select_indicator.corners_show()
	fence_hovered = true

func new_object_hovered():
	dismantle_object_hovered.collision_build_indicator.visible = true
	dismantle_object_hovered.collision_build_indicator.rect_size = Vector2(16 * dismantle_object_hovered.tile_dimensions.x, 16 * dismantle_object_hovered.tile_dimensions.y)
	build_select_indicator.corners_hide()
	
	if dismantle_object_hovered.movable:
		build_select_indicator.show_hand()

func build_object():
	player.build_object()
	object_shaking = false

	var dust_effect = dust_effect_scene.instance()
	dust_effect.position = active_build_object.get_global_position() +  Vector2((active_build_object.tile_dimensions.x - 1) * 8, (active_build_object.tile_dimensions.y - 1) * 16)
	get_tree().current_scene.add_child(dust_effect)
	
	active_build_object.built()
	active_build_object = null
	slots[active_item_slot_index].item_used()
	enter_selecting_state()

func build_fence():
	fence_temp_drawn = false
	player.build_object()
	astar.disable_obstructing_cells([cursor_location/16], true)
	
	var dust_effect = dust_effect_scene.instance()
	dust_effect.position = cursor_location
	get_tree().current_scene.add_child(dust_effect)
	
	if slots[active_item_slot_index].item.current_stack_size == 1:
		slots[active_item_slot_index].item_used()
		build_select_indicator.queue_free()
		enter_selecting_state()
	else:
		slots[active_item_slot_index].item_used()

func update_player_facing():
	var difference_vector = cursor_location - player.get_global_position() + player.grid_offset
	var difference_angle = rad2deg((player.get_global_position() - player.grid_offset).angle_to_point(cursor_location))
	if difference_angle < 135 and difference_angle > 45:
		player.set_orientation(Vector2(0,-1))
	elif difference_angle < 45 and difference_angle > -45:
		player.set_orientation(Vector2(-1,0))
	elif difference_angle < -45 and difference_angle > -135:
		player.set_orientation(Vector2(0,1))
	else:
		player.set_orientation(Vector2(1,0))

func _slot_selected(slot):
	slots[active_item_slot_index].deselected()
	active_item = slot.item_object.item

	active_item_label.set_text(active_item)

	active_item_slot_index = slot.slot_index
	slots[active_item_slot_index].selected()

func _slot_object_held(slot, item_object):
	print('object being held')

	held_item_slot = slot
	held_item_object = item_object
	held_item_object.global_position = get_global_mouse_position()
	
func _slot_object_clicked(slot, item_object):
	pass

func _held_item_released():
	yield(get_tree(), "idle_frame")
	
	if mouse_hovered_slot != held_item_slot && mouse_hovered_slot != null:
		if mouse_hovered_slot.item == null:
			move_held_item_to_slot()
		else:
			swap_items()
	
	return_held_item_to_slot()

func swap_items():
	var temp_item = held_item_object.item
	
	held_item_slot.pickFromSlot()
	held_item_slot.putIntoSlot(mouse_hovered_slot.item_object.item)
	
	mouse_hovered_slot.pickFromSlot()
	mouse_hovered_slot.putIntoSlot(temp_item)

	held_item_slot.deselected()
	return_held_item_to_slot()
	
	active_item_slot_index = mouse_hovered_slot.slot_index
	active_item = mouse_hovered_slot.item

	held_item_object = null
	held_item_slot = null
	mouse_hovered_slot.selected()
	active_item_label.set_text(active_item.name)

func clear_active_item():
	slots[active_item_slot_index].clear_active()
	active_item = null
	active_item_slot_index = -1
	active_item_label.clear_text()

func assign_active_item(hotbar_slot):
	if slots[hotbar_slot].item != null:
		slots[active_item_slot_index].deselected()
		slots[hotbar_slot].selected()
		active_item_slot_index = hotbar_slot
		active_item = slots[active_item_slot_index].item
		active_item_label.set_text(active_item)
	else:
		slots[active_item_slot_index].deselected()
		slots[hotbar_slot].selected()
		active_item_slot_index = hotbar_slot
		active_item = null
		
		active_item_label.clear_text()

func _slot_mouse_entered(slot):
	mouse_hovered_slot = slot
	if mouse_hovered_slot.item != null:
		active_item_label.set_text(mouse_hovered_slot.item.name)
	else:
		active_item_label.clear_text()

func _slot_mouse_exited(slot):
	mouse_hovered_slot = null

func update_item_label_selected():
	active_item_label.set_text(active_item.name)

func return_held_item_to_slot():
	if held_item_object != null and held_item_object != null:
		held_item_slot.mouse_filter = 0
		held_item_object.position = Vector2(8,8)
		held_item_object = null
		held_item_slot = null

func move_held_item_to_slot():
	mouse_hovered_slot.putIntoSlot(held_item_object.item)
	held_item_object.position = Vector2(8, 8)
	held_item_slot.mouse_filter = 1
	held_item_slot.pickFromSlot()
	
	active_item_slot_index = mouse_hovered_slot.slot_index
	active_item = mouse_hovered_slot.item
	held_item_slot.deselected()
	held_item_object = null
	held_item_slot = null
	mouse_hovered_slot.selected()
	active_item_label.set_text(active_item.name)

func _on_hotbar_item_updated(hotbar_position, item):
	var item_index = -1
	for slot in slots:
		if slot.item == item:
			item_index = slot.slot_index
	
	if item_index != -1:
		if item_index != hotbar_position:
			slots[item_index].clear_item()
			if item_index == active_item_slot_index:
				clear_active_item()
	
	if hotbar_position == active_item_slot_index:
		clear_active_item()
	
	slots[hotbar_position].item_updated(item)

func left_click_empty_slot(slot: SlotClass):
	print('empty slot left clicked')
	PlayerInventory.add_hotbar_item(held_item_object, slot)
	slot.putIntoSlot(held_item_object.item)
	held_item_object.position = Vector2(8, 8)
	held_item_object.clear_item()
#	held_item_object.visible = true
	held_item_object = null
	held_item_slot.pickFromSlot()
	held_item_slot = null

func left_click_different_item(event: InputEvent, slot: SlotClass):
	print('different item slot left clicked')
	var temp_item = held_item_object.item
	
	held_item_slot.pickFromSlot()
	held_item_slot.putIntoSlot(slot.item_object.item)
	
	slot.pickFromSlot()
	slot.putIntoSlot(temp_item)
	held_item_object.position = Vector2(8, 8)
	held_item_object = null
	held_item_slot = null

func left_click_same_item(slot: SlotClass):
	print('same item slot left clicked')
	return

func initialize():
	astar = get_tree().current_scene.current_scene.A_star
	fence_tilemap = get_node("../../").current_scene.fence_tilemap
	player = get_node("../../").player
	var inventory = get_node("../InventoryMaster").inventory
	inventory.connect("buildable_item_entry_created", self, "new_buildable_object_added")
	var items = get_node("../InventoryMaster").inventory.get_buildable_items()
	
	for i in range(items.size()):
		var slot = SlotObject.instance()
		hotbar_slots.add_child(slot)
		slot.putIntoSlot(items[i])
	
	slots = hotbar_slots.get_children()
	
	for i in range(slots.size()):
		slots[i].connect("slot_object_held", self, "_slot_object_held")
		slots[i].connect("slot_object_clicked", self, "_slot_object_clicked")
		slots[i].connect("held_item_released", self, "_held_item_released")
		slots[i].connect("slot_mouse_entered", self, "_slot_mouse_entered")
		slots[i].connect("slot_mouse_exited", self, "_slot_mouse_exited")
		slots[i].connect("slot_selected", self, "_slot_selected")
		slots[i].connect("hotbar_item_quantity_depleted", self, "_on_hotbar_item_quantity_depleted")
		slots[i].slotType = SlotClass.SlotType.HOTBAR
		slots[i].slot_index = i
		slots[i].hotbar_label.text = String(i + 1)
	
	if slots.size() == 0:
		build_state = BuildState.DISMANTLE_SELECT
		dismantle_button.grab_focus()
		dismantle_button.material = load("res://Shaders/OutlineShaderRG.tres")

func new_buildable_object_added(item):
	var slot = SlotObject.instance()
	hotbar_slots.add_child(slot)
	slot.putIntoSlot(item)
	slot.connect("slot_object_held", self, "_slot_object_held")
	slot.connect("slot_object_clicked", self, "_slot_object_clicked")
	slot.connect("held_item_released", self, "_held_item_released")
	slot.connect("slot_mouse_entered", self, "_slot_mouse_entered")
	slot.connect("slot_mouse_exited", self, "_slot_mouse_exited")
	slot.connect("slot_selected", self, "_slot_selected")
	slot.connect("hotbar_item_quantity_depleted", self, "_on_hotbar_item_quantity_depleted")
	slot.slotType = SlotClass.SlotType.HOTBAR
	slot.slot_index = hotbar_slots.get_child_count() - 1
	slot.hotbar_label.text = String(hotbar_slots.get_child_count())

	slots = hotbar_slots.get_children()

func appear():
	anim.play('appear')
	tween.interpolate_property(self, 'position',
	position, position - Vector2(0,4), 0.2,
	Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	tween.start()

func disappear():
	object_shaking = false
	get_node('../..').player.finished_building()
	get_parent().enable_hotbar()
	
	anim.play('disappear')
	tween.interpolate_property(self, 'position',
	position, position + Vector2(0,4), 0.2,
	Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	tween.start()

func appear_finished():
	active = true
	if slots.size() != 0:
		slots[0].selected()
		_slot_selected(slots[0])
		build_state = BuildState.SELECTING_ITEM
	else:
		build_state = BuildState.DISMANTLE_SELECT

func disappear_finished():
	queue_free()

func enter_building_state():
	build_state = BuildState.BUILDING
	var build_object = load(active_item.object_path).instance()
	get_node("../../").current_scene.ysort.buildings.add_child(build_object)

	build_object.enter_building_state()

	if (build_object.get_overlapping_areas().size() + build_object.get_overlapping_bodies().size()) != 0:
		build_object.collision_build_indicator.modulate = build_color_blocked
		object_placeable = false
	else:
		build_object.collision_build_indicator.modulate = build_color_clear
		object_placeable = true
	
	build_object.visible = true
	build_object.collision_build_indicator.visible = true
	
	if build_object.tile_dimensions.x > 1 and player.facing_vector.x < 0:
		build_object.set_global_position(player.get_global_position() + build_object.tile_dimensions.x * player.facing_vector - player.grid_offset)
	elif build_object.tile_dimensions.y > 1 and player.facing_vector.y < 0:
		build_object.set_global_position(player.get_global_position() + build_object.tile_dimensions.y * player.facing_vector - player.grid_offset)
	
	else:
		build_object.set_global_position(player.get_global_position() + player.facing_vector - player.grid_offset)
		
	active_build_object = build_object
	cursor_location = active_build_object.get_global_position()

func enter_building_fence_state():
	build_state = BuildState.BUILDING_FENCE
	fence_id = active_item.tileset_id
	fence_tilemap = get_node("../../").current_scene.fence_tilemap
	var build_position = (player.get_global_position() + player.facing_vector - player.grid_offset)
	build_position = astar.get_closest_point(build_position, false)
	
	fence_tilemap.set_cellv(build_position, fence_id, false, false)
	fence_tilemap.update_dirty_quadrants()
	fence_tilemap.update_bitmask_area(build_position)
	fence_tilemap.clear_gates()
	cursor_location = build_position * 16

	build_select_indicator = build_select_indicator_scene.instance()
	get_node("../../").current_scene.ysort.add_child(build_select_indicator)
	build_select_indicator.set_global_position(cursor_location)

	fence_temp_drawn = true
	build_select_indicator.corners.visible = true

func enter_selecting_state():
	if active_build_object != null:
		active_build_object.queue_free()
	
	if slots.size() != 0:
		_slot_selected(slots[0])
	else:
		build_state = BuildState.DISMANTLE_SELECT
		dismantle_button.material = load("res://Shaders/OutlineShaderRG.tres")
		return
	build_state = BuildState.SELECTING_ITEM

	dismantle_button.release_focus()
	dismantle_button.disabled = false

func enter_dismantling_state():
	dismantle_button.disabled = true
	build_state = BuildState.DISMANTLING
	build_select_indicator = build_select_indicator_scene.instance()
	get_node("../../").current_scene.ysort.add_child(build_select_indicator)
	build_select_indicator.set_global_position(player.get_global_position() + player.facing_vector - player.grid_offset)

	build_select_indicator.corners.visible = true
	cursor_location = build_select_indicator.get_global_position()
	process_selection_indicator_move()

func _on_hotbar_item_quantity_depleted(slot):
	slots.erase(slot)
	slot.queue_free()
	reassign_slots()

func reassign_slots():
	for i in range(slots.size()):
		slots[i].slot_index = i
		slots[i].hotbar_label.text = String(i + 1)

func _on_tween_completed(object, key):
	object_shaking = false
