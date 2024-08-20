extends Control

enum DAY_PHASES {DAWN, MORNING, MIDDAY, AFTERNOON, EVENING, DUSK, NIGHT, DEEP_NIGHT}
var current_phase = DAY_PHASES.DAWN

var phase_durations = [10,30,20,30,20,10,80]
var phase_names = ['Dawn', 'Morning', 'Midday', 'Afternoon', 'Evening', 'Dusk', 'Night', 'Deep Night']

var phase_time = 0
var current_time = 0

onready var scrolling_sprite = $ScrollingImage/Sprite
onready var phase_label = $Label
onready var time_incrementer : Timer = $TimeIncrementer

signal time_incremented(current_time)
signal phase_entered(phase)

func day_start():
	time_incrementer.start()

func reset():
	current_time = 0
	current_phase = DAY_PHASES.DAWN
	scrolling_sprite.offset.x = 0
	time_incrementer.stop()
	time_incrementer.wait_time = 6.0
	phase_label.text = phase_names[current_phase]
	emit_signal('phase_entered', current_phase)

func _on_TimeIncrementer_timeout():
	current_time += 1
	phase_time += 1
	emit_signal("time_incremented", current_time)
	
	scroll_sprite()
	
	if current_phase == DAY_PHASES.DEEP_NIGHT:
		return
	
	if phase_time > phase_durations[current_phase]:
		enter_next_phase()
	
	time_incrementer.start()


func scroll_sprite():
	scrolling_sprite.offset.x -= 1

func enter_next_phase():
	phase_time = 0
	current_phase += 1
	phase_label.text = phase_names[current_phase]
	emit_signal("phase_entered", current_phase)

func pause_time():
	time_incrementer.paused = true

func resume_time():
	time_incrementer.paused = false

func advance_day():
	reset()
