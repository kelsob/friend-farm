extends Control

var rot_base_empty : float = -26
var rot_base_full : float = 118
var rot_current : float = 118

var current_energy = 10
var max_energy = 10

var energy_percentage : float = 1.0

onready var indicator_arm = $IndicatorArm

onready var counters = $HBoxContainer
onready var current_energy_label = $HBoxContainer/VBoxContainer/CurrentEnergyLabel
onready var max_energy_label = $HBoxContainer/VBoxContainer/MaxEnergyLabel

onready var tween = $Tween

func _on_current_energy_changed(new_current_energy):
	current_energy = new_current_energy
	current_energy_label.text = String(current_energy)
	update_indicator_arm()

func _on_max_energy_changed(new_max_energy):
	max_energy = new_max_energy
	max_energy_label.text = String(max_energy)
	update_indicator_arm()

func update_indicator_arm():
	energy_percentage = float(current_energy) / float(max_energy)
	var new_rot_position = rot_base_empty + ((rot_base_full - rot_base_empty) * energy_percentage)

	if tween.is_active():
		yield(tween, "tween_completed")

	tween.interpolate_property(
		indicator_arm,
		"rotation_degrees",
		rot_current,
		new_rot_position,
		0.25,
		Tween.TRANS_CUBIC,
		Tween.EASE_IN_OUT
	)
	tween.start()
	
	yield(tween, "tween_completed")
	rot_current = new_rot_position 

func _display_initialized(current_energy_init, max_energy_init):
	current_energy = current_energy_init
	max_energy = max_energy_init
	yield(get_tree().create_timer(0.001), "timeout")

	current_energy_label.text = String(current_energy)
	max_energy_label.text = String(max_energy)
	update_indicator_arm()
