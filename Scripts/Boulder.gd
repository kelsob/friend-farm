extends InteractableObject
tool

export (bool) var cuttable = false
export (bool) var pickable = true
export (int) var variant = 0

export (Array, Resource) var held_resources = []
export (int) var pick_resistance_tier = 0
export (float) var pick_resistance = 6.0
export (Array, float) var crack_points_init = [2.0, 4.0]
export (float) var pick_progress = 0.0

export (bool) var crackable = true
var crack_points

enum State {IDLE, SHAKING}
var state = State.IDLE

export var shake_amplitude_initial : float = 1.0
export var shake_amplitude : float = 1.0
var shake_duration : float = 0.0
var shake_speed : float = 48.0

func _ready():
	sprite.frame_coords = Vector2(0, variant)
	crack_points = crack_points_init.duplicate()
	set_process(false)

func chopped(cut_tier):
	pass

func picked(pick_tier):
	
	print('boulder picked')
	var pick_mod = 0.0
	
	var shake_amplitude_mod
	if pick_tier < pick_resistance_tier:
		shake_amplitude_mod = 0.5
	elif pick_tier == pick_resistance_tier:
		shake_amplitude_mod = 1.0
		pick_mod = 1.0
	elif pick_tier > pick_resistance_tier:
		shake_amplitude_mod = 1.5
		pick_mod = 1.0 + pick_tier - pick_resistance_tier

	print(pick_progress)
	pick_progress += pick_mod

	yield(get_tree().create_timer(0.35), "timeout")
	shake(shake_amplitude_mod)

	if crack_points.size() == 0:
		if pick_progress >= pick_resistance:
			shattered()
	else:
		if pick_progress >= crack_points[0] and pick_progress < pick_resistance:
			cracked()
		elif pick_progress >= pick_resistance:
			shattered()

func cracked():
	if !crackable:
		 return
	
	var x_frame = sprite.frame_coords.x
	x_frame += 1
	var new_frame = Vector2(x_frame, variant)
	
	sprite.frame_coords = Vector2(x_frame, variant)
#	sprite.frame_coords.x += 1
	crack_points.pop_front()

func shattered():
	for resource in held_resources:
		var item_added = get_tree().current_scene.add_item(resource.duplicate())
	
	queue_free()

func shake(shake_amplitude_mod):
	set_process(true)
	state = State.SHAKING
	tween.interpolate_property(self, "shake_amplitude",
	shake_amplitude_initial * shake_amplitude_mod, 0.0, 0.25,
	Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()

func _process(delta):
	if state == State.SHAKING:
		
		shake_duration += delta * shake_speed
		sprite.offset = Vector2(shake_amplitude * cos(shake_duration), 0)

func _on_tween_completed(object, key):
	shake_amplitude = shake_amplitude_initial
	state = State.IDLE
	set_process(false)
	sprite.offset = Vector2(0,0)


func player_interacted(player):
	pass
