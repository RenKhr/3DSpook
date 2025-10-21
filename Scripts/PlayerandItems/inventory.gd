extends Node3D

var item_list = {}
var held_item
var index
var last_equipped
var hand_item

# Fill the inventory with null slots, set index to zero and held_item as the first null slot in inventory
func _ready():
	%Hand.get_child(0).visible = false
	for child in get_children():
		if child.has_signal("press"):
			item_list.append(child)
	index = 0
	if !item_list.is_empty():
		held_item = item_list[index]

# Pickup an item if holding null
func obtainItem(item):
	for child in item_list:
		if child.iname == item.iname and child.activated == false:
			child.activate.emit()

func get_current_item():
	if %Hand.get_children().size() == 2:
		return %Hand.get_child(1)

# Mousewheel changes held item
func change_held_item(input):
	var loops = 0
	var previous_held_item = item_list[index]
	if input == MOUSE_BUTTON_WHEEL_UP:
		if index <= item_list.size()-1:
			index += 1
		if index == item_list.size():
			index = 0
	#spaghetti code to skip unactivated items
		if !item_list[index].activated:
			while !item_list[index].activated and loops < item_list.size():
				if index <= item_list.size()-1:
					index += 1
				if index == item_list.size():
					index = 0
				loops += 1
	
	if input == MOUSE_BUTTON_WHEEL_DOWN:
		if index >= 0:
			index -= 1
		if index < 0:
			index = item_list.size()-1
	#spaghetti code to skip unactivated items
		if !item_list[index].activated:
			while !item_list[index].activated and loops < item_list.size():
				if index >= 0:
					index -= 1
				if index < 0:
					index = item_list.size()-1
				loops += 1

	held_item = item_list[index]
	
	if previous_held_item != null:
		previous_held_item.position = previous_held_item.original_position
		previous_held_item.rotation_degrees = Vector3(-45, 0, 0)
		if previous_held_item.has_node("ammo"):
			previous_held_item.rotation_degrees = Vector3( 0, -90, 70)
		previous_held_item.scale = Vector3(1, 1, 1)
	if held_item.activated == true:
		equip_to_hand(previous_held_item)
	

func equip_to_hand(previous_item):
	unequip(previous_item, hand_item)
	hand_item = load(held_item.scene_file_path).instantiate()
	held_item.visible = false
	hand_item.set("activated", held_item.get("activated"))
	hand_item.set("color", held_item.get("color"))
	hand_item.set("iname", held_item.get("iname"))
	hand_item.position = %Hand.position
	hand_item.rotation_degrees = Vector3(0, -90, 0)
	hand_item.scale = Vector3(2, 2, 2)
	%Hand.add_child(hand_item)
	

func unequip(item, h_item):
	if item.activated == true:
		item.visible = true
	if h_item != null:
		h_item.queue_free()
