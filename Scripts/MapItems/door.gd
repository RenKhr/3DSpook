extends Node3D

@onready var animation = $AnimationPlayer

@export var open: bool = false
@export var locked = false
var cardReaders = []

# Get the keycard readers attached to this door and append them to a list for ease of access
func _ready():
	animation.set_assigned_animation("door_open")
	if open == false:
		animation.advance(0.0)
	for child in self.get_children():
		if get_tree().get_nodes_in_group("reader").has(child):
			cardReaders.append(child)

# Open or Close
func interact():
	if !open and !locked:
		openDoor()
		print("Opening doors")
	elif open:
		closeDoor()
		print("Closing doors")

# Open the door
func openDoor():
	open = true
	$door_open.play()
	animation.play("door_open")

# Close the door
func closeDoor():
	open = false
	$door_close.play()
	animation.play_backwards("door_open")

# Automatic closing of the door after x seconds
func _on_close_timer_timeout():
	closeDoor()

# Check if the animation is finished for color changing and door closing timer
func _on_animation_player_animation_finished(anim_name):
	if anim_name == "door_open" and open == true:
		$closeTimer.start()
		for child in cardReaders:
			child.openLight()
	else:
		$closeTimer.stop()
		for child in cardReaders:
			child.lockDoors()

func _on_player_detected(body:Node3D):
	if body.name == "Player":
		if !locked:
			if $closeTimer.wait_time < 0 or !open:
				openDoor()
	if body.name == "enemy":
		if $closeTimer.wait_time < 0 or !open:
				openDoor()
		#else:
			#$closeTimer.paused = true


func _on_player_detect_body_exited(body: Node3D):
	if body.name == "enemy":
		$closeTimer.paused = false