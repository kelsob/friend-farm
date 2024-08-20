extends InteractableObject

var scene_manager
var sleep_count = 0

var sleep_enabled = true
var sleep_dialog = ["Would you like to sleep?"]

var choice_box_scene = load("res://Scenes/UI/YesNoChoiceBox.tscn")
var choice_box

func _ready():
	scene_manager = get_tree().current_scene

func player_interacted(player):
	if !sleep_enabled:
		return
	
	player.set_physics_process(false)

	dialog_box = dialog_box_scene.instance()
	get_tree().current_scene.add_child(dialog_box)
	dialog_box.dialog = sleep_dialog
	yield(get_tree().create_timer(0.1), "timeout")
	dialog_box.show()
	dialog_box.activate()
	dialog_box.load_dialog()
	yield(dialog_box, "final_dialog_completed")
	dialog_box.deactivate()


	choice_box = choice_box_scene.instance()
	get_tree().current_scene.add_child(choice_box)
	choice_box.show()
	choice_box.activate()
	var choice = yield(choice_box, "answer_chosen")

	if choice:
		sleep()
	else:
		player.set_physics_process(true)
	
	dialog_box.queue_free()
	
	total_interactions += 1

func sleep():
	sleep_count += 1
	scene_manager.player_slept()
