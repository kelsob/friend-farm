extends Resource
class_name WeatherType

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

export (String) var name = "Weather"
export (int) var id = 0
export (int) var node_id = 0
export (Array, Color) var color_progression = [Color.dimgray, Color.lavender, Color.white, Color.lightskyblue, Color.skyblue, Color.darkblue, Color.midnightblue, Color.midnightblue]
export (Array, int) var light_level_progression = [0.4, 0.7, 1.0, 0.8, 0.5, 0.2, 0.0]
export (int) var precipitation_level = 0
export (Array, int) var weather_transition_weights = [10,10,10,10,10,10,10,10,10,10,10]
