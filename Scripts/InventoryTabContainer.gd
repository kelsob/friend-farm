extends TabContainer

onready var inventory = get_parent().inventory

var inventory_tab_display_scene = preload("res://Scenes/UI/InventoryTabDisplay.tscn")
var tab_index = 0


func _on_inventory_tab_created(inventory_tab):
	var new_tab = inventory_tab_display_scene.instance()
	new_tab.initialize(inventory_tab)
	add_child(new_tab)
	set_tab_title(new_tab.get_index(), "")
	set_tab_icon(new_tab.get_index(), inventory_tab.icon)
	new_tab.connect("item_focus_entered", get_parent(), "_on_item_focus_entered")

func inventory_opened():
	if get_child(current_tab).item_container.get_child_count() == 0:
		var new_tab = find_non_empty_tab()
		if new_tab != null:
			get_child(current_tab).tab_closed()
			current_tab = new_tab
	tab_index = current_tab
	get_child(current_tab).tab_opened()
	get_child(current_tab).set_process(true)

func inventory_closed():
	
	get_child(current_tab).tab_closed()

func find_non_empty_tab():
	var tab = null
	for i in range(get_child_count()):
		if get_child(i).item_container.get_child_count() != 0:
			tab = i
	return tab

func _on_self_tab_changed(tab):

	get_child(tab_index).set_process(false)
	tab_index = tab
	current_tab = tab
	get_child(current_tab).tab_opened()
	get_child(current_tab).set_process(true)
