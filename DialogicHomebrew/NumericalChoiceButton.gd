extends Control

onready var counter_label = $HBoxContainer/CounterLabel

var max_count : int = 99
var current_count : int = 1

signal decision_made(purchase_count)
signal decision_cancelled()

func _ready():
	set_process(false)

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		emit_signal('decision_made', current_count)
		queue_free()
	elif Input.is_action_just_pressed("ui_cancel"):
		emit_signal('decision_cancelled')
		queue_free()
	
	if Input.is_action_just_pressed("ui_up"):
		current_count += 1
	elif Input.is_action_just_pressed('ui_down'):
		current_count -= 1
	
	if current_count <= 0:
		current_count = max_count
	elif current_count >= max_count:
		current_count = 1
	
	update_display()

func update_display():
	var string
	if current_count < 10:
		string = "0" + String(current_count)
	else:
		string = String(current_count)
	
	counter_label.text = string
