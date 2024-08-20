extends ColorRect

var lightChangeTime = 6
onready var tween = $Tween

func change_light(new_color: Color):
	
	# Animation for darkness change
	tween.interpolate_property(self, "color",
	color, new_color, lightChangeTime,
	Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
