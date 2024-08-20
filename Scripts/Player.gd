extends KinematicBody2D

class_name Player

export var walk_speed = 4.0
export var run_speed = 7.0
export var jump_speed = 4.0
export var door_speed = 2.0
var current_speed = 4.0

export (Vector2) var tile_dimensions = Vector2(1,1)
var obstructing : = true
var light_level : float = 1.0

var jump_distance = 2.0

const TILE_SIZE = 16

var speed_base : float = 0.015625

var shaded : bool = false

var initial_position = Vector2(0,0)
var input_direction = Vector2(0,1)
var stop_input : bool = false
var is_moving = false
var percent_moved_to_next_tile = 0.0

enum PlayerState {IDLE, TURNING, WALKING, RUNNING, ACTING, BUILDING}
enum FacingDirection {LEFT, RIGHT, UP, DOWN}

var player_state = PlayerState.IDLE
var facing_direction = FacingDirection.DOWN

var selected_character = 0
var jumping_over_ledge : bool = false

var equipped_item = null

var tile_location_target = Vector2(0,0)
var tile_location_current = Vector2(0,0)

var facing_vector = Vector2(0,0)
var item_pickup_locations = [[Vector2(-12, -18)], [Vector2(12, -18)], [Vector2(0, -10), Vector2(0, -20)], [Vector2(0, -16)]]

var grid_offset : Vector2 = Vector2(0,2)

var known_food_recipes : Array = []
var can_eat = true

const landing_dust_effect_scene = preload("res://Scenes/Effects/LandingDustEffect.tscn")
const stats = preload("res://Resources/PlayerResources/Stats.tres")

onready var sprite = $Sprite
onready var sprite_item = $SpriteItem
onready var shadow = $Sprite/PlayerShadow
onready var anim = $AnimationPlayer
onready var anim_tree = $AnimationTree
onready var anim_state = anim_tree.get('parameters/playback')
onready var anim_doors = $AnimationPlayerDoors

onready var ray = $BlockingRayCast2D
onready var ledge_ray = $LedgeRayCast2D
onready var door_ray = $DoorRayCast2D

onready var interactable_collider = $InteractableCollider
onready var plant_collider = $PlantCollider
onready var tilled_earth_collider = $TilledEarthCollider
onready var water_collider = $WaterCollider
onready var traversable_obstruction_collider = $TraversableObstructionCollider

onready var tween = $Tween
onready var camera = $Camera2D

signal tween_complete()

signal player_moving_signal()
signal player_stopped_signal()

signal player_opening_door_signal()
signal player_entered_door_signal()

signal food_capacity_changed(food_capacity)
signal food_current_changed(food_current)
signal digestion_efficiency_changed(digestion_efficiency)
signal digestion_rate(digestion_rate)
signal energy_generated(energy)

func _ready():

	tile_location_current = position - grid_offset
	
	set_physics_process(false)
	sprite.visible = true
	initial_position = position
	anim_tree.active = true
	shadow.visible = false
	
	stats.connect("current_energy_changed", get_tree().current_scene.get_node("UI/FuelGauge"), "_on_current_energy_changed")
	stats.connect("max_energy_changed", get_tree().current_scene.get_node("UI/FuelGauge"), "_on_max_energy_changed")
	stats.connect("display_initialized", get_tree().current_scene.get_node("UI/FuelGauge"), "_display_initialized")
	stats.connect("currency_changed", get_tree().current_scene.get_node("UI/CurrencyDisplay"), "_on_currency_changed")
	stats.initialize_display()
	
	anim_tree.set('parameters/CarExit/blend_position', input_direction)
	anim_tree.set('parameters/Idle/blend_position', input_direction)
	anim_tree.set('parameters/Walk/blend_position', input_direction)
	anim_tree.set('parameters/Turn/blend_position', input_direction)

func _process(delta):
	stats._process(delta)

func _physics_process(delta):
	if player_state == PlayerState.TURNING or player_state == PlayerState.ACTING or stop_input:
		return
	elif is_moving == false:
		process_player_input()
	elif input_direction != Vector2.ZERO:
		if Input.is_action_pressed("shift_mod"):
			anim_state.travel('Run')
			current_speed = run_speed
		else:
			anim_state.travel('Walk')
			current_speed = walk_speed
		
		move(delta)
	else:
		anim_state.travel('Idle')
		is_moving = false

func process_player_input():
	if Input.is_action_pressed("ui_inventory"):
		open_inventory()
		return

	if Input.is_action_just_pressed("ui_accept"):

		if equipped_item != null:
			var item_picked_up = attempt_item_pickup()
			if item_picked_up:
				return
			
			var use_animations = equipped_item.get_use_animations()
			
			var item_used = use_equipped_item()
			
			if item_used:
				act(use_animations[0])
				stats.lose_energy(equipped_item.energy_cost)
				return
			else:
			
				var interactable_object = interactable_object_check()
				if interactable_object != null:
					interactable_object.player_interacted(self)
					
					return
				else:
					act(use_animations[1])
					return
		else:
			var interactable_object = interactable_object_check()
			if interactable_object != null:
				interactable_object.player_interacted(self)
				return
	
	if input_direction.y == 0:
		input_direction.x = int(Input.is_action_pressed('ui_right')) - int(Input.is_action_pressed('ui_left'))
	if input_direction.x == 0:
		input_direction.y = int(Input.is_action_pressed('ui_down')) - int(Input.is_action_pressed('ui_up'))
	
	if input_direction != Vector2.ZERO:
		anim_tree.set('parameters/Idle/blend_position', input_direction)
		anim_tree.set('parameters/Walk/blend_position', input_direction)
		anim_tree.set('parameters/Run/blend_position', input_direction)
		anim_tree.set('parameters/Turn/blend_position', input_direction)
		anim_tree.set('parameters/CarExit/blend_position', input_direction)
		anim_tree.set('parameters/Kneel/blend_position', input_direction)
		anim_tree.set('parameters/Swing/blend_position', input_direction)
		anim_tree.set('parameters/Chop/blend_position', input_direction)
		anim_tree.set('parameters/Hoe/blend_position', input_direction)
		anim_tree.set('parameters/Pickup/blend_position', input_direction)
		anim_tree.set('parameters/KneelStay/blend_position', input_direction)
		anim_tree.set('parameters/KneelStand/blend_position', input_direction)
		anim_tree.set('parameters/SwingHold/blend_position', input_direction)
		anim_tree.set('parameters/SwingFinish/blend_position', input_direction)
		anim_tree.set('parameters/Eat/blend_position', input_direction)
		anim_tree.set('parameters/Poke/blend_position', input_direction)
		
		if need_to_turn():
			player_state = PlayerState.TURNING
			anim_state.travel('Turn')
		else:
			initial_position = position
			is_moving = true
	else:
		anim_state.travel('Idle')

func use_equipped_item():
	var item_used = equipped_item.used(self,get_tree().current_scene.current_scene)
	return item_used

func attempt_item_pickup():
	var interactable_object = interactable_object_check()
	if interactable_object != null:
		if interactable_object.has_method("picked_up"):
			interactable_object.picked_up(self)
			return true

func open_inventory():
	get_tree().current_scene.get_node("UI").open_inventory()
	stop_input = true
	set_physics_process(false)

func equip_item(new_item):
	equipped_item = new_item
	if equipped_item is ToolItem:
		sprite_item.texture = equipped_item.character_equipped_spritesheet
		if equipped_item.custom_cursor != null:
			Input.set_custom_mouse_cursor(equipped_item.custom_cursor)
		else:
			Input.set_custom_mouse_cursor(load("res://Assets/UI/Cursor/hand_base.png"))
	else:
		sprite_item.texture = null
		Input.set_custom_mouse_cursor(load("res://Assets/UI/Cursor/hand_base.png"))

func unequip_item():
	equipped_item = null

func interactable_object_check():
	var desired_interact = Vector2(0,0)
	
	if facing_direction == FacingDirection.LEFT:
		desired_interact = Vector2(-1,0) * TILE_SIZE / 2
	elif facing_direction == FacingDirection.RIGHT:
		desired_interact = Vector2(1,0) * TILE_SIZE / 2
	elif facing_direction == FacingDirection.UP:
		desired_interact = Vector2(0,-1) * TILE_SIZE / 2
	elif facing_direction == FacingDirection.DOWN:
		desired_interact = Vector2(0,1) * TILE_SIZE / 2
	
	move_colliders(facing_vector)
	
	var colliders = interactable_collider.get_overlapping_areas()
	colliders += interactable_collider.get_overlapping_bodies()
	var collider
	if colliders.size() != 0:
		for colliding_obj in colliders:
			if colliding_obj.has_method("player_interacted"):
				collider = colliding_obj
	
	return collider

func closed_gate_check():
	var desired_interact = Vector2(0,0)
	
	if facing_direction == FacingDirection.LEFT:
		desired_interact = Vector2(-1,0) * TILE_SIZE / 2
	elif facing_direction == FacingDirection.RIGHT:
		desired_interact = Vector2(1,0) * TILE_SIZE / 2
	elif facing_direction == FacingDirection.UP:
		desired_interact = Vector2(0,-1) * TILE_SIZE / 2
	elif facing_direction == FacingDirection.DOWN:
		desired_interact = Vector2(0,1) * TILE_SIZE / 2
	
	move_colliders(facing_vector)
	
	var colliders = interactable_collider.get_overlapping_areas()
	colliders += interactable_collider.get_overlapping_bodies()
	var colliding_gate = false
	if colliders.size() != 0:
		for colliding_obj in colliders:
			if colliding_obj is Gate:
				if colliding_obj.gate_state == 1:
					colliding_gate = true
	
	return colliding_gate

func need_to_turn():
	var new_facing_direction
	if input_direction.x < 0:
		new_facing_direction = FacingDirection.LEFT
		facing_vector = Vector2(-16, 0)
		
	if input_direction.x > 0:
		new_facing_direction = FacingDirection.RIGHT
		facing_vector = Vector2(16, 0)
		
	if input_direction.y > 0:
		new_facing_direction = FacingDirection.DOWN
		facing_vector = Vector2(0, 16)
		
	if input_direction.y < 0:
		new_facing_direction = FacingDirection.UP
		facing_vector = Vector2(0, -16)
	
	move_colliders(facing_vector)
	
	if facing_direction != new_facing_direction:
		facing_direction = new_facing_direction
		return true
	facing_direction = new_facing_direction
	return false

func finished_turning():
	player_state = PlayerState.IDLE

func move(delta):
	var desired_step : Vector2 = input_direction * TILE_SIZE / 2
	ray.cast_to = desired_step
	ray.force_raycast_update()
	
	ledge_ray.cast_to = desired_step
	ledge_ray.force_raycast_update()
	
	door_ray.cast_to = desired_step
	door_ray.force_raycast_update()
	
#	move_colliders(facing_vector)
	
	if door_ray.is_colliding():
		var door = door_ray.get_collider()
		
		if door.open == false and !door.locked and percent_moved_to_next_tile == 0.0:
			door.open_door()
			is_moving = false
			percent_moved_to_next_tile = 0.0
			return
		
		# Future Lock Functionality
		elif door.locked:
			is_moving = false
			percent_moved_to_next_tile = 0.0
			door.nudged()
			return
		
		percent_moved_to_next_tile += door_speed * delta
		if percent_moved_to_next_tile >= 1.0:
			position = initial_position + (input_direction * TILE_SIZE)
			percent_moved_to_next_tile = 0.0
			is_moving = false
			stop_input = true
			anim.play("Disappear")
			camera.clear_current()
			door.door_entered()
			tile_location_departed()
		else:
			if anim_doors.current_animation != door.entrance_anim:
				pass
#				anim_doors.play(door.entrance_anim)
			
			is_moving = true
			position = initial_position + (input_direction * TILE_SIZE * percent_moved_to_next_tile)
	
	elif ledge_ray.is_colliding() or jumping_over_ledge:
		ledge_check(delta)
	
	elif water_collider.get_overlapping_bodies().size() != 0 and percent_moved_to_next_tile == 0:
		is_moving = false
	
	elif !ray.is_colliding():
		if percent_moved_to_next_tile == 0:
			tile_location_current = position - grid_offset
			tile_location_target = position + facing_vector - grid_offset
			if !tile_location_check():
				is_moving = false
				return
			emit_signal("player_moving_signal")
		percent_moved_to_next_tile += current_speed * delta
		if percent_moved_to_next_tile >= 1.0:
			tile_location_arrived()
			position = initial_position + (TILE_SIZE * input_direction)
			percent_moved_to_next_tile = 0.0
			is_moving  = false

			emit_signal("player_stopped_signal")
		else:
			position = initial_position + (TILE_SIZE * input_direction * percent_moved_to_next_tile)
	else:
		is_moving = false

func tile_location_check():
	var astar = get_node("../../../Astar")

#	print('player target location: ', tile_location_target)

	var colliding_gate = closed_gate_check()
	if colliding_gate:
		return false

	if astar.is_point_disabled(tile_location_target):
		return false
	elif !astar.are_points_connected(tile_location_current, tile_location_target):
		return false
	else:
		astar.player_arrived_tile(tile_location_target/16)
		tile_location_departed()
		return true


func tile_location_departed():
	var astar = get_node("../../../Astar")
	yield(get_tree().create_timer(0.1), "timeout")
	astar.player_departed_tile(tile_location_current/16)


func tile_location_arrived():
	var astar = get_node("../../../Astar")
	tile_location_current = tile_location_target


func move_colliders(facing_vector):
	var position_vector = Vector2(8,8) + facing_vector
	
	ray.cast_to = facing_vector
	ledge_ray.cast_to = facing_vector
	door_ray.cast_to = facing_vector
	
	ray.force_raycast_update()
	ledge_ray.force_raycast_update()
	door_ray.force_raycast_update()
	
	tilled_earth_collider.position = position_vector
	plant_collider.position = position_vector
	interactable_collider.position = position_vector
	water_collider.position = position_vector
	traversable_obstruction_collider.position = position_vector

func disable_colliders():
	ray.enabled = false
	ledge_ray.enabled = false
	door_ray.enabled = false
	
	tilled_earth_collider.monitorable = false
	tilled_earth_collider.monitoring = false
	plant_collider.monitorable = false
	plant_collider.monitoring = false
	water_collider.monitorable = false
	water_collider.monitoring = false
	traversable_obstruction_collider.monitorable = false
	traversable_obstruction_collider.monitoring = false
	interactable_collider.monitorable = false
	interactable_collider.monitoring = false
	

func enable_colliders():
	ray.enabled = true
	ledge_ray.enabled = true
	door_ray.enabled = true
	
	tilled_earth_collider.monitorable = true
	tilled_earth_collider.monitoring = true
	plant_collider.monitorable = true
	plant_collider.monitoring = true
	water_collider.monitorable = true
	water_collider.monitoring = true
	traversable_obstruction_collider.monitorable = true
	traversable_obstruction_collider.monitorable = true
	interactable_collider.monitorable = true
	interactable_collider.monitoring = true

func get_all_colliders(get_traversable_colliders):
	
	var colliding_objects = []
	move_colliders(facing_vector)
	
	for collider in water_collider.get_overlapping_bodies():
		colliding_objects.append(collider)

	if ray.is_colliding():
		colliding_objects.append(ray.get_collider())
	if ledge_ray.is_colliding():
		colliding_objects.append(ledge_ray.get_collider())

	if get_traversable_colliders:
		for collider in traversable_obstruction_collider.get_overlapping_areas():
			colliding_objects.append(collider)

	return colliding_objects

func ledge_check(delta):
	jump_distance = 2.0
	jump_speed = 4.0
	
	if !jumping_over_ledge:
		var collider_direction = ledge_ray.get_collider().name
		if facing_direction == FacingDirection.LEFT && !collider_direction.ends_with("Left"):
			is_moving = false
			percent_moved_to_next_tile = 0.0
			return
		elif facing_direction == FacingDirection.RIGHT && !collider_direction.ends_with("Right"):
			is_moving = false
			percent_moved_to_next_tile = 0.0
			return
		elif facing_direction == FacingDirection.UP && !collider_direction.ends_with("Up"):
			is_moving = false
			percent_moved_to_next_tile = 0.0
			return
		elif facing_direction == FacingDirection.DOWN && !collider_direction.ends_with("Down"):
			is_moving = false
			percent_moved_to_next_tile = 0.0
			return
	
	if facing_direction == FacingDirection.UP:
		jump_distance = 1.0
		jump_speed = 6.0
	else:
		jump_distance = 2.0
		jump_speed = 4.0
	
	ray.cast_to = facing_vector * jump_distance
	ray.force_raycast_update()
	if ray.is_colliding() and percent_moved_to_next_tile == 0.0:
		is_moving = false
		return
	
	if percent_moved_to_next_tile == 0.0:
		tile_location_departed()
	
	percent_moved_to_next_tile += jump_speed * delta
	if percent_moved_to_next_tile >= 2.0:
		position = initial_position + (input_direction * TILE_SIZE * jump_distance)
		percent_moved_to_next_tile = 0.0
		is_moving = false
		jumping_over_ledge = false
		
		var landing_dust_effect = landing_dust_effect_scene.instance()
		landing_dust_effect.position = position
		get_tree().current_scene.add_child(landing_dust_effect)
		
	else:
		if jump_distance == 1:
			shadow.jump_fast_down()
		else:
			shadow.jump_down()
		jumping_over_ledge = true
		
		var input
		
		if facing_direction == FacingDirection.LEFT:
			input = input_direction.x * TILE_SIZE * percent_moved_to_next_tile
			position.x = initial_position.x - ( 0.96 + 0.53 * input + 0.05 * pow(input,2))
		elif facing_direction == FacingDirection.RIGHT:
			input = input_direction.x * TILE_SIZE * percent_moved_to_next_tile
			position.x = initial_position.x + (0 - 0.53 * input + 0.05 * pow(input,2))
		elif facing_direction == FacingDirection.UP:
			input = input_direction.y * TILE_SIZE * percent_moved_to_next_tile
			position.y = initial_position.y + ( 0.96 + 0.53 * input + 0.05 * pow(input,1))
		elif facing_direction == FacingDirection.DOWN:
			input = input_direction.y * TILE_SIZE * percent_moved_to_next_tile
			position.y = initial_position.y + (-0.96 - 0.53 * input + 0.05 * pow(input,2))

func set_spawn(location : Vector2, direction : Vector2):
	set_orientation(direction)
	set_position(location)

func set_position(location):
	position = location
	tile_location_current = position - grid_offset
	tile_location_target = position + facing_vector - grid_offset
	get_node("../../../Astar").player_arrived_tile(tile_location_current/16)

func set_orientation(direction):
	facing_vector = direction * 16
	
	direction = direction.normalized()
	anim_tree.set('parameters/CarExit/blend_position', direction)
	anim_tree.set('parameters/Idle/blend_position', direction)
	anim_tree.set('parameters/Walk/blend_position', direction)
	anim_tree.set('parameters/Turn/blend_position', direction)
	anim_tree.set('parameters/CarExit/blend_position', direction)
	anim_tree.set('parameters/Kneel/blend_position', direction)
	anim_tree.set('parameters/Swing/blend_position', direction)
	anim_tree.set('parameters/Chop/blend_position', direction)
	anim_tree.set('parameters/Hoe/blend_position', direction)
	anim_tree.set('parameters/Pickup/blend_position', direction)
	anim_tree.set('parameters/KneelStay/blend_position', direction)
	anim_tree.set('parameters/KneelStand/blend_position', direction)
	anim_tree.set('parameters/SwingHold/blend_position', direction)
	anim_tree.set('parameters/SwingFinish/blend_position', direction)
	anim_tree.set('parameters/Eat/blend_position', direction)
	anim_tree.set('parameters/Poke/blend_position', direction)

func tween_move(move_vector : Vector2, speed_mod):
	anim_state.travel('Walk')
	set_orientation(move_vector)
	var tween_duration = speed_base * speed_mod * move_vector.length() * TILE_SIZE
	var final_position = position + move_vector * TILE_SIZE
	tween.interpolate_property(
		self,
		"position",
		position,
		final_position,
		tween_duration,
		Tween.TRANS_LINEAR
	)
	tween.start()
	yield(tween, "tween_completed")
	anim_state.travel('Idle')
	emit_signal("tween_complete")
	is_moving = false

func car_exit(direction):
	anim_tree.set('parameters/CarExit/blend_position', direction)
	anim_tree.set('parameters/Idle/blend_position', direction)
	anim_tree.set('parameters/Walk/blend_position', direction)
	anim_tree.set('parameters/Turn/blend_position', direction)
	visible = true
	anim_state.travel("CarExit")
	tween_move(direction, 2)

func activate():
	set_idle()
	stop_input = false
	sprite.visible = true
	visible = true
	set_physics_process(true)
	camera_activate()

func slept():
	stats.gain_energy(stats.current_max_energy)

func set_idle():
	anim_state.travel("Idle")

func deactivate():
	stop_input = true
	set_physics_process(false)

func act(animation_state):
	anim_state.travel(animation_state)
	player_state = PlayerState.ACTING
	stop_input = true

func swing_finished():
	anim_state.travel("SwingHold")

func build_object():
	anim_state.travel("SwingFinish")

func _on_action_complete():
	set_idle()
	stop_input = false
	player_state = PlayerState.IDLE

func camera_activate():
	camera.current = true

func _on_CharSelect_character_swapped(character_id):
	if selected_character != character_id:
		sprite.texture = load('res://Assets/Player/farmer-OW-master-' + String(character_id) + '.png')
		selected_character = character_id

func set_camera_limits(camera_limits):
	camera.limit_left = camera_limits[0]
	camera.limit_right = camera_limits[1]
	camera.limit_top = camera_limits[2]
	camera.limit_bottom = camera_limits[3]

func building():
	player_state = PlayerState.BUILDING
	disable_colliders()
	stop_input = true

func finished_building():
	enable_colliders()
	set_idle()
	player_state = PlayerState.IDLE
	stop_input = false

func shade_entered(shade_mod):
	light_level = clamp(light_level - shade_mod, 0, 1)
	
	var new_modulate = Color(light_level, light_level, light_level)
	tween.interpolate_property(sprite, 'modulate',
	sprite.modulate, new_modulate, 0.25,
	Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.start()

func shade_exited(shade_mod):
	light_level = clamp(light_level + shade_mod, 0, 1)
	
	var new_modulate = Color(light_level, light_level, light_level)
	tween.interpolate_property(sprite, 'modulate',
	sprite.modulate, new_modulate, 0.25,
	Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.start()

func eat(food):
	stats.food_gained(food.food_value_actual)

func spawn_watering_can_effect():
	var watering_can_effect
	
	if facing_direction == FacingDirection.LEFT:
		var watering_can_effect_scene = load("res://Scenes/Particles/WateringCanWaterEffectHorizontal.tscn")
		watering_can_effect = watering_can_effect_scene.instance()
		
		add_child(watering_can_effect)
		watering_can_effect.position = Vector2(-2,8)
		watering_can_effect.emitting = true
		
		watering_can_effect.scale.x = -1
	elif facing_direction == FacingDirection.RIGHT:
		var watering_can_effect_scene = load("res://Scenes/Particles/WateringCanWaterEffectHorizontal.tscn")
		watering_can_effect = watering_can_effect_scene.instance()
		
		add_child(watering_can_effect)
		watering_can_effect.position = Vector2(18,8)
		watering_can_effect.emitting = true
	elif facing_direction == FacingDirection.UP:
		var watering_can_effect_scene = load("res://Scenes/Particles/WateringCanWaterEffectUp.tscn")
		watering_can_effect = watering_can_effect_scene.instance()
		
		add_child(watering_can_effect)
		watering_can_effect.position = Vector2(8,-1)
		watering_can_effect.emitting = true
	elif facing_direction == FacingDirection.DOWN:
		var watering_can_effect_scene = load("res://Scenes/Particles/WateringCanWaterEffectDown.tscn")
		watering_can_effect = watering_can_effect_scene.instance()
		
		add_child(watering_can_effect)
		watering_can_effect.position = Vector2(8,15)
		watering_can_effect.emitting = true
	
	move_child(watering_can_effect, 0)


func clear_watering_can_effect():
	get_node("WateringCanParticleEffect").emitting = false
	yield(get_tree().create_timer(0.3), "timeout")
	get_node("WateringCanParticleEffect").queue_free()

func scene_activate():
	pass

func return_colliding_indices():
	var obstacle_array = [(get_global_position() - grid_offset)/16]
	return obstacle_array

func left_scene():
	var astar = get_node("../../../Astar")
	astar.player_departed_tile(tile_location_current/16)
