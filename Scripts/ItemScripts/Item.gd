extends Resource
class_name Item

export (String) var name = ""
export (String, MULTILINE) var description = ""

export (bool) var sellable = true
export (int) var energy_cost = 1
export (int) var pal_value_base = 0
export (int) var pal_value_actual = 0
export (Texture) var texture
export (bool) var unique = false
export (float) var quality = 0.0

export (Resource) var quality_tier_resource = load("res://Resources/QualityTierResources/0.tres")

var player_use_animations = []

export (bool) var stackable = false
export (int) var max_stack_size = 1
export (int) var current_stack_size = 1

export (bool) var single_use = false
export (bool) var hotbar_assignable = true
export (bool) var capacitied_item = false

var inventory_display_object : Object

export var player_encountered : bool = false

enum ItemType {ITEM, KEY_ITEM, CROP, FOOD, SEED, PLANT, MATERIAL, TOOL, BUILDABLE, VENDOR_TRASH}
export var item_type = ItemType.ITEM

signal quantity_changed(item, quantity)
signal quantity_depleted(item)

func _ready():
	quality_tier_resource = quality_tier_resource.duplicate()

func used(player, current_scene):
	print('item used!')

func quantity_added(new_quantity):
	current_stack_size += new_quantity
	emit_signal('quantity_changed', self, current_stack_size)

func get_tile_position(player):
	var desired_location = player.get_global_position() + player.facing_vector - player.grid_offset
	
	return desired_location

func check_item_usability(player):
	pass

func use_item(player, current_scene):
	pass

func reduce_quantity():
	if single_use:
		current_stack_size -= 1
		emit_signal("quantity_changed", self, current_stack_size)
		if current_stack_size == 0:
			emit_signal("quantity_depleted", self)

func improve_quality(quality_improvement):
	quality += quality_improvement
	if quality >= quality_tier_resource.quality_threshold_to_next:
		improve_quality_tier()

func improve_quality_tier():
	if quality_tier_resource.next_quality_tier != null:
		quality_tier_resource = quality_tier_resource.next_quality_tier.duplicate()
		if quality >= quality_tier_resource.quality_threshold_to_next:
			improve_quality_tier()
			return
	reassign_values()

func override_quality(quality_tier):
	quality_tier_resource = load("res://Resources/QualityTierResources/" + String(quality_tier) +  ".tres")
	quality = quality_tier_resource.quality_threshold
	reassign_values()

func reassign_values():
	var progression_value_percentage : float = (quality - quality_tier_resource.quality_threshold)/(quality_tier_resource.quality_threshold_to_next - quality_tier_resource.quality_threshold)
	pal_value_actual = pal_value_base + pow(0.2 * float(pal_value_base), quality_tier_resource.tier + progression_value_percentage)

func return_tooltip():
	return description
