extends Control

onready var item_icon_texture = $HBoxContainer/ItemIcon
onready var item_description_label = $HBoxContainer/ItemDescriptionLabel
onready var tween = $Tween

var text_display_speed : float = 1.0
var character_display_length : float = 0.025

func clear_item():
	item_icon_texture.texture = null
	item_description_label.text = ""

func display_item(item):
	if tween.is_active():
		tween.stop(item_description_label)
	
	display_texture(item)
	display_description(item)

func display_texture(item_object):
	item_icon_texture.texture = item_object.texture

func display_description(item_object):
	var tween_duration = 0.25 * character_display_length * item_object.return_tooltip().length() * text_display_speed
	
	item_description_label.percent_visible = 1.0
	item_description_label.bbcode_text = item_object.return_tooltip()

	tween.interpolate_property(item_description_label,
		"percent_visible",
		0.0,
		1.0,
		tween_duration,
		Tween.TRANS_LINEAR
	)
	tween.start()
