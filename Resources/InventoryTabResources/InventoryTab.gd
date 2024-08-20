extends Resource
class_name InventoryTab

enum ItemType {ITEM, KEY_ITEM, CROP, FOOD, SEED, PLANT, MATERIAL, TOOL, VENDOR_TRASH}

export (String) var name = ""

export (bool) var tab_unlocked = false
export (Array, Resource) var items = []

export (Array, int) var item_types_held = [-1]
export (int) var item_capacity = 8
export (Texture) var icon
export (bool) var full = false
export (bool) var empty = true

signal items_changed()
signal item_added(item)
signal stack_size_changed(item_index, stack_size)

func add_item(new_item):
	items.append(new_item)
	new_item.connect('quantity_changed', self, '_on_item_quantity_changed')
	new_item.connect('quantity_depleted', self, '_on_item_quantity_depleted')

	emit_signal("item_added", new_item)
	empty = false
	if items.size() == item_capacity:
		full = true

func _on_item_quantity_changed(item, new_quantity):
	pass

func _on_item_quantity_depleted(item):
	items.erase(item)

func unique_stackability_check(new_item):
	var type_match = false
	
	if item_types_held[0] == -1:
		type_match = true
	
	else:
		for item_type_held in item_types_held:
			if item_type_held == new_item.item_type:
				type_match = true

	var unique_item_found = false

	if type_match:
		for i in items.size():
			if items[i].name == new_item.name:
				if new_item.unique:
					unique_item_found = true
				elif new_item.stackable:
					if items[i].current_stack_size < items[i].max_stack_size && new_item.current_stack_size > 0:
						if items[i].current_stack_size + new_item.current_stack_size > items[i].max_stack_size:
							items[i].quantity_added(items[i].max_stack_size)
							new_item.current_stack_size -= items[i].max_stack_size - items[i].current_stack_size
#							items[i].current_stack_size = items[i].max_stack_size
#							emit_signal("stack_size_changed", i, new_item.max_stack_size)
						else:
							items[i].quantity_added(items[i].current_stack_size + new_item.current_stack_size)
#							items[i].current_stack_size += new_item.current_stack_size
							new_item.current_stack_size = 0
#							emit_signal("stack_size_changed", i, items[i].current_stack_size)
	
		return [unique_item_found, new_item.current_stack_size]
	else:
		return [unique_item_found, new_item.current_stack_size]
