extends Panel

var default_tex = preload("res://Assets/UI/HotBar/ItemSlotDefault.png")
var empty_tex = preload("res://Assets/UI/HotBar/ItemSlotDefault.png")
var selected_tex = preload("res://Assets/UI/HotBar/ItemSlotDefault.png")

var default_style: StyleBoxTexture = null
var empty_style: StyleBoxTexture = null
var selected_style: StyleBoxTexture = null

var ItemClass = preload("res://Scenes/UI/ItemHotBarDisplay.tscn")
var item = null
var item_object = null
var slot_index

var PlayerInventory

var selected : bool = false
var item_object_held : bool = false

onready var hotbar_label = $HotbarLabel
onready var selected_texture = $SelectedTexture
onready var hovered_texture = $HoveredTexture

signal hotbar_item_quantity_depleted(slot)

signal slot_focus_entered(slot_index)
signal slot_focus_exited(slot_index)

signal slot_object_held(slot, item_object)
signal slot_object_clicked(slot, item_object)
signal held_item_released()

signal slot_mouse_entered(slot)
signal slot_mouse_exited(slot)

signal slot_selected(slot)

enum SlotType {
	HOTBAR = 0,
	INVENTORY,
	SHIRT,
	PANTS,
	SHOES,
}

var slotType = null

func _ready():
	PlayerInventory = get_tree().current_scene.get_node("UI/InventoryMaster").inventory
	default_style = StyleBoxTexture.new()
	empty_style = StyleBoxTexture.new()
	selected_style = StyleBoxTexture.new()
	default_style.texture = default_tex
	empty_style.texture = empty_tex
	selected_style.texture = selected_tex

	item_object = ItemClass.instance()
	add_child(item_object)
	item_object.set_item(null)
	item_object.position = Vector2(8,8)

func pickFromSlot():
	if item != null:
		item_object.clear_item()
		item = null

func putIntoSlot(new_item):
	item = new_item
	item.connect('quantity_changed', self, '_on_item_quantity_changed')
	item.connect('quantity_depleted', self, '_on_item_quantity_depleted')
	
	item_object.set_item(item)
	item_object.position = Vector2(8, 8)

func _on_item_quantity_changed(item, new_quantity):
	if new_quantity == 0:
		pickFromSlot()
		get_parent().get_parent().clear_active_item()
	else:
		item_object.set_quantity(new_quantity)

func _on_item_quantity_depleted(item):
	emit_signal("hotbar_item_quantity_depleted", self)

func item_updated(item_init):
	clear_item()
	if item_init == item:
		return
	
	item = item_init
	item.connect('quantity_changed', self, '_on_item_quantity_changed')
	item_object.set_item(item_init)

func item_used():
	item.reduce_quantity()

func _on_self_gui_input(event):
	if item == null:
		return
	if event is InputEventMouseButton:
		hovered_texture.visible = false
		
		if event.button_index == 1 && event.pressed:
			emit_signal('slot_object_clicked', self, item_object)

			if item != null:
				emit_signal("slot_selected", self)

			yield(get_tree(), "idle_frame")
			yield(get_tree(), "idle_frame")
			yield(get_tree(), "idle_frame")
			
			if Input.is_mouse_button_pressed(1):
				emit_signal('slot_object_held', self, item_object)
				item_object_held = true
				mouse_filter = MOUSE_FILTER_IGNORE

func clear_active():
	deselected()

func selected():
	selected_texture.visible = true

func deselected():
	selected_texture.visible = false

func _on_self_mouse_entered():
	hovered_texture.visible = true
	emit_signal("slot_mouse_entered", self)

func _on_self_mouse_exited():
	hovered_texture.visible = false
	emit_signal("slot_mouse_exited", self)

func clear_item():
	item_object.clear_item()
	item = null
	selected = false
