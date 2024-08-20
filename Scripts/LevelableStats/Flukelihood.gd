extends LevelableStat
class_name FlukelihoodStat

var flukelihood_base : float = 0.0
var flukelihood_actual : float = 0.0
var positive_duration : int = 0
var negative_duration : int = 0

var mods : Array = []

func level_1_reached():
	flukelihood_base = 0.1

func level_2_reached():
	positive_duration += 1
	flukelihood_base = 0.15

func level_3_reached():
	negative_duration -= 1
	flukelihood_base = 0.2

func level_4_reached():
	positive_duration += 2
	flukelihood_base = 0.25

func level_5_reached():
	negative_duration -= 1
	flukelihood_base = 0.35

func level_6_reached():
	positive_duration += 3
	negative_duration -= 1
	flukelihood_base = 0.4

func add_mod(mod):
	
	if mod[0] < 0:
		mod[1] += negative_duration
	elif mod[1] > 0:
		mod[1] += positive_duration
	
	mods.append(mod)
	update()

func update():
	var mod_sum = 0.0
	for mod in mods:
		mod_sum += mod[0]
	flukelihood_actual = flukelihood_base + mod_sum

func day_phase_entered():
	for mod in mods:
		mod[1] -= 1

	var mod_ended = true
	while mod_ended:
		mod_ended = false
		for mod in mods:
			if mod[1]:
				mod_ended = true
				mods.erase(mod)
				break
	
	update()
