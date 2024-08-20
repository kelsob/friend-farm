extends Sprite

onready var anim = $AnimationPlayer

func jump_down():
	anim.play("JumpDown")

func jump_fast_down():
	anim.play("JumpFastDown")
