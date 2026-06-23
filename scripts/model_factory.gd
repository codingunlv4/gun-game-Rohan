class_name ModelFactory
extends RefCounted


static func build_pistol(parent: Node3D) -> void:
	_clear_children(parent)
	var metal := _metal_dark()
	var metal_light := _metal_light()
	var polymer := _polymer_black()
	var wood := _wood_grip()

	_add_box(parent, Vector3(0.08, -0.1, -0.28), Vector3(0.07, 0.1, 0.24), metal, "Slide")
	_add_box(parent, Vector3(0.08, -0.14, -0.18), Vector3(0.065, 0.06, 0.14), metal_light, "Frame")
	_add_cylinder(parent, Vector3(0.08, -0.06, -0.46), 0.014, 0.16, metal, Vector3.AXIS_Z, "Barrel")
	_add_box(parent, Vector3(0.08, -0.2, -0.1), Vector3(0.055, 0.12, 0.08), wood, "Grip")
	_add_box(parent, Vector3(0.08, -0.16, -0.2), Vector3(0.05, 0.035, 0.06), polymer, "TriggerGuard")
	_add_box(parent, Vector3(0.08, -0.2, -0.02), Vector3(0.04, 0.09, 0.05), metal_light, "Magazine")
	_add_box(parent, Vector3(0.08, -0.04, -0.52), Vector3(0.012, 0.025, 0.012), metal_light, "FrontSight")
	_add_box(parent, Vector3(0.08, -0.03, -0.17), Vector3(0.018, 0.02, 0.025), metal_light, "RearSight")
	_add_box(parent, Vector3(0.08, -0.02, -0.14), Vector3(0.02, 0.03, 0.02), metal, "Hammer")


static func build_rifle(parent: Node3D) -> void:
	_clear_children(parent)
	var metal := _metal_dark()
	var metal_light := _metal_light()
	var polymer := _polymer_black()
	var accent := _od_green()

	_add_box(parent, Vector3(0.1, -0.1, -0.38), Vector3(0.07, 0.11, 0.42), metal, "Receiver")
	_add_box(parent, Vector3(0.1, -0.05, -0.68), Vector3(0.035, 0.035, 0.38), metal_light, "Barrel")
	_add_box(parent, Vector3(0.1, -0.05, -0.5), Vector3(0.055, 0.055, 0.28), accent, "Handguard")
	_add_box(parent, Vector3(0.1, -0.08, -0.08), Vector3(0.06, 0.08, 0.18), polymer, "Stock")
	_add_box(parent, Vector3(0.1, -0.18, -0.22), Vector3(0.05, 0.13, 0.07), polymer, "Grip")
	_add_box(parent, Vector3(0.1, -0.2, -0.32), Vector3(0.045, 0.14, 0.06), metal_light, "Magazine")
	_add_box(parent, Vector3(0.1, -0.02, -0.3), Vector3(0.05, 0.06, 0.12), metal, "CarryHandle")
	_add_cylinder(parent, Vector3(0.1, -0.05, -0.88), 0.022, 0.06, metal, Vector3.AXIS_Z, "MuzzleBrake")
	_add_box(parent, Vector3(0.14, -0.06, -0.55), Vector3(0.015, 0.04, 0.08), metal_light, "Rail")


static func build_shotgun(parent: Node3D) -> void:
	_clear_children(parent)
	var metal := _metal_dark()
	var metal_light := _metal_light()
	var wood := _wood_grip()

	_add_box(parent, Vector3(0.12, -0.1, -0.35), Vector3(0.08, 0.09, 0.28), metal, "Receiver")
	_add_cylinder(parent, Vector3(0.1, -0.04, -0.72), 0.022, 0.42, metal_light, Vector3.AXIS_Z, "BarrelLeft")
	_add_cylinder(parent, Vector3(0.14, -0.04, -0.72), 0.022, 0.42, metal_light, Vector3.AXIS_Z, "BarrelRight")
	_add_box(parent, Vector3(0.12, -0.06, -0.55), Vector3(0.1, 0.07, 0.22), wood, "Forend")
	_add_box(parent, Vector3(0.12, -0.08, -0.1), Vector3(0.07, 0.07, 0.2), wood, "Stock")
	_add_box(parent, Vector3(0.12, -0.14, -0.24), Vector3(0.05, 0.05, 0.08), metal, "TriggerGroup")
	_add_box(parent, Vector3(0.12, -0.04, -0.18), Vector3(0.025, 0.03, 0.06), metal_light, "Sight")


static func build_target(parent: Node3D) -> Array[MeshInstance3D]:
	_clear_children(parent)
	var meshes: Array[MeshInstance3D] = []
	var frame_mat := _wood_grip()
	var white := _paper_white()
	var red := _target_red()
	var black := _target_black()
	var metal := _metal_light()

	var base := _add_box(parent, Vector3(0.0, 0.15, 0.0), Vector3(0.5, 0.08, 0.5), metal, "Base")
	meshes.append(base)
	var pole := _add_cylinder(parent, Vector3(0.0, 0.65, 0.0), 0.04, 1.0, metal, Vector3.AXIS_Y, "Pole")
	meshes.append(pole)
	var board := _add_box(parent, Vector3(0.0, 1.35, 0.05), Vector3(0.9, 1.2, 0.06), frame_mat, "Frame")
	meshes.append(board)
	var paper := _add_box(parent, Vector3(0.0, 1.35, 0.1), Vector3(0.78, 1.05, 0.02), white, "Paper")
	meshes.append(paper)

	_add_cylinder(parent, Vector3(0.0, 1.55, 0.12), 0.22, 0.015, black, Vector3.AXIS_Z, "RingOuter")
	_add_cylinder(parent, Vector3(0.0, 1.35, 0.12), 0.16, 0.016, white, Vector3.AXIS_Z, "RingMid")
	_add_cylinder(parent, Vector3(0.0, 1.15, 0.12), 0.1, 0.017, red, Vector3.AXIS_Z, "RingInner")
	_add_cylinder(parent, Vector3(0.0, 0.98, 0.12), 0.04, 0.018, black, Vector3.AXIS_Z, "Bullseye")

	return meshes


static func build_crate(parent: Node3D, size: Vector3 = Vector3(2.0, 1.5, 2.0)) -> void:
	_clear_children(parent)
	var wood := _wood_grip()
	var wood_dark := _wood_dark()

	_add_box(parent, Vector3.ZERO, size, wood, "CrateBody")
	var plank_w := size.x * 0.92
	var plank_h := 0.08
	_add_box(parent, Vector3(0.0, size.y * 0.25, size.z * 0.51), Vector3(plank_w, plank_h, 0.06), wood_dark, "Plank1")
	_add_box(parent, Vector3(0.0, -size.y * 0.1, size.z * 0.51), Vector3(plank_w, plank_h, 0.06), wood_dark, "Plank2")
	_add_box(parent, Vector3(size.x * 0.51, 0.0, 0.0), Vector3(0.06, size.y * 0.85, size.z * 0.85), wood_dark, "PlankSide")


static func build_barrel(parent: Node3D) -> void:
	_clear_children(parent)
	var metal := _metal_dark()
	var band := _metal_light()

	_add_cylinder(parent, Vector3(0.0, 0.45, 0.0), 0.35, 0.9, metal, Vector3.AXIS_Y, "BarrelBody")
	_add_cylinder(parent, Vector3(0.0, 0.05, 0.0), 0.38, 0.08, band, Vector3.AXIS_Y, "Rim")
	_add_cylinder(parent, Vector3(0.0, 0.88, 0.0), 0.36, 0.06, band, Vector3.AXIS_Y, "Band")


static func muzzle_flash_mesh() -> MeshInstance3D:
	var flash_mat := StandardMaterial3D.new()
	flash_mat.albedo_color = Color(1.0, 0.75, 0.2)
	flash_mat.emission_enabled = true
	flash_mat.emission = Color(1.0, 0.6, 0.1)
	flash_mat.emission_energy_multiplier = 4.0
	flash_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED

	var flash := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = 0.04
	mesh.height = 0.08
	flash.mesh = mesh
	flash.set_surface_override_material(0, flash_mat)
	return flash


static func _clear_children(parent: Node3D) -> void:
	for child in parent.get_children():
		child.queue_free()


static func _add_box(parent: Node3D, pos: Vector3, size: Vector3, mat: Material, node_name: String = "") -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	if node_name != "":
		mesh_instance.name = node_name
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh_instance.mesh = mesh
	mesh_instance.position = pos
	mesh_instance.set_surface_override_material(0, mat)
	parent.add_child(mesh_instance)
	return mesh_instance


static func _add_cylinder(
	parent: Node3D,
	pos: Vector3,
	radius: float,
	height: float,
	mat: Material,
	axis: Vector3.Axis,
	node_name: String = ""
) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	if node_name != "":
		mesh_instance.name = node_name
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh_instance.mesh = mesh
	mesh_instance.position = pos

	if axis == Vector3.AXIS_Z:
		mesh_instance.rotation_degrees = Vector3(90.0, 0.0, 0.0)
	elif axis == Vector3.AXIS_X:
		mesh_instance.rotation_degrees = Vector3(0.0, 0.0, 90.0)

	mesh_instance.set_surface_override_material(0, mat)
	parent.add_child(mesh_instance)
	return mesh_instance


static func _metal_dark() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.11, 0.11, 0.13)
	mat.metallic = 0.92
	mat.roughness = 0.32
	return mat


static func _metal_light() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.28, 0.29, 0.31)
	mat.metallic = 0.85
	mat.roughness = 0.38
	return mat


static func _polymer_black() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.06, 0.06, 0.07)
	mat.metallic = 0.15
	mat.roughness = 0.65
	return mat


static func _wood_grip() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.38, 0.24, 0.12)
	mat.roughness = 0.78
	return mat


static func _wood_dark() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.25, 0.16, 0.08)
	mat.roughness = 0.82
	return mat


static func _od_green() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.18, 0.24, 0.14)
	mat.metallic = 0.2
	mat.roughness = 0.7
	return mat


static func _paper_white() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.92, 0.9, 0.85)
	mat.roughness = 0.9
	return mat


static func _target_red() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.82, 0.12, 0.1)
	mat.roughness = 0.75
	return mat


static func _target_black() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.05, 0.05, 0.05)
	mat.roughness = 0.8
	return mat
