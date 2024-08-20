extends CanvasLayer

onready var main = $TextureRect

var choice = null

onready var yes_button = $TextureRect/VBoxContainer/YesButton
onready var no_button = $TextureRect/VBoxContainer/NoButton

onready var timer = $Timer

signal answer_chosen(choice)

func initialize(timer_duration):
	if timer_duration != 0:
		timer.wait_time = timer_duration
		timer.start()

func activate():
	yes_button.grab_focus()
	show()

func _on_YesButton_pressed():
	timer.stop()
	choice = 1
	answer_chosen()

func _on_NoButton_pressed():
	timer.stop()
	choice = 0
	answer_chosen()

func _on_Timer_timeout():
	choice = 2
	answer_chosen()

func answer_chosen():
	emit_signal("answer_chosen", choice)
	reset()

func show():
	main.show()

func hide():
	main.hide()

func reset():
	timer.wait_time = 1.0
	choice = 3
	hide()
