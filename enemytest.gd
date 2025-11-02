extends CharacterBody3D

@export var speed = 3
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var player = $"../Player"
@onready var agent = $NavigationAgent3D

var next_location
var current_location
var first_check = false

func _ready():
	$spookymusic.play()

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	next_location = agent.get_next_path_position()
	current_location = global_transform.origin

	agent.target_position = player.global_transform.origin

	if player_view_ray().get("collider") == null and first_check:
		look_at(Vector3(agent.target_position.x, position.y, agent.target_position.z))

	var target_velocity = (next_location - current_location).normalized() * speed

	velocity.x = target_velocity.x
	velocity.z = target_velocity.z

	move_and_slide()
	first_check = true

func player_view_ray():
	var space_state = get_world_3d().direct_space_state
	var ray_start = global_transform.origin
	var ray_end = player.global_transform.origin
	var query = PhysicsRayQueryParameters3D.create(ray_start,ray_end)

	query.exclude = [self, player]

	return space_state.intersect_ray(query)
	
