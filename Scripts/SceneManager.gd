extends Node2D

var next_scene = null
var old_scene = null

var player
var player_location = Vector2(0, 0)
var player_direction = Vector2(0, 0)
var reparent = false

enum WorldState {OVERWORLD, PLAYERHOUSE, WALKING}
var world_state = WorldState.OVERWORLD

var scene_hold_position = Vector2(-10240, 0)
var default_position = Vector2(0, 0)

var inventory
var starting_date = [1, 1]

const grass_step_effect_scene = preload("res://Scenes/Effects/GrassStepEffect.tscn")
const sprite_pickup_scene = preload("res://Scenes/UI/ItemPickupSprite.tscn")
const item_pickup_label_scene = preload("res://Scenes/UI/ItemPickupLabel.tscn")

onready var current_scene = $SceneHolder/PlayerFarm
onready var scene_holder = $SceneHolder
onready var player_farm = $SceneHolder/PlayerFarm
onready var inventory_display = $UI/InventoryMaster
onready var game_clock = $UI/GameClock
onready var day_clock = $UI/DayClock
onready var fuel_gauge = $UI/FuelGauge
onready var fade = $UI/FadeIn
onready var weather = $Weather
onready var ui = $UI
onready var god_box = $UI/GodBox

onready var NPC_controller = $NPCController

signal reparent_completed()

func _ready():
	old_scene = current_scene
	player = current_scene.find_node("Player")
	NPC_controller.initialize()

	for scene in scene_holder.get_children():
		scene.initialize()
		scene.deactivate()
		scene.ysort.activate()
		scene.position = scene_hold_position
		
	current_scene.position = default_position
	current_scene.show()
	
	player.set_camera_limits(current_scene.camera_limits)
	
	current_scene.activate()
	inventory = inventory_display.inventory
	
	weather.connect('weather_changed', self, '_on_weather_changed')
	weather.initialize(player.get_global_position())
	
	game_clock.set_initial_date(starting_date)	
	day_clock.day_start()

func transition_to_scene(new_scene : String, spawn_location, spawn_direction):
	next_scene = scene_holder.find_node(new_scene)
	
	player.left_scene()
	player.set_camera_limits(next_scene.camera_limits)
	
	player_location = next_scene.entrance_positions.get_child(spawn_location).position + player.grid_offset
	player_direction = spawn_direction
	
	fade.fade_in()
	if next_scene.indoors:
		weather.player_went_indoors()
	elif !next_scene.indoors:
		weather.player_went_outdoors()
	
func finished_fading():
	current_scene.position = scene_hold_position
	current_scene.deactivate()
	current_scene.hide()

	current_scene = next_scene
	reparent = true
	yield(self, "reparent_completed")
	
	player.set_idle()
	player.set_spawn(player_location, player_direction)
	player.sprite.visible = true
	
	old_scene = current_scene
	
	current_scene.position = default_position
	current_scene.show()
	current_scene.activate()

	weather.transition_scene(player.get_global_position())

	fade.fade_out()

func player_slept():
	var player_orientation = player.input_direction
	var new_player_orientation = player_orientation.rotated(PI)

	fade.sleep_fade_in()
	yield(fade, "fade_complete")
	player.slept()
	player.set_orientation(new_player_orientation)
	
	advance_day()
	yield(get_tree().create_timer(0.25), "timeout")
	fade.sleep_fade_out()
	yield(fade, "fade_complete")

	player.activate()

func advance_day():
	ui.advance_day()
	
	for scene in scene_holder.get_children():
		scene.advance_day()

func add_item(item, item_pickup_position):
	inventory.add_item(item)
	
	var sprite_pickup = sprite_pickup_scene.instance()
	add_child(sprite_pickup)
	sprite_pickup.initialize(item.texture, item_pickup_position)
	yield(sprite_pickup, "item_pickup_complete")

	var item_pickup_label = item_pickup_label_scene.instance()
	player.add_child(item_pickup_label)
	item_pickup_label.position = Vector2(8,8)
	item_pickup_label.initialize(item)

func _process(delta):
	if reparent:
		old_scene.remove_player()
		current_scene.add_player(player)
		reparent = false
		emit_signal("reparent_completed")


# WEATHER RELATED FUNCTIONALITY

func _on_weather_changed(weather_precipitation, weather_light):
	for scene in scene_holder.get_children():
		scene._on_weather_changed(weather_precipitation, weather_light)

func player_went_indoors():
	weather.player_went_indoors()

func player_went_outdoors():
	weather.player_went_outdoors()

func _on_DayClock_phase_entered(phase):
	weather.day_phase_entered(phase)

func _on_DayClock_time_incremented(current_time):
	NPC_controller.time_incremented()

# GOD MODE FUCNTIONALITY
func release_godbox_focus():
	for button in god_box.get_children():
		button.release_focus()

func _on_GODMODETimeAdvance_pressed():
	NPC_controller.advance_day()
	release_godbox_focus()
	weather.advance_day()
	ui.advance_day()
	yield(game_clock, "time_advance_completed")
	current_scene.advance_day()

func _on_GODMODEGoldGain_pressed():
	release_godbox_focus()
	player.stats.currency_changed(100)

func _on_GODMODEGainEnergy_pressed():
	release_godbox_focus()
	player.stats.gain_energy(1)

func _on_GODMODELoseEnergy_pressed():
	release_godbox_focus()
	player.stats.lose_energy(2)
# END GOD MODE FUNCTIONALITY

func _on_GODMODEGodLand_pressed():
	release_godbox_focus()
	transition_to_scene("GodLand", 0, Vector2(0,1))

func _on_GODMODENPCModeCycle_pressed():
	for character in current_scene.ysort.characters.get_children():
		
		if character is NPC:
			character.cycle_ai_state()
			$UI/GodBox/GODMODENPCModeCycle/Label.text = "npcmode:" + String(character.ai_state)

func _on_GODMODEWeatherCycle_pressed():
	weather.cycle_weather()


func _on_GODMODETown_pressed():
	release_godbox_focus()
	transition_to_scene("Town", get_node("SceneHolder/Town").entrance_positions.get_child_count() - 1, Vector2(0,1))


func _on_GODMODEPlayerFarm_pressed():
	release_godbox_focus()
	transition_to_scene("PlayerFarm", 0, Vector2(0,1))
