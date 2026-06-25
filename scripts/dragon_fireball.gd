extends Area3D

const SPEED := 28.0
const DAMAGE := 18.0
const LIFETIME := 4.0

var _direction := Vector3.FORWARD
var _alive := true


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_build_visual()
	await get_tree().create_timer(LIFETIME).timeout
	if _alive:
		queue_free()


func launch(origin: Vector3, direction: Vector3) -> void:
	global_position = origin
	_direction = direction.normalized()
	if absf(_direction.dot(Vector3.UP)) > 0.98:
		rotation = Vector3.ZERO
	else:
		look_at(global_position + _direction, Vector3.UP)


func _physics_process(delta: float) -> void:
	global_position += _direction * SPEED * delta


func _build_visual() -> void:
	var mesh_instance := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = 0.35
	mesh.height = 0.7
	mesh_instance.mesh = mesh

	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 0.45, 0.1)
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.35, 0.05)
	mat.emission_energy_multiplier = 3.5
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mesh_instance.set_surface_override_material(0, mat)
	add_child(mesh_instance)

	var shape := SphereShape3D.new()
	shape.radius = 0.4
	var collision := CollisionShape3D.new()
	collision.shape = shape
	add_child(collision)


func _on_body_entered(body: Node3D) -> void:
	if not _alive:
		return

	if body.is_in_group("enemies"):
		return

	if body.has_method("take_damage"):
		body.take_damage(DAMAGE, global_position)
		_explode()
	elif body is StaticBody3D or body is CSGShape3D:
		_explode()


func _explode() -> void:
	_alive = false
	queue_free()
