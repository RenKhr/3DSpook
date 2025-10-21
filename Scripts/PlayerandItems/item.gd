class_name Item
extends Node3D
@export_group("Properties")
@export var item_name := ""
@export var color: Color
@export var mesh: MeshInstance3D

var original_position: Vector3
var player


signal press
signal activate

func _ready():
	original_position = position
	player = get_tree().get_nodes_in_group("player")[0]
	if self.has_node("Mesh"):
		$Mesh.material_override.albedo_color = color
		$Text.text = item_name
		$TextShadow.text = item_name

#Pickup item if holding nothing at all ( nothing at all~ )
func pickupItem():
	#print("Picked up: ", iname)
	player.inventory.add_item(self)

func use_item(collider):
	pass

func _on_press():
	pickupItem()
