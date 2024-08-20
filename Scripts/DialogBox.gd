extends CanvasLayer

onready var control = $Control
onready var label = $Control/RichTextLabel
onready var tween = $Control/Tween
onready var progress_indicator = $Control/ProgressIndicator
onready var anim = $Control/AnimationPlayer
onready var timer = $Timer

var text_display_speed : float = 1.0
var character_display_length : float = 0.075

var time_sensitive : bool = false

var dialog = []

var dialog_index = 0
var completed = false
var finished = false

signal final_dialog_initiated()
signal final_dialog_completed()
signal dialog_completed()
signal dialog_skipped()

func _ready():
	set_process(false)

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		if !finished:
			finish_dialog()
		elif finished && !completed:
			load_dialog()
			
		elif finished && completed:
			emit_signal("dialog_completed")
			

func set_time_sensitivity(time_sensivity):
	time_sensitive = time_sensivity

func load_dialog():
	timer.stop()
	if dialog_index == dialog.size() - 1:
		emit_signal('final_dialog_initiated')
	
	progress_indicator.hide()
	
	if dialog_index < dialog.size():
		finished = false
		label.percent_visible = 0
		
		var label_string = dialog[dialog_index]
		label.bbcode_text = label_string
		tween_text(label_string)
	
	else:
		pass

func finish_dialog():
	reset_timer()

	finished = true
	tween.stop_all()
	label.percent_visible = 1.0
	dialog_index += 1
	if dialog_index == dialog.size():
		emit_signal('final_dialog_completed')
		completed = true
	
	emit_signal("dialog_skipped")
	progress_indicator.show()

func tween_text(text):
	var tween_duration  = character_display_length * text.length() * text_display_speed
	
	tween.interpolate_property(
		label,
		'percent_visible',
		0,
		1,
		tween_duration,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT
	)
	tween.start()

func _on_Tween_completed(object, key):
	reset_timer()
	
	finished = true
	dialog_index += 1
	if dialog_index == dialog.size():
		emit_signal('final_dialog_completed')
		completed = true
	else:
		progress_indicator.show()

func appear():
	anim.play("Appear")

func disappear():
	anim.play("Disappear")

func reactivate():
	progress_indicator.show()
	set_process(true)
	
func show():
	control.show()

func hide():
	control.hide()

func activate():
	set_process(true)

func deactivate():
	set_process(false)
	progress_indicator.hide()

func reset():
	timer.stop()
	timer.wait_time = 3
	dialog_index = 0
	dialog.clear()
	completed = false

func reset_timer():
	timer.stop()
	timer.wait_time = 3
	if time_sensitive && is_processing():
		timer.start()

func _on_Timer_timeout():
	if is_processing():
		
		if dialog_index == dialog.size():

			emit_signal("dialog_completed")
		else:
			load_dialog()

func initialize(item):
	var a_an_string = "a"
	var starting_letter = item.name.to_lower().left(1)
	var item_quality
	
	if item.quality_tier_resource.tier == 0:
		starting_letter = item.name.to_lower().left(1)
		item_quality = ""
	else:
		starting_letter = item.quality_tier_resource.name.to_lower().left(1)
		item_quality = " " + item.quality_tier_resource.RTEffect_open_tertiary + item.quality_tier_resource.RTEffect_open_secondary + item.quality_tier_resource.RTEffect_open_primary + item.quality_tier_resource.name + item.quality_tier_resource.RTEffect_close_primary + item.quality_tier_resource.RTEffect_close_secondary + item.quality_tier_resource.RTEffect_close_tertiary
	
	
	if starting_letter == "a" or starting_letter == "e" or starting_letter == "i" or starting_letter == "o" or starting_letter == "u":
		a_an_string += "n"
	
	if item.current_stack_size > 1:
		dialog = ["You have found x" + String(item.current_stack_size) + item_quality + " " + item.name.to_upper() + "!"]
	
	else:
		dialog = ["You have found " + a_an_string + item_quality + " " + item.name.to_upper() + "!"]
