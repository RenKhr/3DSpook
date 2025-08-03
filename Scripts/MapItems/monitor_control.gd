extends Node3D

var is_mouse_inside

var last_event_pos2D

var last_event_time

@onready var node_viewport = $MonitorViewport
@onready var node_quad = $Quad
@onready var node_area = $Quad/Area3D

func _ready():
	node_area.mouse_entered.connect(self._mouse_entered_area)
	node_area.mouse_exited.connect(self._mouse_exited_area)
	node_area.input_event.connect(self._mouse_input_event)

func _mouse_entered_area():
	is_mouse_inside = true

func _mouse_exited_area():
	is_mouse_inside = false

func _unhandled_key_input(event):
	node_viewport.push_input(event)

func _mouse_input_event(_camera: Camera3D, event: InputEvent, event_position: Vector3, _normal: Vector3, _shape_idx: int):
	var quad_mesh_size = node_quad.mesh.size

	var event_pos3D = event_position

	var now: float = Time.get_ticks_msec() / 1000.0

	event_pos3D = node_quad.global_transform.affine_inverse() * event_pos3D

	var event_pos2D: Vector2 = Vector2()

	if is_mouse_inside:
		event_pos2D = Vector2(event_pos3D.x, -event_pos3D.z)

		event_pos2D.x = event_pos2D.x / quad_mesh_size.x
		event_pos2D.y = event_pos2D.y / quad_mesh_size.y

		event_pos2D.x += 0.5
		event_pos2D.y += 0.4

		event_pos2D.x *= node_viewport.size.x
		event_pos2D.y *= node_viewport.size.y
		
		
	elif last_event_pos2D != null:
		event_pos2D = last_event_pos2D

	event.position = event_pos2D
	if event is InputEventMouse:
		event.global_position = event_pos2D

	if event is InputEventMouseMotion or event is InputEventScreenDrag:
		if last_event_pos2D == null:
			event.relative = Vector2(0,0)
		
		else:
			event.relative = event_pos2D - last_event_pos2D
			event.velocity = event.relative / (now - last_event_time)
		
	last_event_pos2D = event_pos2D

	last_event_time = now

	node_viewport.push_input(event)


func _on_press():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _on_area_3d_press() -> void:
	pass # Replace with function body.
