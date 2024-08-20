extends Node

onready var dialog_box = $DialogBox
onready var yesno_box = $YesNoChoiceBox
onready var choices_box = $ChoicesBox

var conversation : Array

var recent_choice
var time_sensitive = true

var conversation_properties = []
var choices = []
var skip_count = 0
var end_condition

var choice_dependent_rewrite : bool = false
var conversation_stage = 0 

signal conversation_completed(conversation_properties)

func set_time_sensitivity(time_sensivity):
	time_sensitive = time_sensivity
	dialog_box.set_time_sensitivity(time_sensitive)

func initiate_conversation():
	dialog_box.show()
	next_stage()

func next_stage():
	var current_stage = conversation[conversation_stage]

	# Simple Dialog Option
	if current_stage[0] == 0:
		current_stage.remove(0)
		load_text_dialog(current_stage)
	# YesNo Choice Option
	elif current_stage[0] == 1:
		current_stage.remove(0)
		load_yesno_option(current_stage)
	# Multi Option Choice
	elif current_stage[0] == 2:
		current_stage.remove(0)
		load_choice_option(current_stage)
	
	conversation_stage += 1

func load_text_dialog(current_stage):
	dialog_box.reset()
	var current_stage_dialog
	
	if choice_dependent_rewrite:
		current_stage_dialog = current_stage[recent_choice]
		choice_dependent_rewrite = false
	elif !choice_dependent_rewrite:
		current_stage_dialog = current_stage

	if current_stage_dialog.back() == "END_DIALOG":
		current_stage_dialog.pop_back()
		
		end_condition = current_stage_dialog.pop_back()
		
		dialog_box.dialog = current_stage_dialog
		dialog_box.show()
		dialog_box.activate()
		dialog_box.load_dialog()
		yield(dialog_box, "final_dialog_completed")
		dialog_box.reactivate()
		yield(dialog_box, "dialog_completed")
		dialog_box.reactivate()
		
		package_conversation_properties()
		emit_signal("conversation_completed", conversation_properties)
		dialog_box.hide()
		reset()
		
	else:
		dialog_box.dialog = current_stage_dialog
	
		dialog_box.show()
		dialog_box.activate()
		dialog_box.load_dialog()
		yield(dialog_box, "final_dialog_completed")
		dialog_box.reactivate()
	
		if conversation[conversation_stage][0] != 0:
			dialog_box.deactivate()
			next_stage()
		elif conversation[conversation_stage][0] == 0:
			yield(dialog_box, "dialog_completed")

			next_stage()

func load_yesno_option(current_stage):
	if current_stage[0] == true:
		choice_dependent_rewrite = true
	elif current_stage[0] == false:
		choice_dependent_rewrite = false
	current_stage.remove(0)
	
	yesno_box.initialize(current_stage[0])
	yesno_box.activate()
	recent_choice = yield(yesno_box, "answer_chosen")
	choices.append(recent_choice)

	next_stage()

func load_choice_option(current_stage):
	if current_stage[0] == true:
		choice_dependent_rewrite = true
	elif current_stage[0] == false:
		choice_dependent_rewrite = false
	current_stage.remove(0)
	
	choices_box.initialize(current_stage)
	choices_box.activate()
	recent_choice = yield(choices_box, "answer_chosen")
	choices.append(recent_choice)
	
	next_stage()

func package_conversation_properties():
	conversation_properties.append(end_condition)
	conversation_properties.append(skip_count)
	conversation_properties.append(choices)

func load_conversation(conversation_init):
	conversation = conversation_init

func reset():

	skip_count = 0
	conversation_stage = 0
	choice_dependent_rewrite = false
	
	dialog_box.reset()
	yesno_box.reset()
	choices_box.reset()
	
	conversation.clear()
	choices.clear()

func _on_DialogBox_dialog_skipped():
	skip_count += 1
