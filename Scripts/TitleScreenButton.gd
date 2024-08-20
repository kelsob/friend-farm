extends TextureButton

tool

export var button_text : String = 'default'
onready var label = $Label
onready var icon = $TextureRect

func _ready():
	label.text = button_text

func show_icon():
	icon.show()

func hide_icon():
	icon.hide()
