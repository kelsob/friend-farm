extends Control

onready var letter_container = $Keyboard/HBoxContainer/GridContainer
onready var character_display_container = $TextDisplay/CharacterDisplayContainer
onready var case_button = $Keyboard/HBoxContainer/VBoxContainer/CaseButton
onready var back_button = $Keyboard/HBoxContainer/VBoxContainer/BackButton
onready var ok_button = $Keyboard/HBoxContainer/VBoxContainer/OKButton
onready var anim = $AnimationPlayer
onready var sprite = $TextDisplay/CharacterSprite

var character_index = 0
var uppercase : bool = false
var string_filled : bool = false
var string_empty : bool = true

signal text_selected(selected_text)
signal fade_complete()

func _ready():
	_to_uppercase()
	for letter_button in letter_container.get_children():
		letter_button.connect('character_selected', self, 'character_selected')
	assign_focus_neighbours()
	letter_container.get_child(0).grab_focus()

func assign_focus_neighbours():
	var columns = letter_container.columns
	
	for i in range(columns):
		letter_container.get_child(i).focus_neighbour_top = letter_container.get_child(i + 24).get_path()
		letter_container.get_child(i + 24).focus_neighbour_bottom = letter_container.get_child(i).get_path()
	
	letter_container.get_child(0).focus_neighbour_left = letter_container.get_child(7).get_path()
	letter_container.get_child(8).focus_neighbour_left = case_button.get_path()
	letter_container.get_child(16).focus_neighbour_left = back_button.get_path()
	letter_container.get_child(24).focus_neighbour_left = ok_button.get_path()
	
	case_button.focus_neighbour_right = letter_container.get_child(8).get_path()
	case_button.focus_neighbour_top = ok_button.get_path()
	back_button.focus_neighbour_right = letter_container.get_child(16).get_path()
	ok_button.focus_neighbour_right = letter_container.get_child(24).get_path()
	ok_button.focus_neighbour_bottom = case_button.get_path()

func activate():
	letter_container.get_child(0).grab_focus()
	character_display_container.get_child(0).activate()

func character_selected(character):
	string_empty = false
	character_display_container.get_child(character_index).assign_character(character)
	character_index = clamp(character_index + 1, 0, 7)
	if character_index == 7:
		string_filled = true
		character_display_container.get_child(character_index).deactivate()
	else:
		character_display_container.get_child(character_index).activate()

func _to_uppercase():
	uppercase = true
	case_button.label.text = "lower"
	for letter_button in letter_container.get_children():
		letter_button._to_uppercase()

func _to_lowercase():
	uppercase = false
	case_button.label.text = "UPPER"
	for letter_button in letter_container.get_children():
		letter_button._to_lowercase()


func _on_CaseButton_pressed():
	if !uppercase:
		_to_uppercase()
	else:
		_to_lowercase()

func _on_BackButton_pressed():

	if character_index == 0:
		string_empty = true
		return
		
	elif character_index == 7 && string_filled:
		character_display_container.get_child(character_index).clear_character()
		character_display_container.get_child(character_index).activate()
		string_filled = false

	else:
		character_display_container.get_child(character_index).deactivate()
		character_index -= 1
		character_display_container.get_child(character_index).clear_character()
		character_display_container.get_child(character_index).activate()

func _on_OKButton_pressed():
	if string_empty:
		return
	else:
		var selected_text : String = ''
		for character_display in character_display_container.get_children():
			selected_text = selected_text + character_display.stored_character

		emit_signal('text_selected', selected_text)

func assign_sprite(char_id):
	sprite.texture = load('res://Assets/Player/farmer-OW-master-' + String(char_id) + '.png')

func appear():
	anim.play("Appear")
	yield(anim, "animation_finished")
	emit_signal("fade_complete")

func disappear():
	anim.play("Disappear")
	yield(anim, "animation_finished")
	emit_signal("fade_complete")

func reset():
	_to_uppercase()
	character_index = 0
	string_empty = true
	string_filled = false
	for character_display in character_display_container.get_children():
		character_display.clear_character()
