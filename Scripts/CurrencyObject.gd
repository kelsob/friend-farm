extends InteractableObject

export (int) var currency_amount = 10

tool

const dust_effect_scene = preload("res://Scenes/Effects/LandingDustEffect.tscn")
const item_pickup_label_scene = preload("res://Scenes/UI/ItemPickupLabel.tscn")

export (bool) var picking_up = false

export (bool) var hidden = false
export (bool) var generic_textured = false
export (int) var quantity_override = 1

onready var area_collision = $CollisionShape2DObstruction

signal collected(item)

func _ready():
	
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
	
	Input.action_release("ui_accept")
	
	player.act("Kneel")
	var first_time_pickup = false
	tween_sprite_positions(null, player, first_time_pickup)
	yield(get_tree().create_timer(0.8), "timeout")

	var item_pickup_label = item_pickup_label_scene.instance()
	player.add_child(item_pickup_label)

	item_pickup_label.position = Vector2(4,4)
	item_pickup_label.initialize_string("[center] + " + String(currency_amount) + " pals!" + "[/center]")
	player.stats.currency_changed(currency_amount)
	player._on_action_complete()
	self_remove()

func tween_sprite_positions(move_directions, player, first_time_pickup):	
	tween.interpolate_property(sprite,
	"position",
	sprite.position,
	sprite.position + player.get_global_position() - get_global_position() + Vector2(8,8) - player.grid_offset,
	1.0,
	Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	tween.start()
	
	tween.interpolate_property(sprite,
	"scale",
	sprite.scale,
	Vector2(0.25,0.25),
	1.0,
	Tween.TRANS_LINEAR,
	Tween.EASE_IN_OUT)
	tween.start()
