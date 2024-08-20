extends Node2D

onready var tween = $Tween

var rect_size = Vector2(480, 320)

signal turned_off()
signal turned_on()

export (Array, int) var particle_children_ids = [0, 1, 2, 3]

func turn_on(duration):
	
	for particle_child_id in particle_children_ids:
		tween.interpolate_property(get_child(particle_child_id), "modulate", Color(1,1,1,0), Color(1,1,1,1), duration,Tween.TRANS_QUAD, Tween.EASE_IN)
		tween.start()
		get_child(particle_child_id).visible = true
		get_child(particle_child_id).emitting = true
	
	yield(get_tree().create_timer(duration), "timeout")
	emit_signal('turned_on')

func turn_off(duration):
	
	for particle_child_id in particle_children_ids:
		get_child(particle_child_id)
		tween.interpolate_property(get_child(particle_child_id), "modulate", Color(1,1,1,1), Color(1,1,1,0), duration, Tween.TRANS_QUAD, Tween.EASE_IN)
		tween.start()
	
	yield(get_tree().create_timer(duration), "timeout")
	
	for particle_child_id in particle_children_ids:
		get_child(particle_child_id).visible = false
		get_child(particle_child_id).emitting = false
	
	emit_signal('turned_off')

func reset_quadrant_positions():
	var quadrants = get_children()
	quadrants.pop_back()
	
	for quadrant in quadrants:
		quadrant.reset_default_position()
