extends Node


func handle_event(event_data, dialog_node):
	""" 
		If this event should wait for dialog advance to occur, uncomment the WAITING line
		If this event should wait for the user to pick a choice, uncomment the WAITINT_INPUT line
		While other states exist, they generally are not neccesary, but include IDLE, TYPING, and ANIMATING
	"""
	#dialog_node.set_state(state.WAITING)
	
	dialog_node.numerical_input_functionality()
	
	# once you want to continue with the next event
#	dialog_node._load_next_event()
#	dialog_node.set_state(dialog_node.state.READY)
