extends InteractableObject

export (Resource) var product_item : Resource = null
export (bool) var item_sellable = true
export (bool) var item_held = false
export (int) var quantity_available = 1
export (int) var daily_stock = 1

export (String) var shop_owner = ""

var appearing = false

onready var product_sprite = $ItemSprite

func _ready():
	if product_item != null:
		item_assigned(product_item)

func item_assigned(new_item):
	item_held = true
	product_item = new_item
	product_sprite.texture = new_item.texture

func item_sold(quantity_sold):
	product_sprite.visible = false
	player.stats.currency_changed(-1 * (product_item.pal_value_actual) * quantity_sold)
	get_tree().current_scene.add_item(product_item.duplicate(), product_sprite.get_global_position() + product_sprite.offset)
	
	quantity_available -= quantity_sold
	if quantity_available == 0:
		quantity_depleted()
	else:
		yield(get_tree().create_timer(3.0), "timeout")
		reappear_item_sprite()

func reappear_item_sprite():
	appearing = true
	product_sprite.scale = Vector2(0,0)
	tween.interpolate_property(product_sprite, "scale", Vector2(0,0), Vector2(1,1), 1.5, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	tween.start()
	product_sprite.visible = true
	yield(tween, "tween_completed")
	appearing = false

func restock():
	quantity_available = daily_stock
	reappear_item_sprite()

func quantity_depleted():
	product_item = null

func player_interacted(player_init):
	player = player_init
	if quantity_available != 0 and item_sellable and !appearing:
		start_dialog()

func start_dialog():
	var dialog = Dialogic.start(shop_owner + "ItemPurchase")
	dialog.pause_mode = PAUSE_MODE_PROCESS
	get_tree().current_scene.find_node("UI").add_child(dialog)
	
	Dialogic.set_variable("PurchaseItemName", product_item.name)
	Dialogic.set_variable("PurchaseItemCost", product_item.pal_value_actual)
	Dialogic.set_variable("PurchaseItemQuantityAvailable", quantity_available)
	
	dialog.connect("timeline_end", self, "end_dialog")
	dialog.connect("dialogic_signal", self, "dialogic_signal")
	
	get_tree().paused = true

func end_dialog(timeline_name):
	get_tree().paused = false

func dialogic_signal(argument):
	if argument == "item_purchased":
		item_sold(int(Dialogic.get_variable("ItemQuantityPurchased")))
