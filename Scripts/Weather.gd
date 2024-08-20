extends Node2D

#Weather Types:
# 0 Clear
# 1 Windy
# 2 Overcast
# 3 Foggy
# 4 Cold Spell
# 5 Heat Wave
# 6 Light Rain
# 7 Normal Rain
# 8 Heavy Rain
# 9 Torrential Rain
# 10 Light Snow
# 11 Heavy Snow

var weather_types = [load('res://Resources/WeatherResources/0.tres'),
	load('res://Resources/WeatherResources/1.tres'),
	load('res://Resources/WeatherResources/2.tres'),
	load('res://Resources/WeatherResources/3.tres'),
	load('res://Resources/WeatherResources/4.tres'),
	load('res://Resources/WeatherResources/5.tres'),
	load('res://Resources/WeatherResources/6.tres'),
	load('res://Resources/WeatherResources/7.tres'),
	load('res://Resources/WeatherResources/8.tres'),
	load('res://Resources/WeatherResources/9.tres'),
	load('res://Resources/WeatherResources/10.tres'),
	load('res://Resources/WeatherResources/11.tres')]

var weather_weights = [10,4,4,0,0,0,5,4,3,0,0,0]

var weekly_forecast = [[[weather_types[0],8]],
	[[weather_types[0],8]],
	[[weather_types[0],8]],
	[[weather_types[0],8]],
	[[weather_types[0],8]],
	[[weather_types[0],8]],
	[[weather_types[0],8]],
]

var daily_weather
var phase_weather

var current_weather = weather_types[0]
var current_weather_node
var current_day_phase = 0

var phase_transition_time = -1

var weather_transition_duration = 6

onready var light_rain = $LightRain
onready var normal_rain = $NormalRain
onready var heavy_rain = $HeavyRain
onready var torrential_rain = $TorrentialRain
onready var light_snow = $LightSnow
onready var heavy_snow = $HeavySnow
onready var breezy = $Breezy
onready var windy = $Windy
onready var foggy = $Fog

onready var weather_type_nodes = [light_rain, normal_rain, heavy_rain, torrential_rain, light_snow, heavy_snow, breezy, windy, foggy]

onready var light_control = $LightControl
onready var tween = $Tween
onready var anim = $AnimationPlayer

var rng = RandomNumberGenerator.new()

signal weather_changed(weather_details)

func _ready():
	rng.randomize()
#	generate_weekly_forecast()
	
	daily_weather = weekly_forecast.pop_front()
	phase_weather = daily_weather.pop_front()
	change_weather(phase_weather)
	weekly_forecast.append(generate_daily_forecast())
	
	light_control.visible = true

func initialize(player_position):
	position = player_position

func transition_scene(player_position):
	initialize(player_position)
	for weather_type_node in weather_type_nodes:
		weather_type_node.reset_quadrant_positions()


func change_weather(weather_phase):
	current_weather = weather_phase[0]
	phase_transition_time = weather_phase[1]
	disable_current_weather_node()
	
	print("current weather: ", current_weather.name, ",   phase transition time: ", phase_transition_time)
	
	
	if current_weather.node_id != -1:
		current_weather_node = weather_type_nodes[current_weather.node_id]
	else:
		current_weather_node = null
	
	emit_signal("weather_changed", current_weather.precipitation_level, current_weather.light_level_progression[current_day_phase])
	light_control.change_light(current_weather.color_progression[current_day_phase])
	
	if current_weather_node != null:
		current_weather_node.turn_on(weather_transition_duration)

func disable_current_weather_node():
	if current_weather_node == null:
		return
	
	var node_to_disable = current_weather_node
	node_to_disable.turn_off(weather_transition_duration)
	node_to_disable = null

func day_phase_entered(phase):
	print('day phase entered: ', phase)
	
	current_day_phase = phase
	phase_transition_time -= 1
	
	if phase_transition_time == 0:
		
		phase_weather = daily_weather.pop_front()
		change_weather(phase_weather)

		print('weather phase transitioned: ', phase_weather[0].name)
	
	else:
		light_control.change_light(current_weather.color_progression[current_day_phase])

func advance_day():
	daily_weather = weekly_forecast.pop_front()
	phase_weather = daily_weather.pop_front()
	change_weather(phase_weather)
	weekly_forecast.append(generate_daily_forecast())

func start_day():
	pass

func end_day():
	pass

func player_went_indoors():
	anim.play('disappear')

func player_went_outdoors():
	anim.play('appear')

func generate_weekly_forecast():
	rng.randomize()
	var forecast = []
	
	for i in range(7):
		forecast.append(generate_daily_forecast())
	
	weekly_forecast = forecast

func generate_daily_forecast():
	var phase_lengths = determine_phase_lengths()
	var phase_progression = determine_phase_progression(phase_lengths.size())
	
	var daily_weather = []
	for i in range(phase_lengths.size()):
		daily_weather.append([phase_progression[i], phase_lengths[i]])
	
	return daily_weather

func determine_phase_lengths():
	rng.randomize()
	var phase_lengths = []
	var phases_total = 7
	var phases_remaining = 7
	var changes_remaining
	
	var changes = random_integer_gauss(0.4,0.8)
	changes_remaining = changes
	if changes == 0:
		phase_lengths.append(phases_total + 1)
	else:
		for i in range(changes + 1):
			if i == changes:
				var phase_duration = phases_remaining + 1
				phase_lengths.append(phase_duration)
			else:
			
				var phase_duration = rng.randi_range(1, phases_remaining - changes_remaining)

				phase_lengths.append(phase_duration)
				phases_remaining -= phase_duration
				changes_remaining -= 1
	
	return phase_lengths

func determine_phase_progression(phase_count):
	rng.randomize()
	var phase_progression = []
	var most_recent_weather_phase
	
	phase_progression.append(determine_initial_weather())
	phase_count -= 1
	for i in range(phase_count):
		phase_progression.append(determine_next_weather(phase_progression[i]))
	
	return phase_progression

func determine_initial_weather():
	var selected_weather
	
	var total_weight = 0
	for weight in weather_weights:
		total_weight += weight
	
	for i in range(weather_weights.size()):
		if rng.randi_range(0, total_weight) < weather_weights[i]:
			selected_weather = weather_types[i]
			break
		elif i == weather_weights.size() - 1:
			selected_weather = weather_types[0]
		total_weight -= weather_weights[i]

	return selected_weather

func determine_next_weather(previous_weather):
	var selected_weather
	
	var total_weight = 0
	for weight in previous_weather.weather_transition_weights:
		total_weight += weight
	
	for i in range(previous_weather.weather_transition_weights.size()):
		if rng.randi_range(0, total_weight) < previous_weather.weather_transition_weights[i]:
			selected_weather = weather_types[i]
			break
		elif i == previous_weather.weather_transition_weights.size() - 1:
			selected_weather = weather_types[0]
		total_weight -= previous_weather.weather_transition_weights[i]

	return selected_weather

func cycle_weather():
	
	if current_weather.id >= weather_types.size() - 1:
		change_weather([weather_types[0], 8])
	else:
		change_weather([weather_types[current_weather.id + 1], 8])


func random_integer_gauss(mean, dev):
	return int(round(abs(rng.randfn(mean, dev))))
