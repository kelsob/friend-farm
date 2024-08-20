extends Node


var conversation_1 : Array = [
	[0,
	"Whew, we're finally out of that tunnel!",
	"We're almost there, CHARNAME! Want to chat on the way?"
	], # TEXT DIALOG, ARGS: TYPE, DIALOG
	[1, true, 8], #YES NO DIALOG, ARGS: TYPE, REWRITE, TIMER_DURATION
	[0, # TEXT DIALOG, WITH CHOICE DEPENDENT DIALOGS
	["Strong silent type huh? That’s okay, my Dad was like that.",
	"Well I'll try to drive a little bit faster then.",
	0, # end condition
	"END_DIALOG"], # dialog end signal
	["Bark! I mean, wonderful!"],
	["Strong silent type huh? That’s okay, my Dad was like that.",
	"Don't worry, I can talk for both of us!",
	]
	],
	[0,
	"I'm just so excited to get started. You're going to have everything you'll ever need here!",
	"But first... I've been wondering...",
	"What do you like most? BALLs or BONEs?"
	],
	[2, true, 8, ["BALLs", "BONEs"]],
	[0,
	["Ah! A fellow BALLer! I just hope my BONE doesn't feel neglected...",
	"Here, as a token of our new friendship, have this!",
	"You have received, BAXTER's BALL!"],
	["Ah! A BONEr! I think I'm more of a BALLman myself, but I respect your choice.",
	"Here, as a token of our new friendship, have this!",
	"You have received, BAXTER's BONE!"],
	["Haha just can't pick huh? I get it, they're both pretty amazing.",
	"Here, as a token of our new friendship, have these!",
	"You have received, BAXTER's BALL!",
	"You have received, BAXTER's BONE!"]
	],
	[0,
	"We're almost at your new HOME!",
	1, # end condition
	"END_DIALOG" # dialog end signal
	]
]
var conversation_2 : Array = [
	[0,
	"Here we are! Welcome to your own little plot of paradise.",
	"It may not look like much yet, but given a little time and love...",
	"...and before you know it, all of your troubles will fade away.",
	"Anyways that sure was a long trip, I'm sure you're just aching to get settled in.",
	"Feel free to look around, maybe clean up the place a bit.",
	"Whenever you're done for the day make sure to go to your BED to get some rest.",
	"Come meet me at my farm in the morning and we'll get started in earnest.",
	"Alright have a wonderful night CHARNAME and enjoy your new life!",
	"Now... fetch!",
	0,
	"END_DIALOG"
	]
]

var animation_stage = 0
var current_animation_parent = "OpeningScene"
var conversation_properties = []


onready var conversation_manager = $ConversationManager
onready var anim = $ScenePlayer

signal current_animation_complete()

func initiate_scene():
	
	conversation_manager.set_time_sensitivity(true)
	conversation_manager.load_conversation(conversation_1)
	anim.play("OpeningScene0")
	conversation_manager.initiate_conversation()
	
	conversation_properties.append(yield(conversation_manager, "conversation_completed"))
	car_conversation_over()

func play_next_stage():
	animation_stage += 1
	var current_animation_stage = current_animation_parent + String(animation_stage)
	
	if anim.has_animation(current_animation_stage):
		anim.play(current_animation_stage)
	else:
		emit_signal("current_animation_complete")

func car_conversation_over():
	if conversation_properties[0][0] == 0:
		# Speed up carride condition.
		
		var truck = get_node("../../YSort/Truck")
		truck.new_speed(20.0)
		
	elif conversation_properties[0][0] == 1:
		# Conversation is finished normally condition.
		var truck = get_node("../../YSort/Truck")
		truck.new_speed(2.0)
	
	conversation_manager.reset()

func carride_completed():
	conversation_manager.set_time_sensitivity(false)
	conversation_manager.load_conversation(conversation_2)
	conversation_manager.initiate_conversation()
	conversation_properties.append(yield(conversation_manager, "conversation_completed"))
	anim.play("OpeningScene6")
