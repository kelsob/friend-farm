extends Node2D

var player

var velocity : float = 0.0
var scale_decay : float = 0.97

onready var sprite = $Sprite
onready var tween = $Tween

signal item_pickup_complete()

func _ready():
	set_process(false)


func initialize(item_texture, initial_position):
	player = get_parent().player
	sprite.texture = item_texture
	position = initial_position
	set_process(true)
	visible = true

func _process(delta):
	if position == player.get_global_position():
		player_arrived()
	else:
		scale = scale * scale_decay
		velocity += delta * 2
		var move_vector = (player.get_global_position() + Vector2(8,6) - position).normalized() * velocity
		if move_vector.length() >= (player.get_global_position() + Vector2(8,6)).distance_to(position):
			player_arrived()
		else:
			position += move_vector

func player_arrived():
	emit_signal("item_pickup_complete")
	set_process(false)
	position = player.get_global_position() + Vector2(8,6)
	queue_free()

func _on_tween_completed(object, key):
	queue_free()

