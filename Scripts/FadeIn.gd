extends ColorRect

onready var anim = $AnimationPlayer

signal fade_complete()

func fade_in():
	anim.play('FadeIn')
	yield(anim, 'animation_finished')
	emit_signal('fade_complete')

func fade_out():
	anim.play('FadeOut')
	yield(anim, 'animation_finished')
	emit_signal('fade_complete')

func play_animation(animation):
	
	anim.play(animation)
	yield(anim, 'animation_finished')
	emit_signal("fade_complete")

func sleep_fade_in():
	anim.play("SleepFadeIn")
	yield(anim, "animation_finished")
	emit_signal("fade_complete")
	
func sleep_fade_out():
	anim.play("SleepFadeOut")
	yield(anim, "animation_finished")
	emit_signal("fade_complete")
