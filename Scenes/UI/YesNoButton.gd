extends TextureButton

onready var icon = $Icon
onready var label = $Label

signal answer_chosen(position)

func initialize(choice):
	label.text = choice

func _on_focus_entered():
	icon.show()

func _on_focus_exited():
	icon.hide()

func _on_self_pressed():
	emit_signal("answer_chosen", get_index())
