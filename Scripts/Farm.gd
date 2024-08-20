extends Node2D

export (bool) var skip_intro = false

var player
var active = true
var conversation_manager

onready var ysort = $YSort
onready var entrance_positions = $EntrancePositions
onready var tilled_earth_tilemap = $TilledEarthTileMap

onready var fade = $CanvasLayer/FadeIn
onready var scenes = $Scenes
onready var tween = $Tween

var camera_limits = [0, 1024, 0, 1024]
var current_scene

func _ready():
	player = ysort.find_node("Player")

func intro_skipped():
	activate()

func play_world_intro():
	current_scene = scenes.get_child(0)
	current_scene.initiate_scene()

func deactivate():
	active = false

func activate():
	player.camera_activate()
	player.activate()
	active = true


func remove_player():
	ysort.characters.remove_child(player)

func add_player(player_init):
	player = player_init
	ysort.characters.add_child(player)

func _on_Truck_tween_complete():
	current_scene.play_next_stage()

func advance_day():
	ysort.advance_day()
