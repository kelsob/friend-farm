extends Area2D

export (float) var shade_mod = 0.15

func _on_area_entered(area):
	if area.get_parent().has_method('shade_entered'):
		area.get_parent().shade_entered(shade_mod * get_parent().species.shade_buff_provided[get_parent().species.growth_stage - 1])

func _on_area_exited(area):
	if area.get_parent().has_method('shade_exited'):
		area.get_parent().shade_exited(shade_mod * get_parent().species.shade_buff_provided[get_parent().species.growth_stage - 1])
