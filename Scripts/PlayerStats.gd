extends Resource
class_name Stats

# ENERGY VARIABLES
var max_energy = 100
var current_energy = max_energy

# FOOD STATUS / DIGESTION VARIABLES:
var food_capacity : float = 100.0
var food_current : float = 0.0
var digestion_efficiency : float = 1.0
var digestion_rate : float = 1.0
const default_digestion_rate : float = 4.0
var digestion_progression : float = 0.0

# CURRENCY VARIABLES
var currency : int = 0

var levelable_stats = [load("res://Resources/LevelableStatResources/Farmiculture.tres"),
	load("res://Resources/LevelableStatResources/Friendshipness.tres"),
	load("res://Resources/LevelableStatResources/Fitnessness.tres"),
	load("res://Resources/LevelableStatResources/Craftion.tres"),
	load("res://Resources/LevelableStatResources/Chefability.tres"),
	load("res://Resources/LevelableStatResources/Flukelihood.tres"),
	load("res://Resources/LevelableStatResources/Trigonometry.tres")]

signal experience_gained(experience)
signal levelled_up(f_level)
signal current_energy_changed(current_energy)
signal max_energy_changed(current_max_energy)
signal display_initialized(current_energy, current_max_energy)
signal food_capacity_changed(food_capacity)
signal food_current_changed(food_current)
signal digestion_efficiency_changed(digestion_efficiency)
signal digestion_rate(digestion_rate)
signal currency_changed(currency)

func _ready():
	for levelable_stat in levelable_stats:
		levelable_stat.initialize(self)

func _process(delta):
	if food_current > 0:
		digestion_progression += delta * digestion_rate
		if digestion_progression >= default_digestion_rate:
			digest()
			digestion_progression = 0.0

func digest():
	food_current = clamp(food_current - 1, 0.0, 100.0)
	current_energy += 1 * digestion_efficiency
	current_energy = clamp(current_energy, 0, max_energy)
	emit_signal('food_current_changed', food_current)
	emit_signal('current_energy_changed', current_energy)

func food_gained(gain):
	food_current = clamp(food_current + gain, 0, food_capacity)
	emit_signal("food_current_changed", food_current)

func experience_gained(gain, id):
	levelable_stats[id].exp_gained(gain)

func currency_changed(currency_change):
	currency = clamp(currency + currency_change, 0, 9999999)
	emit_signal("currency_changed", currency)
	Dialogic.set_variable("PlayerCurrency", currency)

func time_advanced():
	pass

func gain_energy(gain):
	current_energy += gain
	current_energy = clamp(current_energy, 0, max_energy)
	emit_signal("current_energy_changed", current_energy)

func lose_energy(loss):
	current_energy -= loss
	current_energy = clamp(current_energy, 0, max_energy)
	emit_signal("current_energy_changed", current_energy)

func initialize_display():
	emit_signal("display_initialized", current_energy, max_energy)
