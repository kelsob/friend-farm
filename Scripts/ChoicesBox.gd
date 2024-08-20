extends CanvasLayer

onready var main = $NinePatchRect
onready var button_container = $NinePatchRect/VBoxContainer
onready var timer = $Timer

var answer = null

var button_scene = load("res://Scenes/UI/ChoiceButton.tscn")

signal answer_chosen(choice)

func initialize(current_stage):
	var timer_duration = current_stage[0]
	var choice_array = current_stage[1]
	
	if timer_duration != 0:
		timer.wait_time = timer_duration
		timer.start()
	
	for choice in choice_array:
		var button = button_scene.instance()
		button_container.add_child(button)
		button.initialize(choice)
		button.connect("answer_chosen", self, "answer_chosen")
	button_container.get_child(0).grab_focus()

	var npr_y_size = 21 + 12 * choice_array.size()
	main.rect_size.y = npr_y_size

func activate():
	button_container.get_child(0).grab_focus()
	show()

func answer_chosen(answer):
	emit_signal("answer_chosen", answer)
	timer.stop()
	hide()
	reset()

func show():
	main.show()

func hide():
	main.hide()

func _on_Timer_timeout():
	answer_chosen(button_container.get_child_count())

func reset():
	answer = null
	for button in button_container.get_children():
		button_container.remove_child(button)
		button.queue_free()
