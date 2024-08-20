extends Node2D

const SlotClass = preload("res://Scripts/HotbarSlot.gd")
onready var hotbar_slots = $HotbarSlots
onready var active_item_label = $ActiveItemLabel
onready var slots = hotbar_slots.get_children()

enum HotbarOrientation {HORIZONTAL, VERTICAL}
var orientation = HotbarOrientation.HORIZONTAL

var positions_array = [Vector2(160, 148), Vector2(12, 80)]

var active_item_slot_index : int = -1
var active_item
var held_item_object : Node = null

var held_item_slot : SlotClass = null
var mouse_hovered_slot : SlotClass = null

var PlayerInventory
var player

func _ready():
	player = get_tree().current_scene.find_node("Player")
	PlayerInventory = get_tree().current_scene.get_node("UI/InventoryMaster").inventory
	PlayerInventory.connect("update_hotbar_display", self, "_on_hotbar_item_updated")
	
	for i in range(slots.size()):
		slots[i].connect("slot_object_held", self, "_slot_object_held")
		slots[i].connect("slot_object_clicked", self, "_slot_object_clicked")
		slots[i].connect("held_item_released", self, "_held_item_released")
		slots[i].connect("slot_mouse_entered", self, "_slot_mouse_entered")
		slots[i].connect("slot_mouse_exited", self, "_slot_mouse_exited")
		slots[i].connect("slot_selected", self, "_slot_selected")
		slots[i].slotType = SlotClass.SlotType.HOTBAR
		slots[i].slot_index = i
		slots[i].hotbar_label.text = String(i + 1)

func inventory_opened():
	rotation_degrees = 90
	orientation = HotbarOrientation.VERTICAL
	for slot in slots:
		position = positions_array[orientation]
		slot.rect_rotation = -90
	active_item_label.active = false
	active_item_label.visible = false

func inventory_closed():
	rotation_degrees = 0
	orientation = HotbarOrientation.HORIZONTAL
	for slot in slots:
		position = positions_array[orientation]
		slot.rect_rotation = 0
	active_item_label.active = true

func _slot_selected(slot):
	slots[active_item_slot_index].deselected()
	active_item = slot.item_object.item

	active_item_slot_index = slot.slot_index
	slots[active_item_slot_index].selected()
	player.equip_item(active_item)

func _slot_object_held(slot, item_object):
	print('object being held')

	held_item_slot = slot
	held_item_object = item_object
	held_item_object.global_position = get_global_mouse_position()
	
func _slot_object_clicked(slot, item_object):
	pass

func _held_item_released():
	yield(get_tree(), "idle_frame")
	
	if mouse_hovered_slot != held_item_slot && mouse_hovered_slot != null:
		if mouse_hovered_slot.item == null:
			move_held_item_to_slot()
		else:
			swap_items()
	
	return_held_item_to_slot()

func swap_items():
	var temp_item = held_item_object.item
	
	held_item_slot.pickFromSlot()
	held_item_slot.putIntoSlot(mouse_hovered_slot.item_object.item)
	
	mouse_hovered_slot.pickFromSlot()
	mouse_hovered_slot.putIntoSlot(temp_item)

	held_item_slot.deselected()
	return_held_item_to_slot()
	
	active_item_slot_index = mouse_hovered_slot.slot_index
	active_item = mouse_hovered_slot.item

	held_item_object = null
	held_item_slot = null
	mouse_hovered_slot.selected()
	update_item_label_selected(active_item)
	player.equip_item(active_item)

func clear_active_item():
	player.unequip_item()
	slots[active_item_slot_index].clear_active()
	active_item = null
	active_item_slot_index = -1
	active_item_label.clear_text()

func assign_active_item(hotbar_slot):
	if slots[hotbar_slot].item != null:
		slots[active_item_slot_index].deselected()
		slots[hotbar_slot].selected()
		active_item_slot_index = hotbar_slot
		active_item = slots[active_item_slot_index].item
		update_item_label_selected(active_item)
		player.equip_item(active_item)
	else:
		slots[active_item_slot_index].deselected()
		slots[hotbar_slot].selected()
		active_item_slot_index = hotbar_slot
		active_item = null
		player.equip_item(active_item)
		active_item_label.clear_text()

func _process(delta):
	if held_item_object != null && Input.is_action_just_released("left_click"):
		_held_item_released()
	elif held_item_object:
		held_item_object.global_position = get_global_mouse_position()
	
	if Input.is_action_just_released("Hotbar1"):
		assign_active_item(0)
	elif Input.is_action_just_released("Hotbar2"):
		assign_active_item(1)
	elif Input.is_action_just_released("Hotbar3"):
		assign_active_item(2)
	elif Input.is_action_just_released("Hotbar4"):
		assign_active_item(3)
	elif Input.is_action_just_released("Hotbar5"):
		assign_active_item(4)
	elif Input.is_action_just_released("Hotbar6"):
		assign_active_item(5)
	elif Input.is_action_just_released("Hotbar7"):
		assign_active_item(6)
	elif Input.is_action_just_released("Hotbar8"):
		assign_active_item(7)

func _slot_mouse_entered(slot):
	mouse_hovered_slot = slot
	if mouse_hovered_slot.item != null:
		update_item_label_selected(mouse_hovered_slot.item)
	else:
		active_item_label.clear_text()

func _slot_mouse_exited(slot):
	mouse_hovered_slot = null

func update_item_label_selected(item):
	active_item_label.set_text(item)

func return_held_item_to_slot():
	if held_item_object != null and held_item_object != null:
		held_item_slot.mouse_filter = 0
		held_item_object.position = Vector2(8,8)
		held_item_object = null
		held_item_slot = null

func move_held_item_to_slot():
	mouse_hovered_slot.putIntoSlot(held_item_object.item)
	held_item_object.position = Vector2(8, 8)
	held_item_slot.mouse_filter = 1
	held_item_slot.pickFromSlot()
	
	active_item_slot_index = mouse_hovered_slot.slot_index
	active_item = mouse_hovered_slot.item
	held_item_slot.deselected()
	held_item_object = null
	held_item_slot = null
	mouse_hovered_slot.selected()
	update_item_label_selected(active_item)
	player.equip_item(active_item)

func _on_hotbar_item_updated(hotbar_position, item):
	var item_index = -1
	for slot in slots:
		if slot.item == item:
			item_index = slot.slot_index
	
	if item_index != -1:
		if item_index != hotbar_position:
			slots[item_index].clear_item()
			if item_index == active_item_slot_index:
				clear_active_item()
	
	if hotbar_position == active_item_slot_index:
		clear_active_item()
	
	slots[hotbar_position].item_updated(item)

func left_click_empty_slot(slot: SlotClass):
	print('empty slot left clicked')
	PlayerInventory.add_hotbar_item(held_item_object, slot)
	slot.putIntoSlot(held_item_object.item)
	held_item_object.position = Vector2(8, 8)
	held_item_object.clear_item()
#	held_item_object.visible = true
	held_item_object = null
	held_item_slot.pickFromSlot()
	held_item_slot = null

func left_click_different_item(event: InputEvent, slot: SlotClass):
	print('different item slot left clicked')
	var temp_item = held_item_object.item
	
	held_item_slot.pickFromSlot()
	held_item_slot.putIntoSlot(slot.item_object.item)
	
	slot.pickFromSlot()
	slot.putIntoSlot(temp_item)
	held_item_object.position = Vector2(8, 8)
	held_item_object = null
	held_item_slot = null

func left_click_same_item(slot: SlotClass):
	print('same item slot left clicked')
	return

