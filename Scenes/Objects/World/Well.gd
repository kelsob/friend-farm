extends InteractableObject

var raised : bool = true
var filled : bool = false

func player_interacted(player):
	if raised and filled:
		take_water()

	elif raised:
		lower_bucket()

	else:
		raise_bucket()

func lower_bucket():
	if !anim.is_playing():
		anim.play("DescendEmpty")

func raise_bucket():
	if !anim.is_playing():
		anim.play("AscendFull")

func bucket_lowered():
	raised = false 
	filled = true

func bucket_raised():
	raised = true

func take_water():
	filled = false
	sprite.frame = 0
