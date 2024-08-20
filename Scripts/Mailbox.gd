extends InteractableObject

enum STATE {OPEN_NEW, OPEN, CLOSED_NEW, CLOSED}
export (STATE) var state = STATE.CLOSED

var new_mail : bool = false

func new_mail():
	new_mail = true
	state = STATE.CLOSED_NEW
	sprite.frame = 1

func player_interacted(player):
	if state == STATE.CLOSED_NEW or state == STATE.CLOSED:
		opened()
	elif state == STATE.OPEN_NEW or state == STATE.OPEN:
		closed()

func opened():
	if new_mail:
		state = STATE.OPEN_NEW
		sprite.frame = 2
		new_mail = false
	else:
		state = STATE.OPEN
		sprite.frame = 1

func closed():
	state = STATE.CLOSED
	sprite.frame = 0
