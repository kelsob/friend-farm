extends Control

export var base_item : Resource
export (Array, Resource) var item_qualities

var displayed_quality_tier_index = -1
var quality_tier_display_object_scene = preload("res://Scenes/UI/ItemQualityTierDisplay.tscn")

onready var selection_position = $Position2D
onready var quality_tiers_holder = $QualityTiersHolder

signal item_focus_entered(item_object, tier_index)

func _ready():
	item_qualities = []

func initialize_base_item(item_init):
	base_item = item_init
	item_qualities.append(base_item)
	
	create_quality_tier_display(base_item)
	show()

func tier_depleted(tier_display):
	
	item_qualities.erase(tier_display.item)
	tier_display.queue_free()
	yield(get_tree(),"idle_frame")

	if quality_tiers_holder.get_child_count() == 0:
		queue_free()
	else:
		quality_tiers_holder.get_child(0).show()
		displayed_quality_tier_index = 0

func create_quality_tier_display(item):
	var quality_tier_display_object = quality_tier_display_object_scene.instance()
	quality_tiers_holder.add_child(quality_tier_display_object)
	quality_tier_display_object.intialize(item)
	var index_position = 0
	for quality_tier_display_object_child in quality_tiers_holder.get_children():
		if quality_tier_display_object.quality_resource.tier < item.quality_tier_resource.tier:
			index_position += 1
	
	quality_tiers_holder.move_child(quality_tier_display_object, index_position)
	
	item.connect('quantity_changed', quality_tier_display_object, '_on_item_quantity_changed')
	item.connect('quantity_depleted', quality_tier_display_object, '_on_item_quantity_depleted')
	item.inventory_display_object = self
	
	for quality_tier in quality_tiers_holder.get_children():
		quality_tier.hide()
	quality_tiers_holder.get_child(index_position).show()
	
	if displayed_quality_tier_index == -1:
		displayed_quality_tier_index = 0
		quality_tiers_holder.get_child(displayed_quality_tier_index).show()

func add_new_quality_tier(item):
	var array_position = 0
	for i in range(item_qualities.size()):
		var item_quality = item_qualities[i]
		if item_quality.quality_tier_resource.tier > item.quality_tier_resource.tier:
			array_position = i
			break
	displayed_quality_tier_index = array_position
	item_qualities.insert(array_position, item)
	
	create_quality_tier_display(item)

func stack_same_quality_tier(item):
	for item_quality in item_qualities:
		if item_quality.quality_tier_resource.tier == item.quality_tier_resource.tier:
			var new_quality = blend_qualities(item_quality, item)
			item_quality.quantity_added(item.current_stack_size)
			item_quality.quality = new_quality
			break

func blend_qualities(item_1, item_2):
	return (item_1.current_stack_size * item_1.quality + item_2.current_stack_size * item_2.quality) / (item_1.current_stack_size + item_2.current_stack_size)

func has_quality_tier(quality_tier):
	var item_found = false
	for item_quality in item_qualities:
		if item_quality.quality_tier_resource.tier == quality_tier:
			item_found = true
	return item_found

func select_different_quality(direction):
	for quality_tier in quality_tiers_holder.get_children():
		quality_tier.hide()
	displayed_quality_tier_index = clamp(displayed_quality_tier_index + direction, 0, quality_tiers_holder.get_child_count() - 1)
	quality_tiers_holder.get_child(displayed_quality_tier_index).show()
	emit_signal("item_focus_entered", self, item_qualities[displayed_quality_tier_index])

func _on_focus_entered():
	emit_signal("item_focus_entered", self, item_qualities[displayed_quality_tier_index])

func _on_focus_exited():
	pass
