extends TextureButton

onready var icon = $Icon
onready var anim = $AnimationPlayer
onready var tween = $Tween
onready var sprite = $Sprite


export (int) var character_id = 0

signal fade_complete()
signal character_chosen(character_id)

func show_icon():
	icon.show()

func hide_icon():
	icon.hide()

func assign_sprite(character_id):
	sprite.texture = load("res://Assets/ProfileAssets/Rival-" + String(character_id) + ".png")

func appear():
	anim.play("Appear")
	yield(anim, "animation_finished")
	disabled = false
	emit_signal("fade_complete")

func disappear():
	disabled = true
	anim.play("Disappear")
	yield(anim, "animation_finished")
	emit_signal("fade_complete")

func center():
	hide_icon()
	var move = Vector2(16 + 32 * (-1 * character_id), 0)
	if character_id == 1:
		move = Vector2(-16,0)
	else:
		move = Vector2(16,0)
	tween.interpolate_property(self, 'rect_position', rect_position, rect_position + move, 1.0, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	tween.start()


func _self_pressed():
	disabled = true
