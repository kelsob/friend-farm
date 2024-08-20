extends TextureButton

onready var icon = $Icon
onready var label = $Label

func show_icon():
	icon.show()

func hide_icon():
	icon.hide()

