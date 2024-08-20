extends Node2D

var watering_target
var use_rate

var current_value = 0
var max_value = 10

var initial_value
var cutoff_value

onready var progress_bar = $TextureProgress
onready var target_level_indicator = $TextureProgress/TargetLevel
onready var cutoff_level_indicator = $TextureProgress/CutoffLevel

signal minigame_completed(new_value, change)

func initialize(watering_target_init, initial_watering_level, stored_quantity, water_position, use_rate_init):
	if initial_watering_level == 100:
		return
	
	watering_target = watering_target_init
	initial_value = initial_watering_level
	cutoff_value = stored_quantity

	if watering_target == null:
		
		max_value = cutoff_value
		target_level_indicator.visible = false
		cutoff_level_indicator.visible = true
		
	elif watering_target >= initial_value:
		
		if watering_target <= 10:
			max_value = 10
		elif watering_target <= 50:
			max_value = 50
		elif watering_target <= 100:
			max_value = 100
	
		var target_percent = 1 - float(watering_target) / float(max_value)
		var target_y_pos = int(round(target_percent * 16))
		target_level_indicator.rect_position.y = target_y_pos
		target_level_indicator.visible = true

		if cutoff_value <= max_value:
			var cutoff_percent = float(cutoff_value) / float(max_value)
			var cutoff_y_pos = int(round(cutoff_percent) * 16)
			cutoff_level_indicator.rect_position.y = cutoff_y_pos
			cutoff_level_indicator.visible = true
		else:
			cutoff_level_indicator.visible = false
	
	elif watering_target < initial_value:
		max_value = cutoff_value + initial_value
		cutoff_level_indicator.visible = true
		var target_percent = 1 - float(watering_target) / float(max_value)
		var target_y_pos = int(round(target_percent * 16))
		target_level_indicator.rect_position.y = target_y_pos
		target_level_indicator.visible = true

	progress_bar.max_value = max_value
	progress_bar.value = initial_value
	current_value = initial_value

	use_rate = use_rate_init
	set_global_position(water_position + Vector2(0, 4))
		
func start_minigame():
	set_process(true)

func _process(delta):
	
	current_value += delta * use_rate
	progress_bar.value = int(round(current_value))
	if Input.is_action_just_released("ui_accept") or progress_bar.value == max_value or progress_bar.value == cutoff_value + initial_value:

		var change = progress_bar.value - initial_value
		emit_signal("minigame_completed", progress_bar.value, change)
		set_process(false)
		queue_free()
