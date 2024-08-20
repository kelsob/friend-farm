extends Node2D

onready var label = $Label
onready var tween = $Tween
onready var anim = $AnimationPlayer

func initialize(item):
	set_text(item)
	visible = true
	
	tween.interpolate_property(self, "position",
	position,
	position + Vector2(0,-32),
	3.0,
	Tween.TRANS_LINEAR,
	Tween.EASE_OUT)

	tween.start()
	yield(get_tree().create_timer(2.0), "timeout")
	anim.play("disappear")

func set_text(item):
	if item.quality_tier_resource.tier == 0:
		label.bbcode_text = "[center]+ " + item.name + "[/center]"
	else:

		var item_quality = item.quality_tier_resource.RTEffect_open_tertiary + item.quality_tier_resource.RTEffect_open_secondary + item.quality_tier_resource.RTEffect_open_primary + item.quality_tier_resource.name + item.quality_tier_resource.RTEffect_close_primary + item.quality_tier_resource.RTEffect_close_secondary + item.quality_tier_resource.RTEffect_close_tertiary
		var item_name = item.name
	
		var new_text : String = "[center]+ " + item_quality + " " + item_name + "[/center]"
		var left_aligned_text = new_text
	
		label.bbcode_text = left_aligned_text

func initialize_string(text):
	label.bbcode_text = text
	
	tween.interpolate_property(self, "position",
	position,
	position + Vector2(0,-32),
	3.0,
	Tween.TRANS_LINEAR,
	Tween.EASE_OUT)

	tween.start()
	anim.play("disappear")

func _on_tween_completed(object, key):
	queue_free()
