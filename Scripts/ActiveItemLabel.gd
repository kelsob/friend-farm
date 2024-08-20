extends RichTextLabel

var fade_delay = 5.0
var fade_duration : float = 100.0

onready var tween = $Tween
onready var timer = $Timer
onready var anim = $AnimationPlayer

var active : bool = true

func _ready():
	timer.wait_time = fade_delay

func set_text(item):
	var item_quality = item.quality_tier_resource.RTEffect_open_tertiary + item.quality_tier_resource.RTEffect_open_secondary + item.quality_tier_resource.RTEffect_open_primary + item.quality_tier_resource.name + item.quality_tier_resource.RTEffect_close_primary + item.quality_tier_resource.RTEffect_close_secondary + item.quality_tier_resource.RTEffect_close_tertiary
	var item_name = item.name
	
	var new_text : String = item_quality +  " " + item_name
	
	if !active: return

	var right_aligned_text = '[right]' + new_text + '[/right]'

	if !visible:
		pass
	elif right_aligned_text == bbcode_text:
		return
		
	visible = true
	if anim.is_playing():
		anim.stop(true)
	
	modulate = Color(1.0,1.0,1.0,1.0)
	
	if tween.is_active():
		tween.stop_all()
	
	percent_visible = 0
	bbcode_text = right_aligned_text
	
	tween.interpolate_property(self,
		'percent_visible',
		0,
		1,
		0.125
	)
	tween.start()

func _on_tween_completed(object, key):
	timer.start()

func _on_Timer_timeout():
	anim.play("FadeOut")

func clear_text():
	if anim.is_playing():
		anim.stop(true)
	if tween.is_active():
		tween.stop_all()
	visible = false
