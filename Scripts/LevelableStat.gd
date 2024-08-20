extends Resource
class_name LevelableStat

export (int) var id = 0
export (String) var name = "Levelable stat."
export (String, MULTILINE) var description = "Stat description!"
export (Array, String) var level_nicknames = ["","","","","","",""]
export (Array, String, MULTILINE) var level_descriptions = ["","","","","","",""] 

export (int) var current_level = 0
export (Array, int) var experience_curve = [100,250,500,1000,2500,5000]
export (int) var total_levels = 6

export (bool) var hidden = false

var current_experience : int = 0
var progression_to_next_level : float = 0.0

signal leveled_up(level)
signal experience_gained(experience)
signal max_level_reached()

func initialize(player_stats_init):
	pass

func exp_gained(exp_gain):
	# Player is at max level for this stat.
	if current_level == total_levels - 1:
		return
	
	current_experience += exp_gain

	# Checking for level up
	if current_experience >= experience_curve[current_level]:
		level_up()
	
	progression_to_next_level = (current_experience - int(bool(current_level)) * experience_curve[current_level]) / experience_curve[current_level]

func level_up():
	progression_to_next_level = 0.0
	current_level += 1
	
	match current_level:
		1:
			level_1_reached()
		2:
			level_2_reached()
		3:
			level_3_reached()
		4:
			level_4_reached()
		5:
			level_5_reached()
		6:
			level_6_reached()
	
	emit_signal('leveled_up', current_level)
	if current_level == total_levels - 1:
		emit_signal("max_level_reached")


# Override these functions in the child stats to give them specific functionality at each level up.
func level_1_reached():
	print("Stat ", name, " ", "level 1 reached!")

func level_2_reached():
	print("Stat ", name, " ", "level 2 reached!")

func level_3_reached():
	print("Stat ", name, " ", "level 3 reached!")

func level_4_reached():
	print("Stat ", name, " ", "level 4 reached!")

func level_5_reached():
	print("Stat ", name, " ", "level 5 reached!")

func level_6_reached():
	print("Stat ", name, " ", "level 6 reached!")
