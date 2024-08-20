extends TextureRect


var months = ['jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'oct', 'nov', 'dec']

onready var color_rect_current_month = $ColorRectCurrentMonth
onready var color_rect_next_month = $ColorRectNextMonth
onready var day_counter_label = $DayCounterLabel
onready var month_counter_label = $MonthCounterLabel
onready var page_sprite = $PageSprite

export (Array, Color) var colors_per_month = []
export (Array, int) var days_in_month = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
export (int) var current_month = 0
export (int) var current_day = 1

signal time_advance_completed()

func _ready():
	update_day_counter()
	update_month_counter()

func set_initial_date(time : Array):

	current_day = time[0]
	current_month = time[1]
	update_day_counter()
	update_month_counter()

func advance_day():
	current_day += 1
	if current_day > days_in_month[current_month]:
		current_day = 1
		current_month += 1
		if current_month == 12:
			current_month = 0
		update_month_counter()
	
	page_sprite.page_rip()
	emit_signal("time_advance_completed")

func update_month_counter():
	color_rect_current_month.color = colors_per_month[current_month]
	month_counter_label.text = months[current_month]

func update_day_counter():
	day_counter_label.text = String(current_day)
