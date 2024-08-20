extends InteractableObject

const dust_effect_scene = preload("res://Scenes/Effects/LandingDustEffect.tscn")
const item_pickup_label_scene = preload("res://Scenes/UI/ItemPickupLabel.tscn")

export (bool) var picking_up = false

export (Resource) var item
export (bool) var hidden = false
export (bool) var generic_textured = false
export (int) var quantity_override = 1
export (int) var quality_tier_override = 0

onready var area_collision = $CollisionShape2DObstruction

signal collected(item)

func _ready():

	if !generic_textured:
		sprite.texture = item.texture
	
	if hidden:
		area_collision.disabled = true
		visible = false
	else:
		area_collision.disabled = false
		visible = true

func reveal():
	if !hidden:
		return
	else:
		area_collision.disabled = false
		visible = true

func conceal():
	if !hidden:
		area_collision.disabled = true
		visible = false
	else:
		return

func player_interacted(player):
	picked_up(player)

func picked_up(player):
	if picking_up:
		return
	picking_up = true

	var item_mod = item.duplicate()
	
	if quantity_override != 1:
		item_mod.current_stack_size = quantity_override
	
	quality_tier_override = clamp(quality_tier_override, 0, 12)
	item_mod.override_quality(quality_tier_override)
	
	Input.action_release("ui_accept")
	yield(get_tree(),'idle_frame')
	
	var first_time_pickup
	if item.player_encountered:
		get_tree().current_scene.add_item(item_mod, get_global_position() + Vector2(8,8))
		first_time_pickup = false
#		tween_sprite_positions(null, player, first_time_pickup)
#		yield(get_tree().create_timer(0.8), "timeout")
#		var item_pickup_label = item_pickup_label_scene.instance()
#		player.add_child(item_pickup_label)
#		item_pickup_label.position = Vector2(8,8)
#		item_pickup_label.initialize(item_mod)
		
	else:
		player.act("Pickup")
		
		get_tree().current_scene.inventory.add_item(item_mod)
		
		item.player_encountered = true
		first_time_pickup = true
	
		var move_directions = player.item_pickup_locations[player.facing_direction]
		tween_sprite_positions(move_directions, player, first_time_pickup)
		
		var dialog_box_scene = load("res://Scenes/UI/DialogBox.tscn")
		var dialog_box = dialog_box_scene.instance()
		add_child(dialog_box)
		dialog_box.show()
		
		dialog_box.initialize(item_mod)
		
		dialog_box.load_dialog()
		dialog_box.activate()
		yield(dialog_box, "final_dialog_completed")
		dialog_box.reactivate()
		yield(dialog_box, "dialog_completed")
		dialog_box.queue_free()

	var dust_effect = dust_effect_scene.instance()
	dust_effect.position = position + Vector2(0, -2)
	get_tree().current_scene.add_child(dust_effect)
	player._on_action_complete()
	
	self_remove()

func tween_sprite_positions(move_directions, player, first_time_pickup):
	
	
	if first_time_pickup:
		
		for i in move_directions.size():

			var new_direction = player.get_global_position() + move_directions[i] - get_global_position() - player.grid_offset
		
			var tween_duration = 0.0
			
			var tween_property
			if move_directions.size() == 1:
				tween_duration = 0.8
				tween_property = Tween.EASE_IN_OUT
			elif move_directions.size() == 2 && i == 0:
				tween_duration = 0.3
				tween_property = Tween.EASE_OUT
			elif move_directions.size() == 2 && i == 1:
				tween_duration = 0.5
				tween_property = Tween.EASE_IN
			
			tween.interpolate_property(sprite,
			"position",
			sprite.position,
			Vector2(0,0) + new_direction,
			tween_duration,
			Tween.TRANS_CUBIC,
			tween_property)
			
			tween.start()
			yield(tween, "tween_completed")
	else:
		
		tween.interpolate_property(sprite,
		"position",
		sprite.position,
		sprite.position + player.get_global_position() - get_global_position() + Vector2(8,8),
		1.0,
		Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		tween.start()
		
		tween.interpolate_property(sprite,
		"scale",
		sprite.scale,
		Vector2(0.5,0.5),
		1.0,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT)
		tween.start()
