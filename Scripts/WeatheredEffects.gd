extends Node2D

var weather_effect_regions

func _ready():
	set_process(false)
	set_physics_process(false)

	weather_effect_regions = get_children()
	weather_effect_regions.pop_back()

func weather_changed(weather_precipitation, weather_light):
	for weather_effect_region in weather_effect_regions:
		weather_effect_region.weather_changed(weather_precipitation, weather_light)
