extends Control

var item

var quality_resource

onready var name_label = $ItemNameLabel
onready var count_label = $ItemCountLabel

func intialize(item_init):
	item = item_init
	quality_resource = item.quality_tier_resource
	if item.quality_tier_resource.tier == 0:
		name_label.bbcode_text = item.name
	else:
		set_text(item)
	count_label.text = String("x" + String(item.current_stack_size))

func set_text(item):
	var item_quality = item.quality_tier_resource.RTEffect_open_tertiary + item.quality_tier_resource.RTEffect_open_secondary + item.quality_tier_resource.RTEffect_open_primary + item.quality_tier_resource.name + item.quality_tier_resource.RTEffect_close_primary + item.quality_tier_resource.RTEffect_close_secondary + item.quality_tier_resource.RTEffect_close_tertiary
	var item_name = item.name
	
	var new_text : String = item_quality + " " + item_name
	var left_aligned_text = new_text
	
	name_label.bbcode_text = left_aligned_text

func _on_item_quantity_changed(item, new_quantity):
	count_label.text = String("x" + String(new_quantity))

func  _on_item_quantity_depleted(item):
	get_parent().get_parent().tier_depleted(self)
