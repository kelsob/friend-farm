extends LevelableStat
class_name ChefabilityStat

var quality_improvement : float = 0.0
var ingredient_reduction : float = 0.0
var cost_improvement : float = 0.0
var output_multiplier : float = 0.0

func level_1_reached():
	quality_improvement += 0.25

func level_2_reached():
	cost_improvement += 0.25
	quality_improvement += 0.25

func level_3_reached():
	ingredient_reduction += 0.25
	quality_improvement += 0.25

func level_4_reached():
	output_multiplier += 0.5

func level_5_reached():
	quality_improvement += 0.25
	ingredient_reduction += 0.25

func level_6_reached():
	quality_improvement += 0.25
	cost_improvement += 0.25
