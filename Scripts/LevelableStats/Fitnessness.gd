extends LevelableStat
class_name FitnessnessStat

var sprint_efficiency : int = 10
var tool_efficiency : float = 1.0
var maximum_energy_buff : int =  0

func level_1_reached():
	tool_efficiency += 0.2
	maximum_energy_buff = 5
	sprint_efficiency = 10

func level_2_reached():
	tool_efficiency += 0.2
	sprint_efficiency = 13
	maximum_energy_buff = 10

func level_3_reached():
	tool_efficiency += 0.2
	maximum_energy_buff = 15
	sprint_efficiency = 17

func level_4_reached():
	tool_efficiency += 0.2
	sprint_efficiency = 22
	maximum_energy_buff = 25

func level_5_reached():
	tool_efficiency += 0.2
	sprint_efficiency = 28
	maximum_energy_buff = 35

func level_6_reached():
	tool_efficiency += 0.2
	sprint_efficiency = 35
	maximum_energy_buff = 50
