extends Item
class_name HarvestedCropItem

export (bool) var edible = true

export (float) var food_value_base = 5.0
export (float) var food_value_actual = 0.0

export (String) var player_use_animation = "Eat"
export (String) var player_use_animation_miss = "Eat"

func used(player, current_scene):
	
	player.eat(self)
	reduce_quantity()
	
	return true

func get_use_animations():
	player_use_animations = [player_use_animation, player_use_animation_miss]
	return player_use_animations

func reassign_values():
	var progression_value_percentage : float = (quality - quality_tier_resource.quality_threshold)/(quality_tier_resource.quality_threshold_to_next - quality_tier_resource.quality_threshold)
	pal_value_actual = int(floor(pal_value_base + ceil(pal_value_base * 0.25) * (quality_tier_resource.tier + progression_value_percentage)))
	food_value_actual = int(floor(food_value_base + ceil(food_value_base * 0.25) * (quality_tier_resource.tier + progression_value_percentage)))
	print(" food_value_actual:", food_value_actual, " pal_value_actual:", pal_value_actual)
	print(progression_value_percentage)

func return_tooltip():
	var energy_description = "\nReplenishes [sparkle freq=1.0 c1=#1eff00 c2=#94ff00]" + String(food_value_actual) + "[/sparkle] energy." 
	return description + energy_description
