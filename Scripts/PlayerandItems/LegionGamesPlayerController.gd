extends CharacterBody3D

const WALK_SPEED = 5.0
const SPRINT_SPEED = 7.5
const JUMP_VELOCITY = 4.5
const BOB_FREQ = 2.0
const BOB_AMP = 0.08
var speed = WALK_SPEED 
var t_bob = 0.0
var gravity = 9.8
var mouse_sens := 0.002
var ray_length = 5
@onready var pivot: Node3D = $Pivot
@onready var head: Camera3D = %head
@onready var inventory = $inventory
var base_fov = 90
var fov_change = 1.5
var jumped

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	# Capture mouse wheel scrolling for inventory
	if Input.is_action_just_pressed("showmouse"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			inventory.change_held_item(event.button_index)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			inventory.change_held_item(event.button_index)
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		pivot.rotate_y(-event.relative.x * mouse_sens)
		head.rotate_x(-event.relative.y * mouse_sens)
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-90), deg_to_rad(90))
	if Input.is_action_just_pressed("toggle_flashlight"):
		if %flashlight.visible:
			%flashlight.visible = false
		else:
			%flashlight.visible = true
	elif Input.is_action_just_pressed("showmouse") and Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# Raycasting code for interacting with the environment
func raycastFromMouse(r_length):
	var space_state = get_world_3d().get_direct_space_state()
	var cam = $Pivot/head
	var mousepos = get_viewport().get_mouse_position()
	var origin = cam.project_ray_origin(mousepos)
	var end = origin + cam.project_ray_normal(mousepos) * r_length
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true

	return space_state.intersect_ray(query)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
		jumped = true
		$sprint.stop()
		$steps.stop()
	if jumped == true and is_on_floor():
		$step_sound.play()
		jumped = false

	if Input.is_action_just_pressed("mouse_left"):
		var usedItem = inventory.get_current_item()
		var result
		# if is gun
		if  usedItem != null and get_tree().get_nodes_in_group("gun").has(usedItem):
			ray_length = 150
			result = raycastFromMouse(ray_length)
			usedItem.shoot(result)
			#start ammo charging if not charging
			if $ammo_charge.time_left == 0:
				$ammo_charge.start()
		ray_length = 2
		result = raycastFromMouse(ray_length)
		if result:
			if inventory.get_current_item() != null:
				inventory.get_current_item().useItem(result["collider"])
			if result["collider"].has_signal("press"):
				result["collider"].press.emit()
			#print(result["collider"])
	# use item without shooting gun		
	if Input.is_action_just_pressed("use"):
		var result
		ray_length = 2
		result = raycastFromMouse(ray_length)
		if result:
			if inventory.get_current_item() != null:
				inventory.get_current_item().useItem(result["collider"])
			if result["collider"].has_signal("press"):
				result["collider"].press.emit()

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forwards", "backwards")
	var direction := (pivot.transform.basis * transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			if $steps.time_left == 0 and $sprint.time_left == 0:

				if speed == SPRINT_SPEED:
					$sprint.start()
				if speed == WALK_SPEED:
					$steps.start()
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 77.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 77.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 2.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 2.0)
	t_bob += delta * velocity.length() * float(is_on_floor())
	head.transform.origin = _headbob(t_bob)
	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov = base_fov + fov_change * velocity_clamped
	head.fov = lerp(head.fov, target_fov, delta * 8.0)

	move_and_slide()

# Charge the gun
func _on_ammo_charge_timeout():
	if Player.vars["ammo"] <= 3:
		Player.vars["ammo"] += 1
	if Player.vars["ammo"] > 3:
		$ammo_charge.stop()

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos


func _on_steps_timeout() -> void:
	$step_sound.play()
