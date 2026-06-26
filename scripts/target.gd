extends StaticBody3D

@export var max_health: float = 100.0
@export var respawn_time: float = 3.0

var _health: float
var _paper_mesh: MeshInstance3D
var _alive: bool = true
var _default_position: Vector3
var _default_rotation: Vector3
var _hit_player: AudioStreamPlayer3D
var _destroy_player: AudioStreamPlayer3D


func _ready() -> void:
	_health = max_health
	_default_position = global_position
	_default_rotation = rotation
	_build_target_model()

	_hit_player = AudioStreamPlayer3D.new()
	_hit_player.stream = AudioFactory.target_hit()
	add_child(_hit_player)

	_destroy_player = AudioStreamPlayer3D.new()
	_destroy_player.stream = AudioFactory.target_destroyed()
	add_child(_destroy_player)


func _build_target_model() -> void:
	var model_root := get_node_or_null("Model") as Node3D
	if not model_root:
		model_root = Node3D.new()
		model_root.name = "Model"
		add_child(model_root)

	var old_mesh := get_node_or_null("MeshInstance3D")
	if old_mesh:
		old_mesh.queue_free()

	var meshes := ModelFactory.build_target(model_root)
	for mesh in meshes:
		if mesh.name == "Paper":
			_paper_mesh = mesh
			break


func take_damage(amount: float, _hit_position: Vector3 = Vector3.ZERO) -> void:
	if not _alive:
		return

	_health -= amount
	_hit_player.pitch_scale = randf_range(0.9, 1.15)
	_hit_player.play()
	_flash_hit()

	if _health <= 0.0:
		_die()


func _flash_hit() -> void:
	if not _paper_mesh:
		return

	var mat := _paper_mesh.get_active_material(0) as StandardMaterial3D
	if not mat:
		return

	var original := mat.albedo_color
	mat.albedo_color = Color(1.0, 0.35, 0.3)
	await get_tree().create_timer(0.08).timeout
	if is_instance_valid(mat):
		mat.albedo_color = original


func _die() -> void:
	_alive = false
	_destroy_player.play()
	visible = false
	set_collision_layer_value(1, false)
	await get_tree().create_timer(respawn_time).timeout
	_respawn()


func _respawn() -> void:
	_health = max_health
	global_position = _default_position
	rotation = _default_rotation
	visible = true
	set_collision_layer_value(1, true)
	_alive = true
