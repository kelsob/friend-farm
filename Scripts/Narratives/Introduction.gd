extends Control


onready var fade = $FadeIn
onready var fade_low = $FadeInLow
onready var dialog_box = $DialogBox
onready var character_select_button_0 = $CharacterSelectButton
onready var character_select_button_1 = $CharacterSelectButton1
onready var keyboard = $Keyboard
onready var baxter = $BaxterGoodboy
onready var rival = $Rival
onready var anim = $AnimationPlayer

var character_id = 0
var character_name = ''
var rival_name = ''

var selected_character_sprite

var dialog_1 = [
	"Hello young farmer!\nIt’s a pleasure to meet you.",
	'My name is BAXTER GOODEBOY.',
	"Some people call me the GUIDE DOG,\nbut I’m not sure why...",
	"BARK!\nWelcome to your very own,\nFARM ORIENTATION DAY!",
	"This land is full of amazing animals that people make FRIENDS with!",
	"Aren’t FRIENDS wonderful\nto have in your life?",
	"I’m going to show you how to make FRIENDS and take care of them!",
	"BARK!\nLook at me go on, let’s talk about you!",
	"I can’t see so well anymore...\nWhat do you look like?"
]
var dialog_2 = ["Now...\ntell me what was your name?"
]
var dialog_3 = ["<CharName>, ah...\nWhat a good name for a human!",
	"Speaking of humans...",
	"I just came from helping my grandkid set up their first farm!"
]
var dialog_4 = ["...Erm, what was their name again?"
]
var dialog_5 = ["Of course, <RivalName>!\nA very forgettable name.",
	"They are going to be your rival from now on!",
	"Between you and me though,\nI’m rooting for you.\nBARK!"
]
var dialog_6 = ["Now, <CharName>!",
	"Your adventure is just beginning!",
]
var dialog_7 = ["Let’s get started on your very own FRIEND FARM!"
]

func _ready():
	initiate_scene()

func initiate_scene():
	dialog_box.dialog = dialog_1
	fade.fade_out()
	yield(fade, 'fade_complete')
	yield(get_tree().create_timer(0.2), 'timeout')
	
	dialog_box.show()
	dialog_box.activate()
	yield(get_tree().create_timer(0.2), 'timeout')
	dialog_box.load_dialog()
	
	yield(dialog_box, 'final_dialog_initiated')
	baxter.disappear()
	yield(baxter, 'fade_complete')
	
	character_select_button_0.appear()
	character_select_button_1.appear()
	
	yield(character_select_button_1, 'fade_complete')
	character_select_button_1.grab_focus()

func _on_CharacterSelectButton_pressed():
	character_select_button_0.focus_mode = Control.FOCUS_NONE
	character_select_button_1.focus_mode = Control.FOCUS_NONE
	character_select_button_1.disappear()
	yield(get_tree().create_timer(0.2), 'timeout')
	character_select_button_0.center()
	selected_character_sprite = character_select_button_0
	
	character_id = 0
	
	initiate_dialog_2()

func _on_CharacterSelectButton1_pressed():
	character_select_button_0.focus_mode = Control.FOCUS_NONE
	character_select_button_1.focus_mode = Control.FOCUS_NONE
	character_select_button_0.disappear()
	yield(get_tree().create_timer(0.2), 'timeout')

	character_select_button_1.center()
	selected_character_sprite = character_select_button_1

	character_id = 1
	
	initiate_dialog_2()


func initiate_dialog_2():
	dialog_box.reset()
	dialog_box.dialog = dialog_2
	dialog_box.load_dialog()
	
	keyboard.assign_sprite(character_id)
	keyboard.appear()
	yield(keyboard, "fade_complete")
	keyboard.activate()
	character_name = yield(keyboard, "text_selected")
	keyboard.disappear()
	yield(keyboard, "fade_complete")
	keyboard.reset()
	
	if !dialog_box.finished:
		yield(dialog_box, "final_dialog_completed")
		dialog_box.reactivate()
		yield(dialog_box, "dialog_completed")
	
	dialog_box.reset()
	dialog_box.set_process(true)
	
	var dialog_chunk
	

	dialog_chunk = dialog_3[0].replace("<CharName>", character_name)
	dialog_3[0] = dialog_chunk
	dialog_box.dialog = dialog_3
	dialog_box.load_dialog()
	
	yield(dialog_box, 'final_dialog_initiated')
	rival.assign_sprite(character_id)
	selected_character_sprite.disappear()
	yield(selected_character_sprite, 'fade_complete')
	rival.appear()
	
	if dialog_box.finished:
		dialog_box.reset()
		dialog_box.dialog = dialog_4
		dialog_box.reactivate()
	else:
		yield(dialog_box, "final_dialog_completed")
		dialog_box.reactivate()
		yield(dialog_box, "dialog_completed")
		dialog_box.reset()
		dialog_box.dialog = dialog_4
		dialog_box.activate()
		dialog_box.load_dialog()
		
	
	keyboard.assign_sprite(character_id)
	keyboard.appear()
	yield(keyboard, "fade_complete")
	keyboard.activate()
	rival_name = yield(keyboard, "text_selected")
	keyboard.disappear()
	yield(keyboard, "fade_complete")
	keyboard.reset()

	dialog_box.reset()
	dialog_box.set_process(true)
	
	dialog_chunk = dialog_5[0].replace('<RivalName>', rival_name)
	dialog_5[0] = dialog_chunk
	dialog_box.dialog = dialog_5
	dialog_box.load_dialog()
	
	yield(dialog_box, "final_dialog_initiated")
	rival.disappear()
	yield(rival, "fade_complete")
	baxter.appear()
	yield(baxter, "fade_complete")
	
	dialog_chunk = dialog_6[0].replace("<CharName>", character_name)
	dialog_6[0] = dialog_chunk
	
	dialog_box.reset()
	dialog_box.dialog = dialog_6
	dialog_box.set_process(true)
	dialog_box.reactivate()

	yield(dialog_box, "final_dialog_initiated")
	baxter.disappear()
	yield(baxter, "fade_complete")
	selected_character_sprite.appear()
	yield(selected_character_sprite, "fade_complete")
	
	if dialog_box.finished:
		dialog_box.reset()
		dialog_box.dialog = dialog_7
		dialog_box.reactivate()
	else:
		yield(dialog_box, "final_dialog_completed")
		dialog_box.reset()
		dialog_box.dialog = dialog_7
		dialog_box.reactivate()
	
	yield(dialog_box, "final_dialog_completed")
	anim.play("SceneTransition" + String(character_id))
	yield(anim, "animation_finished")
	
	var main_scene : String = "res://Scenes/MainScenes/SceneManager.tscn"
	get_tree().change_scene(main_scene)

func _on_DialogBox_final_dialog_completed():
	dialog_box.set_process(false)
