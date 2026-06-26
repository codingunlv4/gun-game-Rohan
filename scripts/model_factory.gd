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


static func build_dragon(parent: Node3D) -> Dictionary:
	_clear_children(parent)
	var scale_green := _dragon_scale()
	var scale_dark := _dragon_scale_dark()
	var belly := _dragon_belly()
	var horn := _dragon_horn()
	var eye := _dragon_eye()

	var body := _add_box(parent, Vector3(0.0, 0.0, 0.4), Vector3(2.4, 1.4, 3.6), scale_green, "Body")
	_add_box(parent, Vector3(0.0, -0.35, 0.5), Vector3(1.8, 0.5, 2.8), belly, "Belly")

	var neck := _add_cylinder(parent, Vector3(0.0, 0.8, -1.2), 0.55, 1.4, scale_green, Vector3.AXIS_Z, "Neck")
	neck.rotation_degrees = Vector3(-35.0, 0.0, 0.0)

	var head := _add_box(parent, Vector3(0.0, 1.3, -2.4), Vector3(1.1, 0.9, 1.4), scale_dark, "Head")
	_add_box(parent, Vector3(0.0, 1.15, -3.2), Vector3(0.7, 0.55, 1.2), scale_green, "Snout")
	_add_box(parent, Vector3(-0.35, 1.65, -2.2), Vector3(0.15, 0.35, 0.15), horn, "HornLeft")
	_add_box(parent, Vector3(0.35, 1.65, -2.2), Vector3(0.15, 0.35, 0.15), horn, "HornRight")
	_add_box(parent, Vector3(-0.28, 1.45, -2.95), Vector3(0.12, 0.12, 0.12), eye, "EyeLeft")
	_add_box(parent, Vector3(0.28, 1.45, -2.95), Vector3(0.12, 0.12, 0.12), eye, "EyeRight")

	var left_wing := Node3D.new()
	left_wing.name = "LeftWing"
	left_wing.position = Vector3(-1.3, 0.5, 0.2)
	parent.add_child(left_wing)
	_add_box(left_wing, Vector3(-1.6, 0.0, 0.0), Vector3(3.2, 0.08, 1.8), scale_dark, "WingMembrane")
	_add_box(left_wing, Vector3(-0.6, 0.05, 0.0), Vector3(0.18, 0.14, 1.4), horn, "WingBone")

	var right_wing := Node3D.new()
	right_wing.name = "RightWing"
	right_wing.position = Vector3(1.3, 0.5, 0.2)
	parent.add_child(right_wing)
	_add_box(right_wing, Vector3(1.6, 0.0, 0.0), Vector3(3.2, 0.08, 1.8), scale_dark, "WingMembrane")
	_add_box(right_wing, Vector3(0.6, 0.05, 0.0), Vector3(0.18, 0.14, 1.4), horn, "WingBone")

	var tail := _add_cylinder(parent, Vector3(0.0, 0.1, 2.4), 0.35, 2.2, scale_green, Vector3.AXIS_Z, "TailBase")
	tail.rotation_degrees = Vector3(25.0, 0.0, 0.0)
	var tail_tip := _add_cylinder(parent, Vector3(0.0, 0.55, 3.6), 0.2, 1.4, scale_dark, Vector3.AXIS_Z, "TailTip")
	tail_tip.rotation_degrees = Vector3(40.0, 0.0, 0.0)

	_add_cylinder(parent, Vector3(-0.9, -0.5, -0.4), 0.22, 1.0, scale_dark, Vector3.AXIS_Y, "LegFrontLeft")
	_add_cylinder(parent, Vector3(0.9, -0.5, -0.4), 0.22, 1.0, scale_dark, Vector3.AXIS_Y, "LegFrontRight")
	_add_cylinder(parent, Vector3(-0.8, -0.5, 1.2), 0.2, 0.9, scale_dark, Vector3.AXIS_Y, "LegBackLeft")
	_add_cylinder(parent, Vector3(0.8, -0.5, 1.2), 0.2, 0.9, scale_dark, Vector3.AXIS_Y, "LegBackRight")

	return {
		"body": body,
		"left_wing": left_wing,
		"right_wing": right_wing,
		"head": head,
	}


static func build_goblin(parent: Node3D) -> Dictionary:
	_clear_children(parent)
	var meshes: Array[MeshInstance3D] = []
	var skin := _goblin_skin()
	var skin_dark := _goblin_skin_dark()
	var cloth := _goblin_cloth()
	var metal := _metal_light()
	var eye := _goblin_eye()

	var torso := _add_box(parent, Vector3(0.0, 0.55, 0.0), Vector3(0.42, 0.48, 0.28), skin, "Torso")
	meshes.append(torso)
	var head := _add_box(parent, Vector3(0.0, 0.98, 0.02), Vector3(0.34, 0.34, 0.3), skin, "Head")
	meshes.append(head)
	var snout := _add_box(parent, Vector3(0.0, 0.9, -0.18), Vector3(0.22, 0.16, 0.18), skin_dark, "Snout")
	meshes.append(snout)
	var ear_l := _add_box(parent, Vector3(-0.2, 1.12, 0.0), Vector3(0.08, 0.18, 0.06), skin_dark, "EarLeft")
	meshes.append(ear_l)
	var ear_r := _add_box(parent, Vector3(0.2, 1.12, 0.0), Vector3(0.08, 0.18, 0.06), skin_dark, "EarRight")
	meshes.append(ear_r)
	var eye_l := _add_box(parent, Vector3(-0.1, 1.02, -0.14), Vector3(0.07, 0.07, 0.04), eye, "EyeLeft")
	meshes.append(eye_l)
	var eye_r := _add_box(parent, Vector3(0.1, 1.02, -0.14), Vector3(0.07, 0.07, 0.04), eye, "EyeRight")
	meshes.append(eye_r)

	var leg_l := _add_box(parent, Vector3(-0.12, 0.18, 0.0), Vector3(0.12, 0.36, 0.12), skin_dark, "LegLeft")
	meshes.append(leg_l)
	var leg_r := _add_box(parent, Vector3(0.12, 0.18, 0.0), Vector3(0.12, 0.36, 0.12), skin_dark, "LegRight")
	meshes.append(leg_r)
	var arm_l := _add_box(parent, Vector3(-0.28, 0.58, 0.0), Vector3(0.1, 0.34, 0.1), skin, "ArmLeft")
	meshes.append(arm_l)

	var arm_r := Node3D.new()
	arm_r.name = "ArmRight"
	arm_r.position = Vector3(0.28, 0.58, 0.0)
	parent.add_child(arm_r)
	var upper_arm := _add_box(arm_r, Vector3(0.0, -0.05, 0.0), Vector3(0.1, 0.34, 0.1), skin, "UpperArm")
	meshes.append(upper_arm)

	var dagger := _add_box(arm_r, Vector3(0.0, -0.28, -0.22), Vector3(0.04, 0.04, 0.34), metal, "Dagger")
	meshes.append(dagger)
	var handle := _add_box(arm_r, Vector3(0.0, -0.12, -0.08), Vector3(0.06, 0.08, 0.06), cloth, "DaggerHandle")
	meshes.append(handle)

	var loin := _add_box(parent, Vector3(0.0, 0.34, 0.0), Vector3(0.38, 0.12, 0.24), cloth, "Loincloth")
	meshes.append(loin)

	return {
		"meshes": meshes,
		"dagger": dagger,
	}


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


static func _dragon_scale() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.12, 0.42, 0.18)
	mat.metallic = 0.15
	mat.roughness = 0.55
	return mat


static func _dragon_scale_dark() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.08, 0.28, 0.12)
	mat.metallic = 0.2
	mat.roughness = 0.5
	return mat


static func _dragon_belly() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.55, 0.48, 0.22)
	mat.roughness = 0.7
	return mat


static func _dragon_horn() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.35, 0.32, 0.28)
	mat.metallic = 0.4
	mat.roughness = 0.45
	return mat


static func _dragon_eye() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 0.85, 0.1)
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.6, 0.05)
	mat.emission_energy_multiplier = 2.0
	return mat


static func _goblin_skin() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.22, 0.58, 0.18)
	mat.roughness = 0.72
	return mat


static func _goblin_skin_dark() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.14, 0.4, 0.12)
	mat.roughness = 0.75
	return mat


static func _goblin_cloth() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.42, 0.18, 0.12)
	mat.roughness = 0.82
	return mat


static func _goblin_eye() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 0.82, 0.1)
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.7, 0.05)
	mat.emission_energy_multiplier = 1.5
	return mat
