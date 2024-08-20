extends Control

var inventory = preload("res://Resources/ItemResources/Inventory.tres")

var selected_item

onready var tab_container = $InventoryTabContainer
onready var item_description_panel = $ItemDescriptionPanel
onready var overalls_panel = $OverallsPanel
onready var selected_tab = tab_container.current_tab
onready var tab_label = $TabLabel
onready var item_selection_indicator = $ItemSelectionIndicator

func _ready():
	set_process_input(false)
	inventory.connect("create_inventory_tab", tab_container, "_on_inventory_tab_created")
	inventory.initialize_display()
	inventory.connect("currency_changed", get_tree().current_scene.get_node("UI/CurrencyDisplay"), "_on_currency_changed")

func open():
	selected_item = null
	item_description_panel.clear_item()
	set_process_input(true)
	visible = true
	tab_container.inventory_opened()

func close():
	get_tree().current_scene.get_node("UI").close_inventory()
	set_process_input(false)
	visible = false
	Input.action_release("ui_inventory")
	get_tree().current_scene.player.activate()
	tab_container.inventory_closed()
	item_selection_indicator.hide_all_arrows()

func _input(delta):
	
	if Input.is_action_just_pressed("ui_inventory"):
		close()
	elif Input.is_action_just_released("Hotbar1") and selected_item != null:
		inventory.inventory_assigned_hotbar_item(0, selected_item)
	elif Input.is_action_just_released("Hotbar2") and selected_item != null:
		inventory.inventory_assigned_hotbar_item(1, selected_item)
	elif Input.is_action_just_released("Hotbar3") and selected_item != null:
		inventory.inventory_assigned_hotbar_item(2, selected_item)
	elif Input.is_action_just_released("Hotbar4") and selected_item != null:
		inventory.inventory_assigned_hotbar_item(3, selected_item)
	elif Input.is_action_just_released("Hotbar5") and selected_item != null:
		inventory.inventory_assigned_hotbar_item(4, selected_item)
	elif Input.is_action_just_released("Hotbar6") and selected_item != null:
		inventory.inventory_assigned_hotbar_item(5, selected_item)
	elif Input.is_action_just_released("Hotbar7") and selected_item != null:
		inventory.inventory_assigned_hotbar_item(6, selected_item)
	elif Input.is_action_just_released("Hotbar8") and selected_item != null:
		inventory.inventory_assigned_hotbar_item(7, selected_item)

func _on_item_focus_entered(item_display_object, item):
	item_selection_indicator.show_vertical_arrows()
	if item_display_object.item_qualities.size() > 1:
		item_selection_indicator.show_horizontal_arrows()
	else:
		item_selection_indicator.hide_horizontal_arrows()
	
	yield(get_tree(),"idle_frame")
	item_selection_indicator.set_global_position(Vector2(0,0))
	item_selection_indicator.set_global_position(item_display_object.selection_position.get_global_position())
	selected_item = item
	item_description_panel.display_item(item)

func _on_InventoryTabContainer_tab_changed(tab):
	overalls_panel.tab_changed(tab_container.get_child(tab))
	tab_label.text = tab_container.get_child(tab).name
	if tab_container.get_child(tab).item_container.get_child_count() == 0:
		item_selection_indicator.hide_all_arrows()
