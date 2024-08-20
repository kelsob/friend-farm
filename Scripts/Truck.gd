extends KinematicBody2D


onready var sprite = $Sprite
onready var camera = $Camera2D
onready var anim = $AnimationPlayer
onready var tween = $Tween

export (float) var speed_base = 0.0325

enum FacingDirection {LEFT, RIGHT, UP, DOWN}
var facing_direction = FacingDirection.DOWN

signal tween_complete()

func _ready():
	speed_base = 0.015
#	speed_base = 0.001 #So I started blastin
	pass

func tween_move(move_vector : Vector2, speed_mod):
	if move_vector.x > 0:
		facing_direction = FacingDirection.RIGHT
		set_animation("DriveRight")
	elif move_vector.x < 0:
		facing_direction = FacingDirection.LEFT
		set_animation("DriveLeft")
	elif move_vector.y > 0:
		facing_direction = FacingDirection.DOWN
		set_animation("DriveDown")
	elif move_vector.y < 0:
		facing_direction = FacingDirection.UP
		set_animation("DriveUp")
	
	var tween_duration = speed_base * speed_mod * move_vector.length()*16
	var final_position = position + move_vector * 16
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
	emit_signal("tween_complete")

func open_door():
	anim.play("DoorOpenLeft")

func close_door():
	anim.play("DoorCloseLeft")

func set_animation(animation):
	anim.play(animation)

func new_speed(new_speed):
	tween.playback_speed = new_speed
