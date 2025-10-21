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
	player = get_tree().get_nodes_in_group("player")[0]
	if self.has_node("Mesh"):
		$Mesh.material_override.albedo_color = color
		$Text.text = item_name
		$TextShadow.text = item_name

func use_item(target):
	if get_tree().get_nodes_in_group("reader").has(target):
		target.readkeycard(self)

func _on_press():
	player.inventory.add_item(self)
