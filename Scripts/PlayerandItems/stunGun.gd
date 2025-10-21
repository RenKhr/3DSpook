extends Item

var electricityMat = preload("res://Resources/Materials/m_gunElectricity.tres")

func _process(_delta):
	#manage gun ammo display
	if self.has_node("ammo"):
		match Player.vars["ammo"]:
			4:
				$ammo.set_region_rect(Rect2(0,0,32,32))
				$ammo/light.light_energy = 0.25
				$ammo/light.omni_range = 0.12
			3:
				$ammo.set_region_rect(Rect2(0,32,32,32))
				$ammo/light.light_energy = 0.2
				$ammo/light.omni_range = 0.11
			2:
				$ammo.set_region_rect(Rect2(0,64,32,32))
				$ammo/light.light_energy = 0.15
				$ammo/light.omni_range = 0.10
			1:
				$ammo.set_region_rect(Rect2(0,96,32,32))
				$ammo/light.light_energy = 0.1
				$ammo/light.omni_range = 0.09
			0:
				$ammo.set_region_rect(Rect2(0,128,32,32))
				$ammo/light.light_energy = 0.05
				$ammo/light.omni_range = 0.08
		if self.scale == Vector3(1,1,1):
			$ammo/light.omni_range /= 2

func shoot(target):
	if Player.vars["ammo"] > 0:
		var barrel = $Marker3D.global_position
		var targetPoint = target["position"]
		lineDraw(barrel, targetPoint)
		$shoot.play()

		#manage ammo (impressive I know)
		Player.vars["ammo"] -= 1
	
func lineDraw(from: Vector3, to: Vector3, persist_s = 0.1):
	var mesh_instance := MeshInstance3D.new()
	var immediate_mesh := ImmediateMesh.new()
	var directionVector = (to - from).normalized();
	var playerDirection = player.transform.basis.x * -1.0
	var vertexDistance = 0.05
	var stripThickness = 0.01
	var amountOfVertexes = int(from.distance_to(to) / vertexDistance)
	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLE_STRIP, electricityMat)
	for i in amountOfVertexes:
		var shift = (Vector3(playerDirection.x * (i % 2), 0, playerDirection.z * (i % 2))).normalized()
		immediate_mesh.surface_add_vertex(from + directionVector * i * vertexDistance + shift * stripThickness)
		immediate_mesh.surface_set_normal(Vector3(0, -1, 0))
	for i in amountOfVertexes:
		var shift = (Vector3(playerDirection.x * (i % 2), 0, playerDirection.z * (i % 2))).normalized()
		immediate_mesh.surface_add_vertex(from + directionVector * (amountOfVertexes - i) * vertexDistance + shift * stripThickness)
		immediate_mesh.surface_set_normal(Vector3(0, 1, 0))
	immediate_mesh.surface_end()
	#print(mesh_instance.mesh.surface_get_arrays(0))
	#print(get_parent().get_parent().get_parent().transform.basis)

	get_tree().get_root().add_child(mesh_instance)
	if persist_s:
		await get_tree().create_timer(persist_s).timeout
		mesh_instance.queue_free()
	else:
		return mesh_instance
