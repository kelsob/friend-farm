extends Control

onready var anim = $AnimationPlayer
onready var collision_area = $Area2D
onready var hand_sprite = $HandSprite/Sprite
onready var corners = $Corners

func object_grabbed(grabbed):
	if grabbed:
		corners.hide()
		hand_sprite.frame = 0
	else:
		hand_sprite.frame = 1

func moved(move_vector):
	hand_sprite.visible = false
	corners.visible = false
	rect_position += move_vector

func moved_visible(move_vector):
	corners.visible = true
	rect_position += move_vector

func show_hand():
	hand_sprite.visible = true

func hide_hand():
	hand_sprite.visible = false

func corners_hide():
	corners.visible = false

func corners_show():
	corners.visible = true
