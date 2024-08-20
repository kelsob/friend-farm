extends CanvasLayer

export (bool) var debug = false

onready var game_clock = $GameClock
onready var fuel_gauge = $FuelGauge
onready var inventory = $InventoryMaster
onready var currency_display = $CurrencyDisplay
onready var hotbar = $Hotbar
onready var godbox = $GodBox
onready var day_clock = $DayClock

func _ready():
	if debug:
		godbox.show()

func open_inventory():
	inventory.open()
	hotbar.inventory_opened()
	
	if debug:
		godbox.hide()

func close_inventory():
	hotbar.inventory_closed()
	
	if debug:
		godbox.show()

func disable_hotbar():
	hotbar.active_item_label.clear_text()
	hotbar.set_process(false)

func enable_hotbar():
	hotbar.set_process(true)

func advance_day():
	game_clock.advance_day()
	day_clock.advance_day()

func _on_DayClock_phase_entered(phase):
	get_parent()._on_DayClock_phase_entered(phase)


func _on_DayClock_time_incremented(current_time):
	get_parent()._on_DayClock_time_incremented(current_time)
