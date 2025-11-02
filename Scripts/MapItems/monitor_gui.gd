extends Control

var times_pressed: int = 0
var enemy
var camera_feed

# Called when the node enters the scene tree for the first time.
func _ready():
	enemy = get_tree().get_nodes_in_group("enemy")[0]
	camera_feed = $TextureRect


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	camera_feed.texture = enemy.get_child(-1).get_texture()


func _on_button_pressed():
	times_pressed += 1
	if times_pressed == 69:
		$Button.text = str("It was pressed ", "nice!", " times.")
	else:
		$Button.text = str("It was pressed ", times_pressed, " times.")
