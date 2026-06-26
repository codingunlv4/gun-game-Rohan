extends Node3D

const TARGET_SCENE := preload("res://scenes/target.tscn")
const DRAGON_SCENE := preload("res://scenes/dragon.tscn")
const GOBLIN_SCENE := preload("res://scenes/goblin.tscn")
const MAP_HALF := 120.0
const TILE_SPACING := 11.0

var _concrete := StandardMaterial3D.new()
var _metal := StandardMaterial3D.new()
var _wood := StandardMaterial3D.new()
var _accent := StandardMaterial3D.new()


func _ready() -> void:
	_setup_materials()
	_build_floor()
	_build_outer_walls()
	_build_warehouse(Vector3(-70.0, 0.0, -70.0))
	_build_warehouse(Vector3(70.0, 0.0, -70.0))
	_build_warehouse(Vector3(-70.0, 0.0, 70.0))
	_build_corridor_maze(Vector3(60.0, 0.0, 0.0))
	_build_corridor_maze(Vector3(-60.0, 0.0, 0.0))
	_build_elevated_arena(Vector3(0.0, 0.0, 75.0))
	_build_elevated_arena(Vector3(0.0, 0.0, -75.0))
	_build_sniper_lane()
	_build_crossroads()
	_build_open_yards()
	_build_perimeter_bunkers()
	_build_cover_clusters()
	_spawn_targets()
	_spawn_dragons()
	_spawn_goblins()
	_setup_ambient_audio()


func _setup_ambient_audio() -> void:
	var ambient := get_parent().get_node_or_null("AmbientAudio") as AudioStreamPlayer
	if not ambient:
		return
	ambient.stream = AudioFactory.ambient_wind()
	ambient.finished.connect(ambient.play)


func _setup_materials() -> void:
	_concrete.albedo_color = Color(0.24, 0.25, 0.27)
	_concrete.roughness = 0.9

	_metal.albedo_color = Color(0.35, 0.38, 0.42)
	_metal.metallic = 0.7
	_metal.roughness = 0.45

	_wood.albedo_color = Color(0.42, 0.28, 0.16)
	_wood.roughness = 0.75

	_accent.albedo_color = Color(0.18, 0.32, 0.48)
	_accent.roughness = 0.65


func _build_floor() -> void:
	var floor_body := StaticBody3D.new()
	floor_body.name = "Floor"
	add_child(floor_body)

	var shape := BoxShape3D.new()
	shape.size = Vector3(MAP_HALF * 2.0, 1.0, MAP_HALF * 2.0)
	var collision := CollisionShape3D.new()
	collision.shape = shape
	collision.position = Vector3(0.0, -0.5, 0.0)
	floor_body.add_child(collision)

	var mesh_instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = shape.size
	mesh_instance.mesh = mesh
	mesh_instance.position = collision.position
	mesh_instance.set_surface_override_material(0, _concrete)
	floor_body.add_child(mesh_instance)

	var tile_span := int(ceil(MAP_HALF * 2.0 / TILE_SPACING) * 0.5)
	for x in range(-tile_span, tile_span + 1):
		for z in range(-tile_span, tile_span + 1):
			if abs(x) < 3 and abs(z) < 3:
				continue
			var stripe := MeshInstance3D.new()
			var tile := BoxMesh.new()
			tile.size = Vector3(TILE_SPACING + 0.5, 0.05, TILE_SPACING + 0.5)
			stripe.mesh = tile
			stripe.position = Vector3(x * TILE_SPACING, 0.02, z * TILE_SPACING)
			var mat := _concrete.duplicate() as StandardMaterial3D
			mat.albedo_color = Color(0.2, 0.21, 0.23) if (x + z) % 2 == 0 else Color(0.27, 0.28, 0.3)
			stripe.set_surface_override_material(0, mat)
			floor_body.add_child(stripe)


func _build_outer_walls() -> void:
	var wall_height := 10.0
	var thickness := 1.5
	var length := MAP_HALF * 2.0
	_add_wall("WallNorth", Vector3(0.0, wall_height * 0.5, -MAP_HALF), Vector3(length, wall_height, thickness), _metal)
	_add_wall("WallSouth", Vector3(0.0, wall_height * 0.5, MAP_HALF), Vector3(length, wall_height, thickness), _metal)
	_add_wall("WallWest", Vector3(-MAP_HALF, wall_height * 0.5, 0.0), Vector3(thickness, wall_height, length), _metal)
	_add_wall("WallEast", Vector3(MAP_HALF, wall_height * 0.5, 0.0), Vector3(thickness, wall_height, length), _metal)


func _build_warehouse(center: Vector3) -> void:
	var root := Node3D.new()
	root.name = "Warehouse_%d_%d" % [int(center.x), int(center.z)]
	root.position = center
	add_child(root)

	_add_csg_box(root, Vector3(0.0, 3.0, 0.0), Vector3(34.0, 6.0, 34.0), _accent, true)
	_add_csg_box(root, Vector3(0.0, 3.0, 17.0), Vector3(34.0, 6.0, 1.0), _metal, true)
	_add_csg_box(root, Vector3(0.0, 3.0, -17.0), Vector3(34.0, 6.0, 1.0), _metal, true)
	_add_csg_box(root, Vector3(-17.0, 3.0, 0.0), Vector3(1.0, 6.0, 34.0), _metal, true)
	_add_csg_box(root, Vector3(17.0, 3.0, 0.0), Vector3(1.0, 6.0, 34.0), _metal, true)

	for row in 3:
		for col in 4:
			_add_prop_crate(root, Vector3(-13.0 + col * 8.0, 1.0, -13.0 + row * 8.0), Vector3(2.2, 2.0, 2.2))


func _build_corridor_maze(center: Vector3) -> void:
	var root := Node3D.new()
	root.name = "CorridorMaze_%d_%d" % [int(center.x), int(center.z)]
	root.position = center
	add_child(root)

	var segments := [
		[Vector3(0.0, 2.5, -10.0), Vector3(24.0, 5.0, 2.0)],
		[Vector3(0.0, 2.5, 10.0), Vector3(24.0, 5.0, 2.0)],
		[Vector3(12.0, 2.5, 0.0), Vector3(2.0, 5.0, 24.0)],
		[Vector3(-12.0, 2.5, 0.0), Vector3(2.0, 5.0, 24.0)],
		[Vector3(0.0, 2.5, 22.0), Vector3(14.0, 5.0, 2.0)],
		[Vector3(0.0, 2.5, -22.0), Vector3(14.0, 5.0, 2.0)],
	]

	for segment in segments:
		_add_csg_box(root, segment[0], segment[1], _metal, true)

	for i in 4:
		_add_prop_crate(root, Vector3(-6.0 + i * 5.0, 0.75, 16.0), Vector3(1.8, 1.5, 1.8))
		_add_prop_crate(root, Vector3(-6.0 + i * 5.0, 0.75, -16.0), Vector3(1.8, 1.5, 1.8))


func _build_elevated_arena(center: Vector3) -> void:
	var root := Node3D.new()
	root.name = "ElevatedArena_%d_%d" % [int(center.x), int(center.z)]
	root.position = center
	add_child(root)

	_add_static_platform(root, Vector3(0.0, 2.0, 0.0), Vector3(28.0, 0.8, 20.0), _accent)
	_add_static_platform(root, Vector3(-16.0, 1.0, -7.0), Vector3(8.0, 0.5, 10.0), _concrete)
	_add_static_platform(root, Vector3(16.0, 1.0, -7.0), Vector3(8.0, 0.5, 10.0), _concrete)
	_add_prop_crate(root, Vector3(0.0, 0.75, -11.0), Vector3(6.0, 1.5, 3.0))
	_add_prop_barrel(root, Vector3(-10.0, 0.45, -3.0))
	_add_prop_barrel(root, Vector3(10.0, 0.45, -3.0))


func _build_sniper_lane() -> void:
	var root := Node3D.new()
	root.name = "SniperLane"
	add_child(root)

	var lane_length := MAP_HALF * 1.6
	_add_csg_box(root, Vector3(-8.0, 1.5, 0.0), Vector3(2.0, 3.0, lane_length), _metal, true)
	_add_csg_box(root, Vector3(8.0, 1.5, 0.0), Vector3(2.0, 3.0, lane_length), _metal, true)

	var step := 12
	var z_start := int(-lane_length * 0.5)
	var z_end := int(lane_length * 0.5)
	for z in range(z_start, z_end + 1, step):
		_add_prop_crate(root, Vector3(0.0, 0.6, z), Vector3(3.0, 1.2, 3.0))


func _build_crossroads() -> void:
	var root := Node3D.new()
	root.name = "Crossroads"
	add_child(root)

	var arm := MAP_HALF * 0.55
	_add_csg_box(root, Vector3(0.0, 1.5, 0.0), Vector3(8.0, 3.0, arm * 2.0), _metal, true)
	_add_csg_box(root, Vector3(0.0, 1.5, 0.0), Vector3(arm * 2.0, 3.0, 8.0), _metal, true)

	for offset in [-40.0, -20.0, 20.0, 40.0]:
		_add_prop_crate(root, Vector3(offset, 0.75, 0.0), Vector3(2.5, 1.5, 2.5))
		_add_prop_crate(root, Vector3(0.0, 0.75, offset), Vector3(2.5, 1.5, 2.5))
		_add_prop_barrel(root, Vector3(offset, 0.45, 6.0))
		_add_prop_barrel(root, Vector3(6.0, 0.45, offset))


func _build_open_yards() -> void:
	var root := Node3D.new()
	root.name = "OpenYards"
	add_child(root)

	var yard_centers: Array[Vector3] = [
		Vector3(95.0, 0.0, 95.0),
		Vector3(-95.0, 0.0, 95.0),
		Vector3(95.0, 0.0, -95.0),
		Vector3(-95.0, 0.0, -95.0),
		Vector3(0.0, 0.0, 105.0),
		Vector3(0.0, 0.0, -105.0),
	]

	for center in yard_centers:
		_add_static_platform(root, center + Vector3(0.0, 0.15, 0.0), Vector3(22.0, 0.3, 22.0), _wood)
		for i in 6:
			var angle := float(i) / 6.0 * TAU
			var radius := 8.0 + float(i % 2) * 3.0
			var pos := center + Vector3(cos(angle) * radius, 0.75, sin(angle) * radius)
			if i % 3 == 0:
				_add_prop_barrel(root, pos + Vector3(0.0, -0.3, 0.0))
			else:
				_add_prop_crate(root, pos, Vector3(2.0, 1.5, 2.0))


func _build_perimeter_bunkers() -> void:
	var root := Node3D.new()
	root.name = "PerimeterBunkers"
	add_child(root)

	var inset := MAP_HALF - 12.0
	var bunker_spots: Array[Vector3] = [
		Vector3(inset, 0.0, 0.0),
		Vector3(-inset, 0.0, 0.0),
		Vector3(0.0, 0.0, inset),
		Vector3(0.0, 0.0, -inset),
		Vector3(inset * 0.7, 0.0, inset * 0.7),
		Vector3(-inset * 0.7, 0.0, inset * 0.7),
		Vector3(inset * 0.7, 0.0, -inset * 0.7),
		Vector3(-inset * 0.7, 0.0, -inset * 0.7),
	]

	for spot in bunker_spots:
		_add_csg_box(root, spot + Vector3(0.0, 1.5, 0.0), Vector3(10.0, 3.0, 6.0), _accent, true)
		_add_prop_crate(root, spot + Vector3(3.0, 0.75, 0.0), Vector3(2.4, 1.5, 1.8))
		_add_prop_barrel(root, spot + Vector3(-3.0, 0.45, 0.0))


func _build_cover_clusters() -> void:
	var root := Node3D.new()
	root.name = "Cover"
	add_child(root)

	var positions: Array[Vector3] = [
		Vector3(-25.0, 0.75, 25.0),
		Vector3(25.0, 0.75, 18.0),
		Vector3(-40.0, 0.75, 40.0),
		Vector3(40.0, 0.75, -25.0),
		Vector3(-12.0, 0.75, -18.0),
		Vector3(15.0, 0.75, -35.0),
		Vector3(-55.0, 0.75, 12.0),
		Vector3(80.0, 0.75, -55.0),
		Vector3(-80.0, 0.75, 55.0),
		Vector3(55.0, 0.75, 55.0),
		Vector3(-55.0, 0.75, -55.0),
		Vector3(30.0, 0.75, 45.0),
		Vector3(-30.0, 0.75, -45.0),
		Vector3(0.0, 0.75, 40.0),
		Vector3(0.0, 0.75, -40.0),
		Vector3(45.0, 0.75, 0.0),
		Vector3(-45.0, 0.75, 0.0),
	]

	for pos in positions:
		_add_prop_crate(root, pos, Vector3(2.8, 1.5, 1.6))
		_add_prop_barrel(root, Vector3(pos.x + 3.2, 0.45, pos.z))
		_add_prop_crate(root, Vector3(pos.x - 2.5, 0.75, pos.z + 2.8), Vector3(2.0, 1.4, 2.0))


func _spawn_targets() -> void:
	var root := Node3D.new()
	root.name = "Targets"
	add_child(root)

	var spots := [
		[Vector3(0.0, 0.0, -25.0), 0.0],
		[Vector3(-95.0, 0.0, -95.0), 0.4],
		[Vector3(-45.0, 0.0, -95.0), -0.3],
		[Vector3(-95.0, 0.0, -45.0), 0.8],
		[Vector3(95.0, 0.0, -95.0), -0.4],
		[Vector3(45.0, 0.0, -95.0), 0.3],
		[Vector3(95.0, 0.0, -45.0), -0.8],
		[Vector3(-95.0, 0.0, 95.0), 2.4],
		[Vector3(-45.0, 0.0, 95.0), 2.0],
		[Vector3(95.0, 0.0, 95.0), -2.4],
		[Vector3(45.0, 0.0, 95.0), -2.0],
		[Vector3(85.0, 0.0, 0.0), PI * 0.5],
		[Vector3(85.0, 0.0, 35.0), PI * 0.5],
		[Vector3(-85.0, 0.0, 0.0), -PI * 0.5],
		[Vector3(-85.0, 0.0, -35.0), -PI * 0.5],
		[Vector3(60.0, 0.0, -40.0), PI],
		[Vector3(60.0, 0.0, 40.0), 0.0],
		[Vector3(-60.0, 0.0, 40.0), PI],
		[Vector3(-60.0, 0.0, -40.0), 0.0],
		[Vector3(0.0, 2.4, 80.0), PI],
		[Vector3(0.0, 2.4, -80.0), 0.0],
		[Vector3(-28.0, 1.5, 72.0), 0.5],
		[Vector3(28.0, 1.5, 72.0), -0.5],
		[Vector3(-28.0, 1.5, -72.0), -0.5],
		[Vector3(28.0, 1.5, -72.0), 0.5],
		[Vector3(-12.0, 0.0, -55.0), 0.2],
		[Vector3(12.0, 0.0, 55.0), -0.2],
		[Vector3(-60.0, 0.0, 35.0), 1.2],
		[Vector3(60.0, 0.0, -35.0), -1.2],
		[Vector3(100.0, 0.0, -80.0), -0.8],
		[Vector3(-100.0, 0.0, 80.0), 2.0],
		[Vector3(40.0, 0.0, 100.0), PI * 1.1],
		[Vector3(-40.0, 0.0, -100.0), PI * 0.9],
		[Vector3(108.0, 0.0, 108.0), PI * 0.75],
		[Vector3(-108.0, 0.0, 108.0), PI * 1.25],
		[Vector3(108.0, 0.0, -108.0), -PI * 0.75],
		[Vector3(-108.0, 0.0, -108.0), -PI * 1.25],
		[Vector3(0.0, 0.0, 0.0), 0.0],
		[Vector3(35.0, 0.0, 15.0), 0.6],
		[Vector3(-35.0, 0.0, -15.0), -0.6],
	]

	for spot in spots:
		var target := TARGET_SCENE.instantiate()
		target.position = spot[0]
		target.rotation.y = spot[1]
		root.add_child(target)


func _spawn_dragons() -> void:
	var root := Node3D.new()
	root.name = "Dragons"
	add_child(root)

	var spots: Array[Vector3] = [
		Vector3(0.0, 14.0, -40.0),
		Vector3(-70.0, 16.0, 0.0),
		Vector3(70.0, 12.0, 30.0),
		Vector3(0.0, 18.0, 60.0),
	]

	for spot in spots:
		var dragon := DRAGON_SCENE.instantiate()
		dragon.position = spot
		root.add_child(dragon)


func _spawn_goblins() -> void:
	var root := Node3D.new()
	root.name = "Goblins"
	add_child(root)

	var spots: Array[Vector3] = [
		Vector3(-40.0, 0.0, 0.0),
		Vector3(40.0, 0.0, 0.0),
		Vector3(0.0, 0.0, -55.0),
		Vector3(-60.0, 0.0, 35.0),
		Vector3(60.0, 0.0, -35.0),
		Vector3(-70.0, 0.0, -55.0),
		Vector3(70.0, 0.0, 55.0),
		Vector3(-50.0, 0.0, -75.0),
		Vector3(50.0, 0.0, 75.0),
		Vector3(0.0, 0.0, 35.0),
		Vector3(-85.0, 0.0, 30.0),
		Vector3(85.0, 0.0, -30.0),
	]

	for spot in spots:
		var goblin := GOBLIN_SCENE.instantiate()
		goblin.position = spot
		root.add_child(goblin)


func _add_wall(wall_name: String, position: Vector3, size: Vector3, material: StandardMaterial3D) -> void:
	var wall := StaticBody3D.new()
	wall.name = wall_name
	add_child(wall)

	var shape := BoxShape3D.new()
	shape.size = size
	var collision := CollisionShape3D.new()
	collision.shape = shape
	collision.position = position
	wall.add_child(collision)

	var mesh_instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh_instance.mesh = mesh
	mesh_instance.position = position
	mesh_instance.set_surface_override_material(0, material)
	wall.add_child(mesh_instance)


func _add_static_platform(parent: Node3D, position: Vector3, size: Vector3, material: StandardMaterial3D) -> void:
	var body := StaticBody3D.new()
	parent.add_child(body)

	var shape := BoxShape3D.new()
	shape.size = size
	var collision := CollisionShape3D.new()
	collision.shape = shape
	collision.position = position
	body.add_child(collision)

	var mesh_instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh_instance.mesh = mesh
	mesh_instance.position = position
	mesh_instance.set_surface_override_material(0, material)
	body.add_child(mesh_instance)


func _add_csg_box(parent: Node3D, position: Vector3, size: Vector3, material: StandardMaterial3D, collision: bool) -> void:
	var box := CSGBox3D.new()
	box.position = position
	box.size = size
	box.use_collision = collision
	box.material = material
	parent.add_child(box)


func _add_prop_crate(parent: Node3D, position: Vector3, size: Vector3) -> void:
	var body := StaticBody3D.new()
	body.position = position
	parent.add_child(body)

	var shape := BoxShape3D.new()
	shape.size = size
	var collision := CollisionShape3D.new()
	collision.shape = shape
	body.add_child(collision)

	var model_root := Node3D.new()
	body.add_child(model_root)
	ModelFactory.build_crate(model_root, size)


func _add_prop_barrel(parent: Node3D, position: Vector3) -> void:
	var body := StaticBody3D.new()
	body.position = position
	parent.add_child(body)

	var shape := CylinderShape3D.new()
	shape.radius = 0.38
	shape.height = 0.92
	var collision := CollisionShape3D.new()
	collision.shape = shape
	collision.position = Vector3(0.0, 0.46, 0.0)
	body.add_child(collision)

	var model_root := Node3D.new()
	body.add_child(model_root)
	ModelFactory.build_barrel(model_root)
