extends ToolItem
class_name HammerTool

var build_hotbar_scene = preload('res://Scenes/UI/HotbarBuild.tscn')
var build_hotbar

export (String) var player_use_animation = "SwingHold"
export (String) var player_use_animation_miss = "Swing"

func used(player, current_scene):
	Input.action_release("ui_accept")
	
	if player.player_state != player.PlayerState.BUILDING:

		build_hotbar = build_hotbar_scene.instance()

		current_scene.get_node("../../UI").add_child(build_hotbar)
		current_scene.get_node("../../UI").disable_hotbar()
		build_hotbar.initialize()
		build_hotbar.appear()
		
		player.building()
		return true

func get_use_animations():
	player_use_animations = [player_use_animation, player_use_animation_miss]
	return player_use_animations
