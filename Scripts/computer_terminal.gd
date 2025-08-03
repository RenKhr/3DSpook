extends StaticBody3D

@export_file("*tscn") var scene ## Insert desired computer scene here.

@onready var screen = $Monitor/MonitorViewport
@onready var default_scene = load("res://Scenes/Objects/Computer Screens/monitor_control.tscn")

var s

# Called when the node enters the scene tree for the first time.
func _ready():
	if !scene == null:
		var loaded_scene = load(scene)
		s = loaded_scene.instantiate()
		screen.add_child(s)
	else:
		s = default_scene.instantiate()
		screen.add_child(s)
	$anim.play("light_flicker")
