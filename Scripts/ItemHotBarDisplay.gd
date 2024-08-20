extends Node2D

var item_name : String
var item_quantity : int

var item : Item

onready var counter_label = $CounterLabel
onready var texture = $TextureRect
onready var progress_bar = $TextureRect/TextureProgress

func set_item(item_init):
	if item_init == null:
		return
	
	item = item_init
	refresh_display()

func set_quantity(new_quantity):
	counter_label.text = String(new_quantity)

func clear_item():
	if item != null:
	
		item_name = ""
		item_quantity = 0
		
		if item.capacitied_item:
			item.disconnect("stored_quantity_changed", self, "_on_item_stored_quantity_changed")
		
		item.disconnect('quantity_changed', get_parent(), '_on_item_quantity_changed')

		item = null
		refresh_display()

func refresh_display():
	if item == null:
		texture.texture = null
		item_quantity = 0
		counter_label.visible = false
		counter_label.text = String(item_quantity)
		progress_bar.visible = false
	
	else:
		texture.texture = item.texture
		item_quantity = item.current_stack_size
		if item.single_use:
			counter_label.visible = true
			counter_label.text = String(item_quantity)
		else:
			counter_label.visible = false
	
		if item.capacitied_item:
			initialize_progress_bar()

func initialize_progress_bar():
	progress_bar.visible = true
	progress_bar.max_value = item.capacity
	progress_bar.min_value = 0
	progress_bar.value = item.stored_quantity
	item.connect("stored_quantity_changed", self, "_on_item_stored_quantity_changed")

func _on_item_stored_quantity_changed(new_quantity):
	progress_bar.value = new_quantity
