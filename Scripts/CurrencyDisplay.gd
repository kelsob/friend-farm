extends HBoxContainer

onready var counter_label = $CounterLabel

func _on_currency_changed(currency):
	counter_label.text = String(currency)
