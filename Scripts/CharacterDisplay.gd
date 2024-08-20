extends Control

onready var anim = $AnimationPlayer
onready var label = $Label

export (String) var stored_character = ''

func activate():
	anim.play("UnderlineBob")

func deactivate():
	anim.stop(false)
	anim.seek(0.0, true)


func assign_character(character):
	stored_character = character
	label.text = stored_character
	deactivate()

func clear_character():
	stored_character = ''
	label.text = stored_character
	deactivate()
