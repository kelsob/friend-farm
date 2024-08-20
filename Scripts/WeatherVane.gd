extends Sprite

var rng = RandomNumberGenerator.new()

onready var tween = $Tween
onready var big_timer = $BigTimer
onready var smol_timer = $SmolTimer

var _is_moving = false

func _ready():
	rng.randomize()
	smol_timer.start()
	big_timer.start()

func _on_SmolTimer_timeout():
	var new_timer = rng.randi_range(0, 20)
	var new_wait_time = new_timer * 0.25 + 0.25
	smol_timer.wait_time = new_wait_time
	smol_timer.start()

	var up = bool(rng.randi_range(0,1))
	
	if up && frame == 9:
		frame = 0
	elif up: 
		frame += 1
	elif !up && frame == 0:
		frame = 9
	else:
		frame -= 1


func _on_BigTimer_timeout():
	var new_timer = rng.randi_range(3, 20)
	var new_wait_time = new_timer * 2
	big_timer.wait_time = new_wait_time
	big_timer.start()
	
	var new_frame = rng.randi_range(0, 9)
	var tween_duration = 0.125 * abs((new_frame - frame))

	tween.interpolate_property(
		self,
		"frame",
		frame,
		new_frame,
		tween_duration,
		Tween.TRANS_CUBIC,
		Tween.EASE_IN_OUT
	)
	tween.start()
