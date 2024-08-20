extends Resource
class_name Inventory

export (Array, Resource) var item_tabs = [
	preload("res://Resources/InventoryTabResources/Items.tres"),
	preload("res://Resources/InventoryTabResources/Food.tres"),
	preload("res://Resources/InventoryTabResources/Seeds.tres"),
	preload("res://Resources/InventoryTabResources/Crops.tres"),
	preload("res://Resources/InventoryTabResources/Tools.tres"),
	preload("res://Resources/InventoryTabResources/Buildables.tres"),
	preload("res://Resources/InventoryTabResources/Materials.tres"),
	preload("res://Resources/InventoryTabResources/KeyItems.tres")
]
export (Array, Resource) var item_tabs_unlocked = [
]

enum ItemType {ITEM, KEY_ITEM, CROP, FOOD, SEED, PLANT, MATERIAL, TOOL, VENDOR_TRASH}

var buildables_tab : InventoryTab

var hotbar_items = [null,
	 null,
	 null,
	 null,
	 null,
	 null,
	 null,
	 null]

export (int) var gold_pals = 0

signal items_changed()
signal item_added(item)
signal stack_size_changed(item_index, stack_size)
signal currency_changed(currency)

signal update_hotbar_display(hotbar_position, item)
signal create_inventory_tab(inventory_tab)
signal buildable_item_entry_created(item)

func initialize_display():
	item_tabs = [
	load("res://Resources/InventoryTabResources/Items.tres"),
	load("res://Resources/InventoryTabResources/Food.tres"),
	load("res://Resources/InventoryTabResources/Seeds.tres"),
	load("res://Resources/InventoryTabResources/Crops.tres"),
	load("res://Resources/InventoryTabResources/Tools.tres"),
	load("res://Resources/InventoryTabResources/Buildables.tres"),
	load("res://Resources/InventoryTabResources/Materials.tres"),
	load("res://Resources/InventoryTabResources/KeyItems.tres")
]
	
	for tab in item_tabs:
		if tab.tab_unlocked:
			item_tabs_unlocked.append(tab)
			emit_signal("create_inventory_tab", tab)
			if tab.item_types_held[0] == 8:
				buildables_tab = tab

func add_item(new_item):
	
	
	var item_added
	if new_item.unique:
		item_added = add_unique_item(new_item)
	elif new_item.stackable:
		add_stackable_item(new_item)
	else:
		create_new_item_entry(new_item)

func add_unique_item(new_item):
	var item_found = false
	for tab in item_tabs_unlocked:
		for item in tab.items:
			if item.name == new_item.name:
				item_found = true
	
	if !item_found:
		create_new_item_entry(new_item)
	
	return item_found

func add_stackable_item(new_item):
	var item_found = false
	var item_stack = null
	for tab in item_tabs_unlocked:
		for item in tab.items:
			if item.name == new_item.name:
				item_stack = item
				item_found = true
	
	if !item_found:
		create_new_item_entry(new_item)
	else:
		if item_stack.inventory_display_object.has_quality_tier(new_item.quality_tier_resource.tier):
			stack_same_quality(new_item, item_stack)
		else:
			create_new_quality_stack(new_item, item_stack)

func stack_same_quality(new_item, item_stack):
	item_stack.inventory_display_object.stack_same_quality_tier(new_item)

func create_new_quality_stack(new_item, item_stack):
	item_stack.inventory_display_object.add_new_quality_tier(new_item)

func create_new_item_entry(new_item):
	if new_item is BuildableItem:
		emit_signal('buildable_item_entry_created', new_item)
	
	var tab_selected
	
	for tab in item_tabs_unlocked:
		for item_type_held in tab.item_types_held:
			if item_type_held == new_item.item_type && !tab.full:
				tab_selected = tab
	
	if tab_selected == null && !item_tabs_unlocked[0].full:
		tab_selected = item_tabs_unlocked[0]
		tab_selected.add_item(new_item)
		return [true]
	
	elif tab_selected == null && item_tabs_unlocked[0].full:
		return [false, new_item]
	
	elif tab_selected != null:
		tab_selected.add_item(new_item)
		return [true]

func unique_stackability_check(new_item):
	var tabs_unique_stackability = []
	
	for tab in item_tabs_unlocked:
		tabs_unique_stackability.append(tab.unique_stackability_check(new_item))
		if new_item.current_stack_size == 0:
			break
	
	return tabs_unique_stackability
	
func gold_gained(gain):
	gold_pals += gain
	emit_signal("currency_changed", gold_pals)

func gold_lost(loss):
	gold_pals -= loss
	gold_pals = clamp(gold_pals, 0, 999999999)
	emit_signal("currency_changed", gold_pals)

# HOTBAR RELATED FUNCTIONALITY
func inventory_assigned_hotbar_item(hotbar_position, item):
	if item == null:
		return
	if !item.hotbar_assignable:
		return
	
#	hotbar_items[hotbar_position] = item
	emit_signal("update_hotbar_display", hotbar_position, item)

func add_hotbar_item(item, slot):
	pass

func remove_hotbar_item(item, slot):
	pass
# END OF HOTBAR RELATED FUNCTIONALITY

# BUILD HOTBAR RELATED FUNCTIONALITY

func get_buildable_items():
	return buildables_tab.items
