extends TextureButton

tool

export (String) var character = 'a'

onready var label = $Label
onready var icon = $Icon

signal character_selected(character)

func _ready():
	label.text = character

func show_icon():
	icon.show()

func hide_icon():
	icon.hide()

func _to_uppercase():
	character = character.to_upper()
	label.uppercase = true

func _to_lowercase():
	character = character.to_lower()
	label.uppercase = false

func _self_pressed():
	emit_signal('character_selected', character)
