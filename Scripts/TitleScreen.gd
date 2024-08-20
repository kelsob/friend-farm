extends Control


onready var fade = $FadeIn
onready var buttons = $Menu

func _ready():
	$Menu/NGButton.grab_focus()
	SceneLoader.connect("on_scene_loaded", self, "do_scene_loaded")
	SceneLoader.connect("on_progress", self, "scene_load_progressed")


# Menu Button Functionality.
func _on_NGButton_pressed():
	SceneLoader.load_scene("res://Scenes/MainScenes/SceneManager.tscn", { hii = "cool" })
#	SceneLoader.load_scene("res://Scenes/MainScenes/WorldScenes/PlayerFarm.tscn", { hii = "cool" })
	for button in buttons.get_children():
		button.disabled = true
	fade.fade_in()
	yield(fade, 'fade_complete')

#	yield(get_tree().create_timer(1.0), 'timeout')
#
#	var introduction_scene : String = 'res://Scenes/NarrativeScenes/IntroductionScene.tscn'
#	get_tree().change_scene("res://Scenes/MainScenes/SceneManager.tscn")

func _on_ContinueButton_pressed():
	pass # Replace with function body.

func _on_OptionsButton_pressed():
	pass # Replace with function body.

func _on_QuitButton_pressed():
	pass # Replace with function body.

func do_scene_loaded(scene):
	# You can hook the instance name to run your specific per scene logic
	# Example: parse the name for a substring such as "ITEM_" and then
	# run your item specific logic
	
	get_tree().change_scene_to(scene.instance)
#	add_child(scene.instance.instance())
	print(scene)
	print(scene)
#	get_tree().change_scene(scene)
#	print(props.hii)

func scene_load_progressed(scene_path, scene_total_load_stages, scene_load_stage):
	#	print(float(scene_load_stage)/float(scene_total_load_stages))
	pass
