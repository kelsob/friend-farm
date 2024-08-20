extends Node2D

signal shift_area_entered(move_vector)

func _on_Area2DLeft_body_entered(body):
	if body is Player:
		emit_signal('shift_area_entered', Vector2(-1,0))


func _on_Area2DRight_body_entered(body):
	if body is Player:
		emit_signal('shift_area_entered', Vector2(1,0))


func _on_Area2DUp_body_entered(body):
	if body is Player:
		emit_signal('shift_area_entered', Vector2(0,-1))


func _on_Area2DDown_body_entered(body):
	if body is Player:
		emit_signal('shift_area_entered', Vector2(0,1))
