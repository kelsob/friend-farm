extends Area2D
class_name InteractableObject
tool

export var obstructing = true

export (Vector2) var tile_dimensions = Vector2(1, 1)
export (bool) var dismantlable = false
export (bool) var movable = false

export (Resource) var build_item

var player
var total_interactions = 0
var current_interaction = 0

var dialog_box_scene = load("res://Scenes/UI/DialogBox.tscn")

export var dialog = [
		["Initial interaction dialog.", "Continued first interaction dialog."],
		["Secondary interaction dialog.", "Continued second interaction dialog."]
]
var dialog_box

onready var timer = $Timer
onready var area_interactable = $Area2DInteractable
onready var tween = $Tween
onready var sprite = $Sprite
onready var collision_shape_obstruction = $CollisionShape2DObstruction
onready var collision_build_indicator = null
onready var visibility_notifier = $VisibilityNotifier2D
onready var weathered_effects = $WeatheredEffects
onready var anim = $AnimationPlayer

func _ready():
	set_process(false)
	set_physics_process(false)

func _activate():
	player = get_node("../Player")

func player_interacted(player):
	player.set_physics_process(false)

	dialog_box = dialog_box_scene.instance()
	get_tree().current_scene.add_child(dialog_box)
	dialog_box.dialog = dialog[current_interaction]
	yield(get_tree().create_timer(0.1), "timeout")
	dialog_box.show()
	dialog_box.activate()
	dialog_box.load_dialog()
	yield(dialog_box, "dialog_completed")
	dialog_box.queue_free()

	player.set_physics_process(true)

	total_interactions += 1
	current_interaction = clamp(current_interaction + 1, 0, dialog.size() - 1)

	timer.start()

func _on_Timer_timeout():
	current_interaction = 0

func _on_tween_completed(object, key):
	pass # Replace with function body.

func enter_building_state():
	var collision_build_indicator_scene = load("res://Scenes/UI/BuildIndicator.tscn")
	collision_build_indicator = collision_build_indicator_scene.instance()
	add_child(collision_build_indicator)
	
	collision_shape_obstruction.scale = Vector2(0.99, 0.99)
	collision_build_indicator.rect_size = tile_dimensions * 16
	collision_build_indicator.visible = true
	z_index = 10

func built():
	create_pathfindinding_obstacle()
	dismantlable = true
	movable = true
	collision_build_indicator.visible = false
	collision_shape_obstruction.scale = Vector2(1,1)
	z_index = 5

func dismantled():
	remove_astar_obstacles()
	get_node("../../../../..").add_item(build_item.duplicate(), get_global_position() + collision_shape_obstruction.position)
	queue_free()

func create_pathfindinding_obstacle():
	var obstacle_array = get_colliding_points()
	get_node("../../..").create_obstacle(obstacle_array)

func object_grabbed():
	var obstacle_array = get_colliding_points()
	get_node("../../..").remove_obstacle(obstacle_array)
	collision_shape_obstruction.scale = Vector2(0.99,0.99)
	z_index = 10

func object_released():
	var obstacle_array = get_colliding_points()
	get_node("../../..").create_obstacle(obstacle_array)
	collision_shape_obstruction.scale = Vector2(1,1)
	z_index = 0

func get_colliding_points():
	var obstacle_array = []
	for dx in range(tile_dimensions.x):
		for dy in range(tile_dimensions.y):
			obstacle_array.append(get_global_position()/16 + Vector2(dx,dy))
	return obstacle_array

func advance_day():
	pass

func _on_Area2DPlayer_area_entered(area):
	pass # Replace with function body.

func _on_Area2DPlayer_area_exited(area):
	pass # Replace with function body.

func add_astar_obstacles():
	get_node("../../../Astar").disable_obstructing_cells(get_colliding_points(), true)

func remove_astar_obstacles():
	get_node("../../../Astar").disable_obstructing_cells(get_colliding_points(), false)

func self_remove():
	get_node("../../../Astar").disable_obstructing_cells(get_colliding_points(), false)
	queue_free()

func weather_changed(weather_precipitation, weather_light):
	weathered_effects.weather_changed(weather_precipitation, weather_light)

func return_colliding_indices():
	var obstacle_array = []

	for dx in range(tile_dimensions.x):
		for dy in range(tile_dimensions.y):
			var index = Vector2(get_global_position().x/16 + dx, get_global_position().y/16 + dy)
			obstacle_array.append(index)
	
	return obstacle_array
