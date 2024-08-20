extends LevelableStat
class_name FarmicultureStat

var crop_quality_improvement : float = 0.0
var seed_quality_retention : float = 0.0
var fertilizer_life_extension : int = 0

func level_1_reached():
	crop_quality_improvement += 0.25

func level_2_reached():
	seed_quality_retention += 0.25

func level_3_reached():
	fertilizer_life_extension += 1

func level_4_reached():
	crop_quality_improvement += 0.25

func level_5_reached():
	seed_quality_retention += 0.25

func level_6_reached():
	crop_quality_improvement += 0.25
	seed_quality_retention += 0.25
	fertilizer_life_extension += 1
