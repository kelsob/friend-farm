extends Sprite

onready var anim = $AnimationPlayer

signal fade_complete()

func appear():
	anim.play('Appear')
	yield(anim, "animation_finished")
	anim.play("Idle")
	emit_signal("fade_complete")

func disappear():
	anim.play('Disappear')
	yield(anim, "animation_finished")
	anim.play("Idle")
	emit_signal("fade_complete")

func wag_tail():
	anim.play("Tailwag")
	yield(anim, "animation_finished")
	anim.play("Idle")
