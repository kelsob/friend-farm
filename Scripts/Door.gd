extends Area2D

export (String) var next_scene_path = ""

var open = false
var closing = false

export (bool) var perma_open = false
export (bool) var is_invisible = false
export (bool) var locked = false
export (bool) var horizontal = true

export (String) var entrance_anim = "Idle"
export (int) var spawn_location = 0
export (Vector2) var spawn_direction = Vector2(0,0)

onready var sprite = $Sprite
onready var anim = $AnimationPlayer
onready var timer = $Timer

func _ready():

	if !horizontal:
		rotation_degrees = 90
	
	if is_invisible:
		sprite.visible = false
		sprite.texture = null
	if perma_open:
		open = true
#
#	var player = find_parent("SceneHolder").get_children().front().find_node("Player")
#	player.connect("player_opening_door_signal", self, "open_door")
#	player.connect("player_entered_door_signal", self, "door_entered")

func open_door():
	if open or locked:
		return
	anim.play("DoorOpen")
	yield(anim, "animation_finished")
	open = true
	timer.start()

func close_door():
	closing = true
	anim.play("DoorClose")
	yield(anim, 'animation_finished')
	closing = false
	open = false

func door_entered():
	timer.stop()
	
	if perma_open:
		pass
	elif !perma_open and !closing:
		anim.play("DoorClose")
		yield(anim, "animation_finished")
		open = false
	
	get_node(NodePath("/root/SceneManager")).transition_to_scene(next_scene_path, spawn_location, spawn_direction)

func _on_Timer_timeout():
	if !perma_open:
		close_door()

func nudged():
	pass
