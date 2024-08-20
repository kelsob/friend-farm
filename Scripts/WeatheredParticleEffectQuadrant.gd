extends Particles2D

var rect_size = Vector2(960, 640)
var default_position : Vector2

func _ready():
	default_position = position
	var shifts = get_node("Area2DShifts").connect("shift_area_entered", self, "_on_Area2DShifts_shift_area_entered")

func _on_Area2DShifts_shift_area_entered(move_vector):
	position += rect_size * move_vector

func reset_default_position():
	position = default_position
