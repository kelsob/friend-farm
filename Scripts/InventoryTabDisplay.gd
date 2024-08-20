extends Control
var item_display_scene = load("res://Scenes/UI/ItemDisplay.tscn")

onready var item_container = $ItemContainer/VBoxContainer
onready var scroll_container = $ItemContainer

var selected_item

signal item_focus_entered(item_display_object, item)

func _ready():
	set_process(false)

func _process(delta):
	
	if selected_item != null:
		if Input.is_action_just_pressed("ui_left"):
			selected_item.select_different_quality(-1)
		elif Input.is_action_just_pressed("ui_right"):
			selected_item.select_different_quality(1)
	
func initialize(inventory_tab):
	name = inventory_tab.name
	
	inventory_tab.connect("items_changed", self, "_on_items_changed")
	inventory_tab.connect("stack_size_changed", self, "_on_stack_size_changed")
	inventory_tab.connect("item_added", self, "_on_item_added")

func _on_stack_size_changed(item_index, stack_size):
	item_container.get_child(item_index).item.quantity_added(stack_size)

func _on_item_added(item):
	var item_display = item_display_scene.instance()
	item_container.add_child(item_display)
	
	item_display.connect("item_focus_entered", self, "_on_item_focus_entered")
	item_display.initialize_base_item(item)

func _on_items_changed(indexes):
	for item_index in indexes:
		pass

func tab_opened():
	if item_container.get_child_count() == 0:
		selected_item = null
		get_parent().get_parent().selected_item = null
	else:
		selected_item = item_container.get_child(0)
		selected_item.grab_focus()
		scroll_container.scroll_vertical = 0

func tab_closed():
	set_process(false)

func _on_item_focus_entered(item_display_object, item):
	selected_item = item_display_object
	emit_signal("item_focus_entered", item_display_object, item)
