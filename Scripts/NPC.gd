extends KinematicBody2D

class_name NPC

export (String) var home_scene = "Town"
export (String) var work_scene = "CityHallFloor1"

export (Vector2) var day_starting_position = Vector2(16,16)
export (Array, Resource) var daily_schedule = []
var current_schedule
var current_behaviour : Resource = null
var current_behaviour_duration : int = 0

var dialog_current : String = "DefaultDialog"

export var walk_speed = 1.0
export var jump_speed = 4.0
export var door_speed = 1.0
const TILE_SIZE = 16

var obstructing : bool = true
var interactable : bool = true

var speed_base : float = 0.015625

var initial_position = Vector2(0,0)
var move_direction = Vector2(0,0)
var is_moving = false
var percent_moved_to_next_tile = 0.0

var waiting : bool = false

enum MovementState {IDLE, TURNING, WALKING}
enum FacingDirection {LEFT, RIGHT, UP, DOWN}
enum AIState {FREE_ROAM, STATIONARY, FOLLOWING, TRAVELLING, TRAVELLING_SCENES}
enum AIThought {IDLE, SEEKING, WANDERING}

export (bool) var entering_door : bool = false
export (bool) var exiting_door : bool = false

var movement_state = MovementState.IDLE
var facing_direction = FacingDirection.DOWN
var ai_state
var ai_thought = AIThought.IDLE

var tile_location_target = Vector2(0,0)
var tile_location_current = Vector2(0,0)

var destination_scene : int
var destination_exit
var destination_exits : Array = []
var scene_path = []

var facing_vector = Vector2(0,0)
var grid_offset : Vector2 = Vector2(0,2)
var current_move_path : PoolVector2Array

var jumping_over_ledge : bool = false

var a_star
var a_star_scene_nav

var rng = RandomNumberGenerator.new()
var player

const landing_dust_effect_scene = preload("res://Scenes/Effects/LandingDustEffect.tscn")

onready var sprite = $Sprite
onready var shadow = $Shadow
onready var anim = $AnimationPlayer
onready var anim_tree = $AnimationTree
onready var anim_state = anim_tree.get('parameters/playback')
onready var ray = $BlockingRayCast2D
onready var ledge_ray = $LedgeRayCast2D
onready var door_ray = $DoorRayCast2D
onready var interactable_ray = $InteractableRayCast2D
onready var tween = $Tween
onready var camera = $Camera2D
onready var idle_timer = $IdleTimer

signal tween_complete()

signal player_moving_signal()
signal player_stopped_signal()

signal player_opening_door_signal()
signal player_entered_door_signal()

signal npc_entered_new_scene(npc)

func _ready():
	$debuglabel.text = name
	current_behaviour_duration = 0
	tile_location_current = position

	current_schedule = daily_schedule.duplicate()

	rng.randomize()
	set_physics_process(false)
	sprite.visible = true
	initial_position = position
	anim_tree.active = true
	shadow.visible = false

	anim_tree.set('parameters/CarExit/blend_position', move_direction)
	anim_tree.set('parameters/Idle/blend_position', move_direction)
	anim_tree.set('parameters/Walk/blend_position', move_direction)
	anim_tree.set('parameters/Turn/blend_position', move_direction)

func initialize():
	update_scene()

func update_scene():
	a_star = get_node("../../../Astar")
	a_star_scene_nav = get_tree().current_scene.NPC_controller

func _physics_process(delta):
	if movement_state == MovementState.TURNING:
		return
	elif move_direction != Vector2.ZERO:
		anim_state.travel('Walk')
		move(delta)
	else:
		anim_state.travel('Idle')
		is_moving = false
		if ai_state == AIState.FREE_ROAM:
			process_free_roam(delta)
		elif ai_state == AIState.STATIONARY:
			process_stationary(delta)
		elif ai_state == AIState.TRAVELLING:
			process_travelling(delta)
		elif ai_state == AIState.TRAVELLING_SCENES:
			process_travelling_scenes(delta)

func cycle_ai_state():

	if ai_state == AIState.FREE_ROAM:
		ai_state = AIState.STATIONARY
	else:
		ai_state = AIState.FREE_ROAM

func process_stationary(delta):
	pass

func process_free_roam(delta):
	
	if ai_thought == AIThought.IDLE:
	
		ai_thought = AIThought.WANDERING
		yield(get_tree().create_timer(rng.randf_range(1, 2)), "timeout")
		
		if !interactable:
			return
		
		var idle_move_vector
		if bool(rng.randi_range(0,1)):
			idle_move_vector = Vector2((get_global_position().x/16) + rng.randi_range(-3,3), (get_global_position().y/16))
		else:
			idle_move_vector = Vector2((get_global_position().x/16), (get_global_position().y/16) + rng.randi_range(-3,3))
		
		
		a_star = get_node("../../../Astar")

		current_move_path = a_star.get_point_path(get_global_position()/16, idle_move_vector)
		if current_move_path.size() > 1:
			current_move_path.remove(0)
			set_current_move_vector(current_move_path[0])
		else:
			ai_thought = AIThought.IDLE
			current_move_path = []

func process_travelling(delta):
	if get_global_position()/16 == (get_parent().get_global_position() + current_behaviour.destination_position)/16:
		travel_destination_arrived()
	
	elif current_move_path.size() > 1:
		set_current_move_vector(current_move_path[0])

	else:
		rethink_path()

func process_travelling_scenes(delta):
	if get_global_position() == destination_exit.get_global_position():
		
		move_direction = destination_exit.entrance_vector
		need_to_turn()
		update_blend_states(facing_vector)
		
		door_ray.force_raycast_update()
		door_ray.get_collider().open_door()
		
		entering_door = true
		set_current_move_vector(destination_exit.get_global_position()/16 + destination_exit.entrance_vector)
	
	elif current_move_path.size() > 1 and !entering_door and !exiting_door:
		set_current_move_vector(current_move_path[0])
	
	else:
		rethink_path()

func travel_destination_arrived():
	load_next_behaviour()

func set_current_move_vector(move_point):
	initial_position = position
#	print(position)
	
	move_direction = (move_point - position/16)
	move_direction = move_direction.normalized()
	
	move_direction.x = int(round(move_direction.x))
	move_direction.y = int(round(move_direction.y))
	
#	print('initial position:', initial_position/16, ' move direction:', move_direction, ' move point:', move_point)

	update_blend_states(move_direction)

	if need_to_turn():
		movement_state = MovementState.TURNING
		anim_state.travel('Turn')
		move_colliders(facing_vector)
		
	if current_move_path.size() != 0:
		current_move_path.remove(0)
	if current_move_path.size() == 0:
		ai_thought = AIThought.IDLE
	is_moving = true

func update_blend_states(move_direction):
	anim_tree.set('parameters/Idle/blend_position', move_direction)
	anim_tree.set('parameters/Walk/blend_position',  move_direction)
	anim_tree.set('parameters/Run/blend_position',  move_direction)
	anim_tree.set('parameters/Turn/blend_position',  move_direction)

func interact():
	
	var desired_interact = Vector2(0,0)
	
	if facing_direction == FacingDirection.LEFT:
		desired_interact = Vector2(-1,0) * TILE_SIZE / 2
	elif facing_direction == FacingDirection.RIGHT:
		desired_interact = Vector2(1,0) * TILE_SIZE / 2
	elif facing_direction == FacingDirection.UP:
		desired_interact = Vector2(0,-1) * TILE_SIZE / 2
	elif facing_direction == FacingDirection.DOWN:
		desired_interact = Vector2(0,1) * TILE_SIZE / 2
	
	interactable_ray.cast_to = desired_interact
	interactable_ray.force_raycast_update()
	
	if interactable_ray.is_colliding():
		var collider = interactable_ray.get_collider()
		collider.get_parent().player_interacted(self)
	else:
		pass

func need_to_turn():
	var new_facing_direction
	if move_direction.x < 0:
		new_facing_direction = FacingDirection.LEFT
		facing_vector = Vector2(-16, 0)
		
	if move_direction.x > 0:
		new_facing_direction = FacingDirection.RIGHT
		facing_vector = Vector2(16, 0)
		
	if move_direction.y > 0:
		new_facing_direction = FacingDirection.DOWN
		facing_vector = Vector2(0, 16)
		
	if move_direction.y < 0:
		new_facing_direction = FacingDirection.UP
		facing_vector = Vector2(0, -16)
	
	move_colliders(facing_vector)
	
	if facing_direction != new_facing_direction:
		facing_direction = new_facing_direction
		return true
	facing_direction = new_facing_direction
	return false

func move_colliders(facing_vector):
	var position_vector = Vector2(8,8) + facing_vector
	
	ray.cast_to = facing_vector
	ledge_ray.cast_to = facing_vector
	door_ray.cast_to = facing_vector
	interactable_ray.cast_to = facing_vector
	
	interactable_ray.force_raycast_update()
	ray.force_raycast_update()
	ledge_ray.force_raycast_update()
	door_ray.force_raycast_update()

func finished_turning():
	movement_state = MovementState.IDLE

func move(delta):

	if entering_door:
		if percent_moved_to_next_tile == 0:
			start_moving()
			tween.interpolate_property(self,'modulate', modulate, Color(1,1,1,0), 0.8, Tween.EASE_OUT)
			tween.start()
			tile_location_departed()

		percent_moved_to_next_tile += clamp(walk_speed * delta, 0, 1.0)
		is_moving = true

		if percent_moved_to_next_tile >= 1.0:
			position = tile_location_target
			transition_scenes()
			entering_door = false
		else:
			position = initial_position + (TILE_SIZE * move_direction.normalized() * percent_moved_to_next_tile)

		return

	elif exiting_door:
		move_direction = destination_exit.entrance_vector
		if percent_moved_to_next_tile == 0:
			start_moving()

		percent_moved_to_next_tile += clamp(walk_speed * delta, 0, 1.0)
		is_moving = true

		if percent_moved_to_next_tile >= 1.0:
			position = tile_location_target
			scene_transition_completed()
			
		else:
			position = initial_position + (TILE_SIZE * move_direction.normalized() * percent_moved_to_next_tile)

		return

	if percent_moved_to_next_tile == 0:
		start_moving()
		gate_location_check()
		
		if !tile_location_check():
			rethink_path()
			return
		emit_signal("player_moving_signal")
	
	percent_moved_to_next_tile += clamp(walk_speed * delta, 0, 1.0)
	is_moving = true
	
	if percent_moved_to_next_tile >= 1.0:
		tile_location_arrived()
	else:
		position = initial_position + (TILE_SIZE * move_direction.normalized() * percent_moved_to_next_tile)

func start_moving():
	initial_position = position
	tile_location_current = position
	tile_location_target = position + facing_vector

func gate_location_check():
	move_colliders(facing_vector)
	var interactable_collider = interactable_ray.get_collider()
	if interactable_collider != null:
		if interactable_collider is Gate:
			if interactable_collider.gate_state == interactable_collider.STATE.CLOSED:

				interactable_collider.npc_opened(facing_vector)
				
				yield(get_tree().create_timer(1.0), 'timeout')
				while get_global_position() == interactable_collider.get_global_position():
					yield(get_tree().create_timer(1.0), 'timeout')
				yield(get_tree().create_timer(1.0), 'timeout')
				interactable_collider.npc_closed()

func tile_location_check():

#	print(name, ' target location: ', tile_location_target)

	if a_star.is_point_disabled(tile_location_target):
#		print('Point disabled! for the npc. cant move.')
		return false
		
	elif !a_star.are_points_connected(tile_location_current, tile_location_target):
#		print(" Points are disconnected.")
		return false
		
	else:
#		print("tile_location_target: ", tile_location_target)
		a_star.npc_arrived_tile(tile_location_target/16)
		tile_location_departed()
		return true

func tile_location_departed():
	yield(get_tree().create_timer(0.1), "timeout")
	get_node("../../../Astar").npc_departed_tile(tile_location_current/16)

func tile_location_arrived():

	position = tile_location_target
	percent_moved_to_next_tile = 0.0
	move_direction = Vector2.ZERO
	tile_location_current = tile_location_target
	
	emit_signal("player_stopped_signal")
	if current_move_path.size() > 0:
		set_current_move_vector(current_move_path[0])
	else:
		path_end_reached()

func path_end_reached():
	tile_location_target = Vector2(0,0)
	is_moving = false
	move_direction = Vector2.ZERO
	anim_state.travel('Idle')

func rethink_path():
	if waiting:
		return
	
	percent_moved_to_next_tile = 0.0
	tile_location_target = Vector2(0,0)
	is_moving = false
	move_direction = Vector2.ZERO
	anim_state.travel('Idle')
	ai_thought = AIThought.IDLE
	current_move_path.resize(0)
	
	if ai_state == AIState.TRAVELLING_SCENES:
		
		current_move_path = a_star.get_point_path(get_global_position()/16, destination_exit.get_global_position()/16)
		
		if current_move_path.size() > 1:
			current_move_path.remove(0)
			set_current_move_vector(current_move_path[0])
		else:
			waiting = true
			yield(get_tree().create_timer(1.0), 'timeout')

			current_move_path = a_star.get_npcless_path(get_global_position()/16, destination_exit.get_global_position()/16)
			if current_move_path.size() > 1:
				current_move_path.remove(0)
				set_current_move_vector(current_move_path[0])
				
			waiting = false


	elif ai_state == AIState.TRAVELLING:
		var current_position = get_global_position()/16
		var target_position = (get_parent().get_global_position() + current_behaviour.destination_position)/16
			
		current_move_path = a_star.get_point_path(current_position, target_position)
	
		if current_move_path.size() > 1:
			current_move_path.remove(0)
			set_current_move_vector(current_move_path[0])
		else:
			waiting = true
			yield(get_tree().create_timer(1.0), 'timeout')
			
			current_move_path = a_star.get_npcless_path(current_position, target_position)
			if current_move_path.size() > 1:
				current_move_path.remove(0)
				set_current_move_vector(current_move_path[0])
			
			waiting = false

func transition_scenes():
	print(name, " left ", get_node('../../..').name)
	
	is_moving = false
	move_direction = Vector2.ZERO
	percent_moved_to_next_tile = 0.0
	set_physics_process(false)
	
	emit_signal('npc_entered_new_scene', self)

func entered_new_scene():
	update_scene()
	exiting_door = true
	
	door_ray.force_raycast_update()
	door_ray.get_collider().open_door()
	
	print(name, " entered ", get_node('../../..').name)
	
	tween.interpolate_property(self,'modulate', modulate, Color(1,1,1,1), 0.8, Tween.EASE_IN)
	tween.start()
	
	set_physics_process(true)
	is_moving = true
	move_direction = destination_exit.entrance_vector
	facing_vector = destination_exit.entrance_vector * 16
	update_blend_states(facing_vector)
	set_current_move_vector(get_global_position()/16 + destination_exit.entrance_vector - get_parent().get_global_position()/16)

func scene_transition_completed():
	
	tile_location_departed()
	
	exiting_door = false
	current_move_path.resize(0)

#	print(scene_path)

	scene_path.remove(0)
	
	if scene_path.size() != 0:
		if current_behaviour.destination_scene != get_node("../../..").name:
			ai_state = AIState.TRAVELLING_SCENES

			destination_scene = scene_path[0]
			select_closest_scene_exit()

			current_move_path = a_star.get_point_path(get_global_position()/16, destination_exit.get_global_position()/16)
			if current_move_path.size() != 0:
				current_move_path.remove(0)

#		# the npc is already in the desired scene.
		else:
			ai_state = AIState.TRAVELLING
			
			destination_exit = null
			scene_path = []
			
			current_move_path = a_star.get_point_path(get_global_position()/16, (get_parent().get_global_position() + current_behaviour.destination_position)/16)
			current_move_path.remove(0)
	else:
		ai_state = AIState.TRAVELLING
		
		destination_exit = null
		scene_path = []
		
		current_move_path = a_star.get_point_path(get_global_position()/16, (get_parent().get_global_position() + current_behaviour.destination_position)/16)
		if current_move_path.size() != 0:
			current_move_path.remove(0)

func set_spawn(location : Vector2, direction : Vector2):
	set_orientation(direction)
	set_position(location)

func set_position(location):
	position = location
	tile_location_current = position
	tile_location_target = position

func set_orientation(direction):
	direction = direction.normalized()
	anim_tree.set('parameters/CarExit/blend_position', direction)
	anim_tree.set('parameters/Idle/blend_position', direction)
	anim_tree.set('parameters/Walk/blend_position', direction)
	anim_tree.set('parameters/Turn/blend_position', direction)

func activate():
	anim_state.travel("Idle")
	sprite.visible = true
	set_physics_process(true)
	camera_activate()

func camera_activate():
	camera.current = true

func scene_activate():
	set_physics_process(true)

func return_colliding_indices():
	var obstacle_array = [get_global_position()/16]
	return obstacle_array

# TIME CONTROL RELATED FUNCTIONS:
func advance_day():
	set_physics_process(true)
	load_next_behaviour()

func day_ended():
	if percent_moved_to_next_tile != 0:
		get_node("../../../Astar").npc_departed_location(tile_location_current/16)
		get_node("../../../Astar").npc_departed_location(tile_location_target/16)
	
	exiting_door = false
	entering_door = false
	percent_moved_to_next_tile = 0.0
	
	ai_state = AIState.STATIONARY
	move_direction = Vector2.ZERO
	current_move_path.resize(0)
	scene_path.resize(0)
	current_behaviour_duration = 0
	current_schedule = daily_schedule.duplicate()

func time_incremented():
	current_behaviour_duration += 1

	if current_behaviour == null:
		return
	
	if current_behaviour.duration == -1:
		return
	
	if current_behaviour_duration >= current_behaviour.duration:
		load_next_behaviour()

func load_next_behaviour():

	rethink_path()

	current_behaviour_duration = 0
	current_behaviour = current_schedule.pop_front()
	
	if current_behaviour == null:
		ai_state = AIState.FREE_ROAM
		return

	
	match current_behaviour.id:
		"TravelTo":
			
			# initiating travel to a separate scene.
			
			if current_behaviour.destination_scene != get_node("../../..").name:
				ai_state = AIState.TRAVELLING_SCENES
				
				scene_path = a_star_scene_nav.get_scene_path(get_node("../../..").get_index(), get_node("../../../../" + current_behaviour.destination_scene).get_index())
				scene_path.remove(0)
				
				destination_scene = scene_path[0]
				select_closest_scene_exit()
				
				current_move_path = a_star.get_point_path(get_global_position()/16, destination_exit.get_global_position()/16)
				if current_move_path.size() > 1:
					current_move_path.remove(0)
					set_current_move_vector(current_move_path[0])

			# the npc is already in the desired scene.
			else:
				ai_state = AIState.TRAVELLING
				var current_position = get_global_position()/16
				var target_position = (get_parent().get_global_position() + current_behaviour.destination)/16
			
				current_move_path = a_star.get_point_path(current_position, target_position)
		
		"FreeRoam":
			ai_state = AIState.FREE_ROAM

#	print("Ai_state: ", ai_state)
	set_physics_process(true)

func select_closest_scene_exit():
	destination_exits = get_node("../../..").get_exits(destination_scene)
	destination_exit = destination_exits[0]
	destination_exits.remove(0)
	var destination_distance = a_star.get_point_path(get_global_position()/16, destination_exit.get_global_position()/16).size()
	
	for exit in destination_exits:
		if a_star.get_point_path(get_global_position()/16, exit.get_global_position()/16).size() < destination_distance:
			destination_exit = exit
			destination_distance =  a_star.get_point_path(get_global_position()/16, exit.get_global_position()/16).size()


func player_interacted(player_init):
	if !interactable:
		return
		
	player = player_init
	player.set_physics_process(false)
	set_physics_process(false)
	
	interactable = false

	set_orientation(player.facing_vector * -1)
	update_blend_states(player.facing_vector * -1)
	anim_state.travel("Idle")
	
	start_dialog()

func start_dialog():
	var dialog = Dialogic.start(dialog_current)
	dialog.pause_mode = PAUSE_MODE_PROCESS
	get_tree().current_scene.find_node("UI").add_child(dialog)
	
	dialog.connect("timeline_end", self, "end_dialog")
	dialog.connect("dialogic_signal", self, "dialogic_signal")

func end_dialog(timeline_name):
	Input.action_release("ui_accept")
	need_to_turn()
	player.set_physics_process(true)

	interactable = true

	update_blend_states(facing_vector)
	set_physics_process(true)

func dialogic_signal(argument):
	pass
