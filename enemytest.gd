extends CharacterBody3D

@export var SPEED = 3
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var PLAYER = $"../Player"
@onready var AGENT = $NavigationAgent3D

var NEXT_LOCATION
var CURRENT_LOCATION
var FIRST_CHECK = false

func _ready():
	$spookymusic.play()

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	NEXT_LOCATION = AGENT.get_next_path_position()
	CURRENT_LOCATION = global_transform.origin

	AGENT.target_position = PLAYER.global_transform.origin

	if player_view_ray().get("collider") == null and FIRST_CHECK:
		look_at(Vector3(AGENT.target_position.x, position.y, AGENT.target_position.z))

	var target_velocity = (NEXT_LOCATION - CURRENT_LOCATION).normalized() * SPEED

	velocity.x = target_velocity.x
	velocity.z = target_velocity.z

	move_and_slide()
	FIRST_CHECK  = true

func player_view_ray():
	var space_state = get_world_3d().direct_space_state
	var ray_start = global_transform.origin
	var ray_end = PLAYER.global_transform.origin
	var query = PhysicsRayQueryParameters3D.create(ray_start,ray_end)

	query.exclude = [self, PLAYER]

	return space_state.intersect_ray(query)
	
