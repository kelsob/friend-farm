extends Node

var NPC_packed_array : Array = [
#load("res://Scenes/Npcs/BaxterGoodeboy.tscn"),
load("res://Scenes/Npcs/NPC1.tscn"),
load("res://Scenes/Npcs/NPC2.tscn"),
load("res://Scenes/Npcs/NPC3.tscn"),
load("res://Scenes/Npcs/NPC4.tscn"),
load("res://Scenes/Npcs/NPC5.tscn"),
load("res://Scenes/Npcs/NPC6.tscn"),
load("res://Scenes/Npcs/NPC7.tscn"),
load("res://Scenes/Npcs/NPC8.tscn"),
load("res://Scenes/Npcs/NPC9.tscn"),
load("res://Scenes/Npcs/NPC10.tscn"),
load("res://Scenes/Npcs/NPC11.tscn"),
load("res://Scenes/Npcs/NPC12.tscn"),
load("res://Scenes/Npcs/NPC13.tscn"),
load("res://Scenes/Npcs/NPC14.tscn"),
load("res://Scenes/Npcs/NPC15.tscn"),
load("res://Scenes/Npcs/NPC16.tscn"),
load("res://Scenes/Npcs/NPC17.tscn"),
load("res://Scenes/Npcs/NPC18.tscn"),
load("res://Scenes/Npcs/NPC19.tscn"),
load("res://Scenes/Npcs/NPC20.tscn")
]
var NPC_array : Array = []

var scenes

onready var astar_scene_nav = AStar2D.new()

func initialize():

	for packed_npc in NPC_packed_array:
		var npc = packed_npc.instance()
		get_node("../SceneHolder/" + npc.home_scene).ysort.characters.add_child(npc)
		npc.set_global_position(npc.day_starting_position)
		npc.initialize()
		npc.connect('npc_entered_new_scene', self, '_on_npc_entered_new_scene')

		NPC_array.append(npc)
		

	initialize_scene_nav()

	activate_npcs()

func activate_npcs():
	for npc in NPC_array:
		npc.load_next_behaviour()

func initialize_scene_nav():
	var scene_holder = get_node("../SceneHolder")

	scenes = scene_holder.get_children()

	# Adding astar points that represent each scene.
	for scene in scenes:
		astar_scene_nav.add_point(scene.get_index(), Vector2.ZERO, 1.0)
	
	# Connecting astar points to relevant connected scenes.
	for scene in scenes:
		for connected_scene in scene.connected_scenes:
			print(scene," ",  connected_scene)
			astar_scene_nav.connect_points(scene.get_index(), scene_holder.get_node(connected_scene).get_index(), true)

func _on_npc_entered_new_scene(npc : NPC):
	var target_scene = get_node("../SceneHolder").get_child(npc.destination_scene)
	npc.get_parent().remove_child(npc)
	target_scene.ysort.characters.add_child(npc)
	
	var target_position = target_scene.entrance_positions.get_child(npc.destination_exit.connected_entrance).get_global_position() - (16 * npc.destination_exit.entrance_vector)
	npc.set_global_position(target_position)
	npc.entered_new_scene()

func get_scene_path(scene_1, scene_2):
	var point_path = astar_scene_nav.get_id_path(scene_1, scene_2)
	return point_path

func advance_day():
	reset_daily_positions()
	for npc in NPC_array:
		npc.advance_day()

func reset_daily_positions():
	for npc in NPC_array:
		npc.set_physics_process(false)
		npc.day_ended()
		npc.get_parent().remove_child(npc)
		get_node("../SceneHolder/" + npc.home_scene).ysort.characters.add_child(npc)
		npc.update_scene()
		npc.set_global_position(get_node("../SceneHolder/" + npc.home_scene).get_global_position() + npc.day_starting_position)

func time_incremented():
	for npc in NPC_array:
		npc.time_incremented()
