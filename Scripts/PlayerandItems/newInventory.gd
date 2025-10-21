extends Node3D

var item_list = {}
var held_item
var index := 0

func _ready():
	item_list[0] = get_child(0)
	held_item = item_list[0]
	equip_to_hand(held_item, held_item)

# Pickup an item
func add_item(item: Item):
	item.reparent(self, false)
	item_list[get_child_count()-1] = item
	print(item_list)

func get_current_item():
	return held_item

# Mousewheel changes held item
func change_held_item(input):
	var previous_held_item = item_list[index]
	if input == MOUSE_BUTTON_WHEEL_UP:
		if index+1 >= item_list.size():
			index = 0
		else:
			index+=1
	
	if input == MOUSE_BUTTON_WHEEL_DOWN:
		if index-1 < 0:
			index = item_list.size()-1
		else:
			index-=1
	held_item = item_list[index]
	equip_to_hand(held_item, previous_held_item)

func equip_to_hand(item, previous_held_item):
	item.reparent(%Hand, false)
	previous_held_item.reparent(%inventory, false)
	item.position = %Hand.position
