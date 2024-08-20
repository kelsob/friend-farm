extends Area2D

var fertilizer_item
onready var sprite = $Sprite

func initialize(item):
	fertilizer_item = item.duplicate()
	modulate = fertilizer_item.color_modulate

func _on_area_entered(area):
	if area.has_method("fertilized") and fertilizer_item.uses != 0:
		area.fertilized(self)

func fertilizer_used():
	fertilizer_item.uses -= 1
	if fertilizer_item.uses != 0:
		sprite.frame = 3 - fertilizer_item.uses

func exhausted():
	queue_free()
