extends Control

onready var anim = $AnimationPlayer
onready var button_1 = $CharacterSelectButton
onready var button_2 = $CharacterSelectButton2

signal selection_complete()

func appear():
	anim.play("Appear")
	yield(anim, "animation_finished")
	button_1.disabled = false
	button_2.disabled = false
	button_1.grab_focus()

func disappear():
	anim.play("Disappear")
	yield(anim, "animation_finished")
	

func character_0_selected():
	pass

func character_1_selected():
	pass
